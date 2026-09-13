from asyncio import Queue, StreamReader, create_task, wait_for, sleep, TaskGroup
from COMenum import COMProtocol
from TaskProtocol import TaskProtocol, TaskData
from logging import Logger
from errors import UserShutdown

class HcomReader:

    def __init__(self, instruction_queue: Queue, send_data_queue: Queue, stream_reader: StreamReader, logger: Logger):
        """
        Thread to read and format data from TempleOS
        :param instruction_queue:
        :param send_data_queue:
        """
        self.instruction_queue: Queue = instruction_queue
        self.send_data_queue: Queue = send_data_queue
        self.stream_reader: StreamReader = stream_reader
        self.logger: Logger = logger


    async def configure(self):
        """
        Wait for protocol
        :return:
        """

        try:
            async with TaskGroup() as tg:
                tg.create_task(self.wait_for_protocol())
                tg.create_task(self.wait_for_task_protocol())
        except* UserShutdown:
            print("  HcomReader shutdown...")

    async def wait_for_task_protocol(self):
        """
        Wait for instruction from the main task
        :return:
        """

        while True:
            instruction: TaskProtocol = await self.instruction_queue.get()

            match instruction:
                case TaskProtocol.STOP:
                    raise UserShutdown()

    async def wait_for_protocol(self):
        """
        Wait for a protocol sent by TempleOS
        :return:
        """

        while True:


            readed_protocol: bytes = await self.read_stream()

            match readed_protocol:
                case COMProtocol.PING.value:
                    await self.PING_read_protocol()
                case COMProtocol.SENDSTRING.value:
                    await self.SENDSTRING_read_protocol()
                case COMProtocol.SENDLINE.value:
                    await self.SENDLINE_read_protocol()
                case COMProtocol.SENDCHAR.value:
                    await self.SENDCHAR_read_protocol()


    async def read_stream(self, timeout: int = 5) -> bytes:
        """
        Read one byte data to the stream (socket)
        :return: a bytes object with one byte if success, an empty bytes object if a TimeoutError occurred
        """

        async def read():
            return await self.stream_reader.read(1)

        try:
            return await wait_for(read(), timeout=timeout)
        except TimeoutError:
            return bytes(0)

    async def PING_read_protocol(self):
        """
        Send the ping protocol to the main thread
        :return:
        """
        await self.send_data_queue.put(TaskData(COMProtocol.PING))

    async def SENDSTRING_read_protocol(self):
        """
        Get a string (ended by \0) from TempleOS
        :return:
        """

        await self.SIZE_read_protocol()

        string = ''
        char: bytes = await self.read_stream(1)
        print("caract :", char)
        while char != b'\0':
            string += char.decode('latin-1')
            char: bytes = await self.read_stream(1)
            print("caract :", char)

        await self.send_data_queue.put(TaskData(COMProtocol.SENDSTRING, _data=string))

    async def SENDLINE_read_protocol(self):
        """
        Get a line (ended by \n) from TempleOS
        :return:
        """

        await self.SIZE_read_protocol()

        line = ''
        char: bytes = await self.read_stream(1)

        while char != b'\n':
            line += char.decode('latin-1')
            char: bytes = await self.read_stream(1)

        line += '\n'

        await self.send_data_queue.put(TaskData(COMProtocol.SENDLINE, _data=line))

    async def SENDCHAR_read_protocol(self):
        """
        Get a char from TempleOS
        :return:
        """

        char: bytes = await self.read_stream(1)

        await self.send_data_queue.put(TaskData(COMProtocol.SENDCHAR, _data=char.decode('latin-1')))

    async def SIZE_read_protocol(self):
        """
        Get data size on 8 bytes
        :return:
        """

        proto: bytes = await self.read_stream(1) # not used here but need to be consumed

        size: bytearray = bytearray(8)
        for i in range(8):
            size[i] = int.from_bytes(await self.read_stream(1)) # read 8 bytes

        return int.from_bytes(size, byteorder='little')

from asyncio import Queue, StreamWriter, create_task, Task, sleep
from logging import Logger
from COMenum import COMProtocol
from TaskProtocol import TaskProtocol, TaskData

class HcomWriter:

    def __init__(self, instruction_queue: Queue, send_data_queue: Queue, stream_writer: StreamWriter, logger: Logger):
        """
        Thread to send formated data to TempleOS
        :param instruction_queue:
        :param send_data_queue:
        """
        self.instruction_queue: Queue = instruction_queue
        self.send_data_queue: Queue = send_data_queue
        self.stream_writer: StreamWriter = stream_writer
        self.logger: Logger = logger

        self.shutdown: bool = False

    async def configure(self):
        """
        Configure the thread writer
        :return:
        """

        t1 = create_task(self.wait_for_protocol())

        while not self.shutdown:
            await sleep(1)

        t1.cancel()

    async def wait_for_protocol(self):
        """
        Wait for main task instruction to send to TempleOS
        :return:
        """

        while not self.shutdown:

            task_data: TaskData = await self.instruction_queue.get()

            match task_data.type:
                case COMProtocol.PING.value:
                    await self.PING_write_protocol(task_data.type)
                case COMProtocol.SENDCHAR.value:
                    await self.SENDCHAR_write_protocol(task_data.data)
                case COMProtocol.SENDLINE.value:
                    await self.SENDLINE_write_protocol(task_data.data)
                case COMProtocol.SENDSTRING.value:
                    await self.SENDSTRING_write_protocol(task_data.data)


    async def PING_write_protocol(self, data: bytes):
        """
        Send a ping to TempleOS
        :return:
        """

        self.stream_writer.write(data)
        await self.stream_writer.drain()


    async def SENDCHAR_write_protocol(self, data: str):
        """
        Send a character to TempleOS
        :param data:
        :return:
        """

        self.stream_writer.write(COMProtocol.SENDCHAR.value)
        await self.stream_writer.drain()

        self.stream_writer.write(bytes(data, 'latin-1'))
        await self.stream_writer.drain()


    async def SENDLINE_write_protocol(self, data: str):
        """
        Send a character to TempleOS
        :param data:
        :return:
        """

        line: str = ''
        char: str = data[0] if data else ''
        i: int = 0
        while i < len(data):

            if char == '\n':

                line += '\n'

                self.stream_writer.write(COMProtocol.SENDLINE.value)
                await self.stream_writer.drain()

                self.stream_writer.write(bytes(line, 'latin-1'))
                await self.stream_writer.drain()

                line = ''

            else:
                line += char
                char = data[i]

        if line:
            self.logger.warning(f"SENDLINE write protocol : line not ended by \\n : {line}")

    async def SENDSTRING_write_protocol(self, data: str):
        """
        Send a string to TempleOS
        :param data:
        :return:
        """

        self.stream_writer.write(COMProtocol.SENDSTRING.value)
        await self.stream_writer.drain()

        self.stream_writer.write(bytes(data, 'latin-1'))
        await self.stream_writer.drain()

        # python doesn't contain \0 at end of strings
        self.stream_writer.write(bytes('\0', 'latin-1'))
        await self.stream_writer.drain()



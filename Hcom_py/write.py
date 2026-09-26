from asyncio import Queue, StreamWriter, create_task, Task, sleep, TaskGroup
from logging import Logger
from COMenum import COMProtocol
from TaskProtocol import TaskData, TaskProtocol
from typing import Union
from errors import UserShutdown

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

    async def configure(self):
        """
        Configure the thread writer
        :return:
        """

        try:
            async with TaskGroup() as tg:
                tg.create_task(self.wait_for_task_protocol())
        except* UserShutdown:
            print("  HcomWriter shutdown...")


    async def wait_for_task_protocol(self):
        """
        Wait for main task instruction to send to TempleOS
        :return:
        """

        while True:

            task_data: Union[TaskProtocol, TaskData] = await self.instruction_queue.get()

            if isinstance(task_data, TaskProtocol):
                match task_data:
                    case TaskProtocol.STOP:
                        raise UserShutdown()

            else:
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

                bytes_data: bytes = bytes(line, 'latin-1')

                self.stream_writer.write(COMProtocol.SENDLINE.value)
                await self.stream_writer.drain()

                await self.SIZE_write_protocol(len(bytes_data))

                self.stream_writer.write(bytes_data)
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

        bytes_data: bytes = bytes(data, 'latin-1')

        self.stream_writer.write(COMProtocol.SENDSTRING.value)
        await self.stream_writer.drain()

        await self.SIZE_write_protocol(len(bytes_data)+1) # +1 for \0

        self.stream_writer.write(bytes_data)
        await self.stream_writer.drain()

        # python doesn't contain \0 at end of strings
        self.stream_writer.write(bytes('\0', 'latin-1'))
        await self.stream_writer.drain()


    async def SIZE_write_protocol(self, size_data: int):
        """
        Send data size after sent the protocol
        :param size_data:
        :return:
        """

        self.stream_writer.write(COMProtocol.SIZE.value)
        await self.stream_writer.drain()

        nbr_bytes: int = (size_data.bit_length() + 7) // 8

        self.stream_writer.write(size_data.to_bytes(nbr_bytes, byteorder='big'))
        await self.stream_writer.drain()

        # if 8 bytes wasn't sent, complete it by sending empty bytes
        if nbr_bytes != 8:
            self.stream_writer.write(bytes(8-nbr_bytes))
            await self.stream_writer.drain()

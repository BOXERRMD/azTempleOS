from asyncio import Queue, StreamWriter, create_task, Task
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

        await self.wait_for_task_protocol()

    async def wait_for_task_protocol(self):
        """
        Wait for main task instruction to send to TempleOS
        :return:
        """

        while not self.shutdown:

            task_data: TaskData = await self.instruction_queue.get()

            match task_data.type:
                case COMProtocol.PING.value:
                    await self.PING_write_protocol(task_data.type)



    async def PING_write_protocol(self, data: bytes):
        """
        Send a ping to TempleOS
        :return:
        """

        self.stream_writer.write(data)
        await self.stream_writer.drain()




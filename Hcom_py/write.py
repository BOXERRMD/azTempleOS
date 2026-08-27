from asyncio import Queue, StreamWriter
from logging import Logger

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

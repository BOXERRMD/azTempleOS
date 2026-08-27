from asyncio import Queue, sleep


class HcomUser:
    """
    Class thread to manage Hcom protocol on console
    """

    def __init__(self, instruction_queue: Queue, send_data_queue: Queue,):
        """
        Entry point
        """
        self.instruction_queue: Queue = instruction_queue
        self.send_data_queue: Queue = send_data_queue

    async def configure(self):
        """
        Configure user thread
        :return:
        """

        while True:
            await sleep(8000000)

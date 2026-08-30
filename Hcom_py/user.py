from asyncio import Queue, sleep, Queue, create_task, sleep, TaskGroup
from TaskProtocol import TaskProtocol, COMProtocol, TaskData
from threading import Thread
from queue import Empty, Queue as TQueue
from typing import Union
from errors import UserShutdown

commands = """
        1 = send ping
        2 = send char
        3 = send line
        4 = send string
        rb = read buffer
        cb = clean buffer
        pb = pop first buffer entry
        s = shutdown"""

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

        self.tqueue_instructions: TQueue = TQueue()
        self.tqueue_data: TQueue = TQueue()
        self.thread: Thread = Thread(target=self.thread_configuration) # used for request user input
        self.requests_user_task: Queue = Queue()

        self.thread_shutdown: bool = False

    async def configure(self):
        """
        Configure user thread
        :return:
        """

        self.thread.start()

        try:
            async with TaskGroup() as tg:
                tg.create_task(self.wait_for_task_protocol())
                tg.create_task(self.wait_for_thread_data())
        except UserShutdown:
            print("  Shutdown HcomUser...")


    async def wait_for_thread_data(self):
        """
        Wait for data thread
        :return:
        """

        while True:

            try:
                data: Union[TaskData, TaskProtocol] = self.tqueue_data.get_nowait()
            except Empty:
                data = None

            if data is None:
                await sleep(0.1)
                continue

            await self.send_data_queue.put(data)


    async def wait_for_task_protocol(self):
        """
        Wait for a task protocol
        :return:
        """

        while True:

            instruction: TaskProtocol = await self.instruction_queue.get()

            match instruction:
                case TaskProtocol.RESEND_COMMANDS:
                    print(commands)
                    print('>>> ', end='', flush=True)

    def thread_configuration(self):
        """
        Configure the thread
        :return:
        """

        while not self.thread_shutdown:
            self.thread_wait_for_user_input()


    def thread_wait_for_task_protocol_user_input(self, input_user: str):
        """
        Wait for user input task protocol
        :return:
        """

        match input_user:
            case 's':
                self.tqueue_data.put(TaskProtocol.STOP)
                print("  HcomUser shutdown...")
                self.thread_shutdown = True
            case 'rb':
                self.tqueue_data.put(TaskProtocol.READ_READER_BUFFER)
            case 'cb':
                self.tqueue_data.put(TaskProtocol.CLEAN_READER_BUFFER)
            case 'pb':
                self.tqueue_data.put(TaskProtocol.POP_READER_BUFFER)

    def thread_wait_for_user_input(self):
        """
        Wait for a user input
        :return:
        """

        input_user: str = input()

        if not input_user.isdigit():
            self.thread_wait_for_task_protocol_user_input(input_user)
            return

        int_user_input = int(input_user)

        match int_user_input.to_bytes():

            case COMProtocol.PING.value:
                print("   Send PING to TempleOS...")
                self.tqueue_data.put(TaskData(COMProtocol.PING))

            case COMProtocol.SENDCHAR.value:
                print("   Send CHAR to TempleOS...")
                char: str = input('Type a char : ')
                while len(char) != 1:
                    print(f"'{char}' is not a valid character !")
                    char: str = input('Type a char : ')
                self.tqueue_data.put(TaskData(COMProtocol.SENDCHAR, char))

            case COMProtocol.SENDLINE.value:
                print("   Send LINE to TempleOS...")
                line: str = input('Type a line (ended by \\n) : ')
                self.tqueue_data.put(TaskData(COMProtocol.SENDLINE, line))

            case COMProtocol.SENDSTRING.value:
                print("   Send STRING to TempleOS...")
                string: str = input('Type a string : ')
                self.tqueue_data.put(TaskData(COMProtocol.SENDSTRING, string))

            case _:
                pass


from COMenum import COMProtocol
from TaskProtocol import TaskData
from read import HcomReader
from write import HcomWriter
from user import HcomUser
from typing import Optional, Union, Any
from asyncio import run, Queue, open_connection, StreamReader, StreamWriter, sleep, Task, create_task
from logging import getLogger

class HCOM:

	def __init__(self, address: str = '127.0.0.1', port: int = 4444, attempt_socket_connexion: int = 1, sleep_before_reattempt_socket_connexion: int = 0):
		self.address = address
		self.port = port
		self.attempt_socket_connexion: int = attempt_socket_connexion
		self.sleep_before_reattempt_socket_connexion: int = sleep_before_reattempt_socket_connexion

		self.hcom_reader_instruction_queue: Queue = Queue()
		self.hcom_reader_data_queue: Queue = Queue()

		self.hcom_writer_instruction_queue: Queue = Queue()
		self.hcom_writer_data_queue: Queue = Queue()

		self.hcom_user_instruction_queue: Queue = Queue()
		self.hcom_user_data_queue: Queue = Queue()

		self.socket_reader: StreamReader = None
		self.socket_writer: StreamWriter = None

		self.task_reader: Task = None
		self.task_writer: Task = None
		self.task_user: Task = None

		self.logger = getLogger(__name__)

		self.is_pinging: bool = False

		run(self.config())


	async def config(self):
		"""
		Configure the connexion and threads and wait for response
		:return:
		"""
		if not await self.wait_for_socket_connexion():
			critical_message = "TempleOS VM not found !"
			self.logger.critical(critical_message)
			raise ConnectionRefusedError(critical_message)

		await self.config_tasks()

		create_task(self.wait_for_hcom_reader_data())
		#create_task(self.wait_for_hcom_writer_data())

		while not self.task_user.done():
			await sleep(1)

		self.task_writer.cancel()
		self.task_reader.cancel()

		self.hcom_reader_instruction_queue.shutdown()
		self.hcom_writer_instruction_queue.shutdown()
		self.hcom_user_instruction_queue.shutdown()

		self.hcom_reader_data_queue.shutdown()
		self.hcom_writer_data_queue.shutdown()
		self.hcom_user_data_queue.shutdown()

		self.socket_writer.close() # close the connection socket


	async def wait_for_hcom_reader_data(self):
		"""
		Wait for data in hcom_reader_data_queue queue
		:return:
		"""

		while not self.task_user.done():
			print("Wait for data from TempleOS...")
			data = await self.hcom_reader_data_queue.get()
			print(f"Data from TempleOS : {data.type} - {data.data}")

			# if TempleOS request ping to the current system, and we don't ping before
			if data.type == COMProtocol.PING.value:
				if not self.is_pinging:
					await self.hcom_writer_instruction_queue.put(TaskData(COMProtocol.PING))
				else:
					self.logger.info("    Ping successful whith TempleOS !")
					self.is_pinging = False

	async def wait_for_hcom_user_data(self):
		"""
		Wait for data in hcom_user_data_queue queue
		:return:
		"""
		while not self.task_user.done():

			data = await self.hcom_user_data_queue.get()

			# if the user request a ping to TempleOS
			if data.type == COMProtocol.PING.value:
				self.is_pinging = True
				self.hcom_writer_instruction_queue(TaskData(COMProtocol.PING))

	async def wait_for_socket_connexion(self) -> bool:
		"""
		Wait for socket connexion.
		:return: Return the current status connexion
		"""

		attempt: int = 0
		connect: bool = False
		self.logger.info("Wait for connexion...")
		while not connect and attempt < self.attempt_socket_connexion:
			self.logger.info(" - Attempt ", attempt+1)
			try:
				self.socket_reader, self.socket_writer = await open_connection(self.address, self.port)
				connect = True
				self.logger.info("    Connexion success")
			except ConnectionRefusedError:
				attempt += 1
				self.logger.error("Connexion Refused ! Please, look if your TempleOS VM is active !")
				await sleep(self.sleep_before_reattempt_socket_connexion)

		return connect

	async def config_tasks(self) -> bool:
		"""
		Config tasks reader/writer
		:return:
		"""

		self.task_reader = create_task(HcomReader(self.hcom_reader_instruction_queue, self.hcom_reader_data_queue, self.socket_reader, self.logger).configure())
		self.task_writer = create_task(HcomWriter(self.hcom_writer_instruction_queue, self.hcom_writer_data_queue, self.socket_writer, self.logger).configure())
		self.task_user = create_task(HcomUser(self.hcom_user_instruction_queue, self.hcom_user_data_queue).configure())



if __name__ == '__main__':
	Hcom_class = HCOM()

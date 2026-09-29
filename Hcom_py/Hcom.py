from asyncio import open_connexion, StreamReader, StreamWriter
from time import sleep
from typing import Optional

from Constants import PACKET_SIZE

async def makeSocketConnexion(address: str, port: int, retry_after: int = 3, max_retry: int = 5 ) -> tuple[StreamReader, StreamWriter]:
    """
    Make the socket connexion to TempleOS.
    Return a tuple of StreamReader and StreamWriter asyncio class.
    :param address: The server address made by QEMU (look at -serial parameter in the command to start TempleOS)
    :param port: The server port of QEMU server (look at -serial parameter in the command to start TempleOS)
    :param retry_after: Time in second to wait before retry a connexion to QEMU
    :param max_retry: Max connexion retry after give up
    :return: tuple of StreamReader and StreamWriter asyncio class
    :except Connexion
    """

    is_connected: bool = False
    current_retry: int = 0

    reader: Optional[StreamReader] = None
    writer: Optional[StreamWriter] = None

    while not is_connected and current_retry < max_retry:
        try:
            reader, writer = await open_connexion(address, port)
            is_connected = True
        except ConnectionRefusedError:
            sleep(retry_after)
            current_retry += 1

    if not is_connected or reader is None or writer is None:
        raise ConnectionRefusedError("Unable to connect with TempleOS QEMU VM. Please, run QEMU VM before start the script.")

    return reader, writer


async def sendBytes(writer: StreamWriter, data: bytes) -> None:
    """
    Send bytes to TempleOS
    :param writer: The open StreamWriter stream with the makeSocketConnexion function
    :param data: bytes to sent at TempleOS
    :return: None
    """

    if len(data) <= 0:
        return

    writer.write(data)
    await writer.drain()

async def readBytes(reader: StreamReader, size: int = PACKET_SIZE) -> bytes:
    """
    Read "size" bytes from TempleOS.
    Wait until all bytes was read
    :param reader:
    :param size:
    :return:
    """

    data = await reader.readexactly(size)
    return data


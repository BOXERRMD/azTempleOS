"""
This file make the protocol to send/read commands
"""

class DataCommand:

    def __init__(self, _type: int, _id: int, _flags: int, _data_length: int, _data: str):
        self._type = _type
        self._id = _id
        self._flags = _flags
        self._data_length = _data_length
        self._data = _data

async def readCommand(data: bytes) -> DataCommand:
    """
    Read a packet to make a DataCommand class
    :param data:
    :return:
    """
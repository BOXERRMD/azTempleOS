"""
This file make the protocol to send/read commands
"""
from typing import Union
from Constants import *

class DataCommand:

    def __init__(self, _type: int, _id: int, _flags: int, _packet_number: int, _data_length: int, _data: str):
        self._type = _type
        self._id = _id
        self._flags = _flags
        self._packet_number = _packet_number
        self._data_length = _data_length
        self._data = _data

async def readCommand(data: bytes) -> DataCommand:
    """
    Read a packet to make a DataCommand class
    :param data:
    :return:
    """

    tmp: dict[str, Union[int, str]] = {}
    i: int = 0

    tmp['_type'] = int.from_bytes(data[i:PACKET_TYPE_SIZE])
    i += PACKET_TYPE_SIZE

    tmp['_id'] = int.from_bytes(data[i:i+PACKET_ID_SIZE])
    i += PACKET_ID_SIZE

    tmp['_flags'] = int.from_bytes(data[i:i+PACKET_FLAGS_SIZE])
    i += PACKET_FLAGS_SIZE

    tmp['_packet_number'] = int.from_bytes(data[i:i+PACKET_NUMBER_SIZE])
    i += PACKET_NUMBER_SIZE

    tmp['_data_length'] = int.from_bytes(data[i:i+PACKET_DATA_LENGTH])
    i += PACKET_DATA_LENGTH

    tmp['_data'] = data[i:i+tmp['_data_length']].decode(TEMPLEOS_STRING_FORMAT, 'ignore')

    return DataCommand(**tmp)
from typing import Callable
from functools import reduce
from operator import or_

PACKET_SIZE: int = 1024     # octets
PACKET_ID_SIZE: int = 4     # octets
PACKET_TYPE_SIZE: int = 1   # octet
PACKET_FLAGS_SIZE: int = 2  # octets
PACKET_NUMBER_SIZE: int = 8 # octets
PACKET_DATA_LENGTH: int = 2 # octets
PACKET_DATA_SIZE: int = (PACKET_SIZE -
                         PACKET_ID_SIZE -
                         PACKET_TYPE_SIZE -
                         PACKET_FLAGS_SIZE -
                         PACKET_NUMBER_SIZE -
                         PACKET_DATA_LENGTH)

TEMPLEOS_STRING_FORMAT: str = 'cp437'
TEMPLEOS_BYTES_FORMAT: str = 'big'

FLAGS_CALCULATOR: Callable = lambda *flags: reduce(or_, flags)
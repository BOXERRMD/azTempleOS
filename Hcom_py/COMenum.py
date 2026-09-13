from enum import Enum

class COMProtocol(Enum):
    PING = 0x01.to_bytes()
    SENDCHAR = 0x02.to_bytes()
    SENDLINE = 0x03.to_bytes()
    SENDSTRING = 0x04.to_bytes()
    SIZE = 0x05.to_bytes()

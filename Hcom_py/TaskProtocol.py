from enum import IntEnum
from COMenum import COMProtocol
from typing import Any, Optional

class TaskProtocol(IntEnum):
    STOP = 1
    RESEND_COMMANDS = 2
    READ_READER_BUFFER = 3
    CLEAN_READER_BUFFER = 4
    POP_READER_BUFFER = 5


class TaskData:
    def __init__(self, _type: COMProtocol, _data: Optional[Any] = None):
        self._type = _type.value
        self._data = _data

    @property
    def type(self):
        return self._type

    @property
    def data(self):
        return self._data

    def __repr__(self):
        return f"TaskData : {self.type} - {self.data}"

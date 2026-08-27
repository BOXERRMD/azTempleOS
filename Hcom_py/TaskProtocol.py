from enum import IntEnum
from COMenum import COMProtocol
from typing import Any, Optional

class TaskProtocol(IntEnum):
    STOP = 1


class TaskData:
    def __init__(self, _type: COMProtocol, _data: Optional[Any] = None):
        self._type = _type
        self._data = _data

    @property
    def type(self):
        return self._type

    @property
    def data(self):
        return self._data

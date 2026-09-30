from Pcommand import readCommand, DataCommand
from Protocol import *
from Constants import *
from asyncio import run
from random import randbytes, choices, randint

def writeInBytearray(data: bytearray, cur_pos: int, to_write: bytearray) -> int:

    i: int = 0
    while i<len(to_write) and cur_pos<len(data):
        data[cur_pos] = to_write[i]
        i+=1
        cur_pos+=1

    return cur_pos

async def readCommandTest():
    data: bytearray = bytearray(PACKET_SIZE)

    i: int = 0

    _type: bytearray = bytearray(randbytes(PACKET_TYPE_SIZE))
    i = writeInBytearray(data, i, _type)

    _id: bytearray = bytearray(randbytes(PACKET_ID_SIZE))
    i = writeInBytearray(data, i, _id)

    _flags: bytearray = bytearray(FLAGS_CALCULATOR(
                                    *choices(
                                        HcomEnumFlags.getValues(), k = randint(1, len(HcomEnumFlags.getValues())-1)
                                    )
                                  ).to_bytes(2))
    i = writeInBytearray(data, i, _flags)

    _packet_number: bytearray = bytearray(PACKET_NUMBER_SIZE)
    _packet_number[0] = 0x01
    i = writeInBytearray(data, i, _packet_number)

    _command: bytearray = bytearray('Cd("/azTempleOS/Shell");;Dir;'.encode(TEMPLEOS_STRING_FORMAT))
    _data_length: bytearray = bytearray(len(_command).to_bytes(PACKET_DATA_LENGTH))

    i = writeInBytearray(data, i, _data_length)
    i = writeInBytearray(data, i, _command)

    data_command: DataCommand = await readCommand(data)

    assert data_command._type == int.from_bytes(_type), "types is not the same !"
    assert data_command._id == int.from_bytes(_id), "id is not the same !"
    assert data_command._flags == int.from_bytes(_flags), "flags is not the same !"
    assert data_command._packet_number == int.from_bytes(_packet_number), "packet number is not the same !"
    assert data_command._data_length == int.from_bytes(_data_length), "data length is not the same !"
    assert data_command._data == _command.decode(TEMPLEOS_STRING_FORMAT, 'ignore'), "data is not the same !"

if __name__ == '__main__':
    run(readCommandTest())
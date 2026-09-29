
# Hcom protocol
HCOM_PING: bytes = 0x00.to_bytes(1)
HCOM_COMMAND: bytes = 0x01.to_bytes(1)
HCOM_FILE: bytes = 0x02.to_bytes(1)
HCOM_DIRECTORY: bytes = 0x03.to_bytes(1)


# Hcom flags
FLAGS_NONE: int = 0
FLAGS_START: int = 1 << 0
FLAGS_END: int = 1 << 2
FLAGS_ACK: int = 1 << 3  # resent if the packet is received
FLAGS_NACK: int = 1 << 4 # resent if a timeout is raised before receive a packet / a packet is missing

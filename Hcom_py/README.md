
### packet : 1024 octets MAX

**FORMAT : BIG ENDIAN**

- Type *(U8 = 1 octet)* : request type (command, file, string...)
- ID *(U32 = 4 octets)* : requests (all packets get the same ID if it's for the same request)
- Flags *(U16 = 2 octets)* : flags for errors / last packet
- Packet number *(U64 = 8 octets)* : packet number to look if packets is lost | to restore data at the end
- Data length *(U16 = 2 octets)* : The Data size passed in the packet (<= 1007)
- Data *(U8 ~ 1007 octets)*

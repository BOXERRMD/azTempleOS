
U0 findEHCI(){

  I64 bus,device,function;
  U16 vendor_id;
  U32 class_code;
  I64 class_id, subclass_id, prog_if;

  "Scan PCI port...";

  for (bus=0; bus<256; bus++){
    for (device=0; device<32; device++){
      for (function=0; function<8; function++){
        
        vendor_id = PCIReadU16(bus, device, function, 0x00);

        if (vendor_id != 0xFFFF){

          class_code = PCIReadU32(bus, device, function, 0x08);

          class_id = class_code >> 24;
          subclass_id = (class_code >> 16) & 0xFF;
          prog_if = (class_code >> 8) & 0xFF;

          if (class_id == 0x0C && subclass_id == 0x03 && prog_if == 0x20){
          
            "Success ! EHCI controler find !\n";
            "Bus : %d   Device : %d   Function : %d\n", bus, device, function;
            return;

          }

        }

      }
     Yield;
    }
  }
  "EHCI not found...\n";
}

findEHCI;
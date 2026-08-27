                           TempleOS

You can't do much until you burn a TempleOS CD/DVD from the ISO file
and boot it, or you aim your virtual machine's CD/DVD at the ISO file
and boot.  TempleOS files are compressed and the source code can only be 
compiled by the TempleOS compiler... which is available when you boot
the CD/DVD.  TempleOS is 100% open source with all source present.

TempleOS is 64-bit and will not run on 32-bit hardware.

TempleOS requires 512 Meg of RAM minimum.

TempleOS may require you to enter I/O port addresses for the CD/DVD drive
and the hard drive.  In Windows, you can find I/O port info in the
Accessories/System Tools/System Info/Hardware Resources/I/O ports.
Look for and write down "IDE", "ATA" or "SATA" port numbers.  In Linux, use
"lspci -v".  Then, boot the TempleOS CD and try all combinations.  (Sorry,
it's too difficult for TempleOS to figure-out port numbers, automatically.)

The source code can also be found at the TempleOS web site, 
http://www.templeos.org but cannot be compiled outside TempleOS because
it's HolyC, a nonstandard C/C++ dialect, and asm.

                           azTempleOS

azTempleOS is a rewrited OS from the original TempleOS made by Terry Davis.
It support azerty keyboard mapping but with some changes.

You can find an .ISO in the **::/azTempleOS** directory if you want try it.
Keyboard mapping is in **::/azTempleOS/Keyboard/Layouts/**.

In mapping, each character code (or scancode if it's the first code on the line) will be behind a ;
If a ; follow an another ; the value it's considered to 0.
The "." is the same caracter like the second code of the current line.
Exemple :
    0x10; 50; .; ; .;   =    0x10; 50; 50; 0; 50;
    
0x10 is the scancode. After the first ;, all code is a caracter (in decimal or hexadecimal)
You can make comment with "/"

ALT combo is make on "~/HomeKeyPlugins". You can set ALT combo in this file.

You can also make your personal font and load it when your systemt starting up.

All documentation is in the system. Look "Font" and "Keymap" in /Doc directory.

This project is, like the original TempleOS repo, 100% open source.

Changes made by BOXERRMD.
Rest in peace Terry Davis...

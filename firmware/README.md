# Firmware

This is sample software to run as the Cartridge Firmware, in order to demonstrate how to trigger NOXROM paging.

NOTE: Currently this software is a TEST version that is compiled as a regular TAP (ZX Spectrum tape format), that is loaded into RAM through the usual process:
   LOAD ""

A later version will run directly from ROM start address (0x0000), as a boot ROM, with correct interrupt handlers defined as needed.


# How to compile
Batch file (compile.bat) is used to compile (on windows), which current function is just to compile and attach the required ZX Spectrum BASIC loader.
To compile, Pasmo assembler needs to exist on the PATH system variable.

NOTE: It can be compiled alternatively on an Unix system, given a suitable assembler, compatible with Pasmo syntax.

Main files:
- NOXTEST.asm
	Graphical oriented Paging version

- NOXTEST-Paging.asm
	Simple text oriented Paging version


Assembly code uses Pasmo assembler syntax for asm files.


Both versions page NOXROM into defined page, and then start a "fake boot" process, i.e it setups CPU state (all it's registers) into a similar state when hardware reset is done, which includes as final step, a jump to boot address 0x0000.

Note: Memory is not changed in anyway during a "fake boot".


For "fake boot" to actualy boot the machine, NOXROM must have in it's Flash memory, in the correct page (16KB slot) the required contents to boot the computer.

Flash can contain a cartridge ROM, an application or game ROM, or even a set of Pages to keep a full snapshot 48JB (3x16KB). Although the set of pages is not supported yet.

WARNING:
No actual ROM software is supplied, since many of them are copyrighted.
There are however, some that are available, like "The GOSH WONDERFUL ZX Spectrum ROM", as a compatible replacement for the ZX Spectrum 48KB ROM.


# Other uses
A large pageable Flash ROM, allows to do a lot more than just replace the ZX Spectrum internal ROM .
New software utilities or games can use the extra space available in several ways.
- To load more then 48KB of software, in a 48KB machine, by paging the Flash ROM in similar way to how the ZX Spectrum 128KB did to its 4 memory pages. The difference is that Flash ROM as a single page area to manage (the ROM one).
- To load Levels from Flash
- To "page in" Sprites or Game data required, for render.
- to "page in" Reference tables or memory aligned tables required for some speed optimization.
- etc ...
 


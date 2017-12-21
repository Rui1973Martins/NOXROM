# NOXROM
 is a ZX Spectrum Cartridge compatible system, that extends the ROM size beyond 16KB


To use a NOXROM cartridge a regular cartridge interface is required to plug it in to a ZX Spectrum 48KB.

Common retro interfaces are:
- Sinclair ZX Interface 2
. RAM Turbo
- Kempston Pro

Modern tnterfaces also exist, with the same compatible Cartridge socket, like the "SPECTRA Interface" by Paul Farrows.


This is a hardware implementation of a new smart cartridge, that currently can have 128KB, 256KB or %12KB, pageable in 16KB blocks. This is implemented using a CPLD (for control logic) and a parallel interface Flash chip.

NOXROM cartridge is smart, in the sense that it supports side band signaling, as a form of communication, that allows ZX software to control the internal cartridge paging register, hence allowing the use of the entire Flash chip memory, mapped into the ZX Spectrum ROM 16KB address space.

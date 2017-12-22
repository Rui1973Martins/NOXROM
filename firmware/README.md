# Firmware

This is sample software to run as the Cartridge Firmware, in order to demonstrate how to trigger NOXROM paging.

NOTE: Currently this software is a TEST version that is compiled as a regular TAP (ZX Spectrum tape format), that is loaded into RAM through the usual process:
   LOAD ""

A later version will run directly from ROM start address (0x0000), as a boot ROM, with correct interrupt handlers defined as needed. 
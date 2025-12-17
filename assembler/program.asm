interrupt_start:


main_start:
    LDM R0, 0x05
    LDM R1, 0x03
    ADD R0, R1
    OUT R0
    STD R0, 0x09
    LDD R2, 0x09
    OUT R2
    NOP
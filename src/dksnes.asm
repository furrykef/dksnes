// Written for bass v14
// Note: $00 and $01 can freely be used for temp variables in some code
arch snes.cpu

include "snes.inc"
include "nescolors.inc"

macro assert(evaluate condition) {
    if !{condition} {
        error "Assertion failure"
    }
}


constant DMA_XFER8($00)
constant DMA_XFER16($01)
constant DMA_FILL8_8($08)                   // fill 8-bit value into 8-bit register
constant DMA_FILL8_16($09)                  // fill 8-bit value into 16-bit register

// Assumes X is 8-bit and M is 16-bit
macro PrepDma(evaluate channel, evaluate mode, evaluate dest_reg, evaluate src_addr, evaluate size) {
        ldx.b #{mode}
        stx.w DMAP0+{channel}*$10
        ldx.b #{dest_reg}
        stx.w BBAD0+{channel}*$10
        lda.w #{src_addr}
        sta.w A1T0L+{channel}*$10
        ldx.b #{src_addr} >> 16
        stx.w A1B0+{channel}*$10
        lda.w #{size}
        sta.w DAS0L+{channel}*$10
}


constant MyRAM(0x0800)

constant MyOAM(MyRAM)                       // 256 bytes (we're only using half of the low table)
constant DKFallFlag(MyRAM+$0100)
constant BlueFireballFlag(MyRAM+$0101)


// Program output begins here

base $808000

ChrData:
        insert "../snes.chr"
constant ChrDataSize(pc() - ChrData)

start:
        // Boilerplate SNES init code
        // Taken from Wikibooks (IIRC), then tweaked
        sei         // Disabled interrupts
        jml +       // run from FastROM region
+;      phk
        plb
        clc         // clear carry to switch to native mode
        xce         // Xchange carry & emulation bit. native mode
        rep #$38    // Binary mode (decimal mode off), A/X/Y 16 bit
        lda.w #0
        tcd
        ldx.w #$01ff
        txs
        sep #$30    // X,Y,A are 8 bit numbers
        lda.b #$8F    // screen off, full brightness
        sta.w $2100   // brightness + screen enable register
        stz.w $2101   // Sprite register (size + address in VRAM)
        stz.w $2102   // Sprite registers (address of sprite memory [OAM])
        stz.w $2103   //    ""                       ""
        stz.w $2105   // Mode 0, = Graphic mode register
        stz.w $2106   // noplanes, no mosaic, = Mosaic register
        stz.w $2107   // Plane 0 map VRAM location
        stz.w $2108   // Plane 1 map VRAM location
        stz.w $2109   // Plane 2 map VRAM location
        stz.w $210A   // Plane 3 map VRAM location
        stz.w $210B   // Plane 0+1 Tile data location
        stz.w $210C   // Plane 2+3 Tile data location
        stz.w $210D   // Plane 0 scroll x (first 8 bits)
        stz.w $210D   // Plane 0 scroll x (last 3 bits) #$0 - #$07ff
        lda.b #$FF    // The top pixel drawn on the screen isn't the top one in the tilemap, it's the one above that.
        sta.w $210E   // Plane 0 scroll y (first 8 bits)
        sta.w $2110   // Plane 1 scroll y (first 8 bits)
        sta.w $2112   // Plane 2 scroll y (first 8 bits)
        sta.w $2114   // Plane 3 scroll y (first 8 bits)
        lda.b #$07    // Since this could get quite annoying, it's better to edit the scrolling registers to fix this.
        sta.w $210E   // Plane 0 scroll y (last 3 bits) #$0 - #$07ff
        sta.w $2110   // Plane 1 scroll y (last 3 bits) #$0 - #$07ff
        sta.w $2112   // Plane 2 scroll y (last 3 bits) #$0 - #$07ff
        sta.w $2114   // Plane 3 scroll y (last 3 bits) #$0 - #$07ff
        stz.w $210F   // Plane 1 scroll x (first 8 bits)
        stz.w $210F   // Plane 1 scroll x (last 3 bits) #$0 - #$07ff
        stz.w $2111   // Plane 2 scroll x (first 8 bits)
        stz.w $2111   // Plane 2 scroll x (last 3 bits) #$0 - #$07ff
        stz.w $2113   // Plane 3 scroll x (first 8 bits)
        stz.w $2113   // Plane 3 scroll x (last 3 bits) #$0 - #$07ff
        lda.b #$80    // increase VRAM address after writing to $2119
        sta.w $2115   // VRAM address increment register
        stz.w $2116   // VRAM address low
        stz.w $2117   // VRAM address high
        stz.w $211A   // Initial Mode 7 setting register
        stz.w $211B   // Mode 7 matrix parameter A register (low)
        lda.b #$01
        sta.w $211B   // Mode 7 matrix parameter A register (high)
        stz.w $211C   // Mode 7 matrix parameter B register (low)
        stz.w $211C   // Mode 7 matrix parameter B register (high)
        stz.w $211D   // Mode 7 matrix parameter C register (low)
        stz.w $211D   // Mode 7 matrix parameter C register (high)
        stz.w $211E   // Mode 7 matrix parameter D register (low)
        sta.w $211E   // Mode 7 matrix parameter D register (high)
        stz.w $211F   // Mode 7 center position X register (low)
        stz.w $211F   // Mode 7 center position X register (high)
        stz.w $2120   // Mode 7 center position Y register (low)
        stz.w $2120   // Mode 7 center position Y register (high)
        stz.w $2121   // Color number register ($0-ff)
        stz.w $2123   // BG1 & BG2 Window mask setting register
        stz.w $2124   // BG3 & BG4 Window mask setting register
        stz.w $2125   // OBJ & Color Window mask setting register
        stz.w $2126   // Window 1 left position register
        stz.w $2127   // Window 2 left position register
        stz.w $2128   // Window 3 left position register
        stz.w $2129   // Window 4 left position register
        stz.w $212A   // BG1, BG2, BG3, BG4 Window Logic register
        stz.w $212B   // OBJ, Color Window Logic Register (or,and,xor,xnor)
        sta.w $212C   // Main Screen designation (planes, sprites enable)
        stz.w $212D   // Sub Screen designation
        stz.w $212E   // Window mask for Main Screen
        stz.w $212F   // Window mask for Sub Screen
        lda.b #$30
        sta.w $2130   // Color addition & screen addition init setting
        stz.w $2131   // Add/Sub sub designation for screen, sprite, color
        lda.b #$E0
        sta.w $2132   // color data for addition/subtraction
        stz.w $2133   // Screen setting (interlace x,y/enable SFX data)
        stz.w $4200   // Enable V-blank, interrupt, Joypad register
        lda.b #$FF
        sta.w $4201   // Programmable I/O port
        stz.w $4202   // Multiplicand A
        stz.w $4203   // Multiplier B
        stz.w $4204   // Multiplier C
        stz.w $4205   // Multiplicand C
        stz.w $4206   // Divisor B
        stz.w $4207   // Horizontal Count Timer
        stz.w $4208   // Horizontal Count Timer MSB (most significant bit)
        stz.w $4209   // Vertical Count Timer
        stz.w $420A   // Vertical Count Timer MSB
        stz.w $420B   // General DMA enable (bits 0-7)
        stz.w $420C   // Horizontal DMA (HDMA) enable (bits 0-7)
        lda.b #$01
        sta.w $420D   // Access cycle designation (slow/fast rom)

        // *** init video ***
        // display and NMI are off when we get here

        SetM16()

        // Clear VRAM
        stz.w VMADDL
        PrepDma(0, DMA_FILL8_16, VMDATAL, Zero, 0)
        ldx.b #$01
        stx.w MDMAEN

        // Transfer CHR to VRAM $0000
        stz.w VMADDL
        PrepDma(0, DMA_XFER16, VMDATAL, ChrData, ChrDataSize)
        ldx.b #$01
        stx.w MDMAEN

        // Init OAM, low and high tables
        stz.w OAMADDL
        PrepDma(0, DMA_FILL8_8, OAMDATA, ByteD240, 512)
        PrepDma(1, DMA_FILL8_8, OAMDATA, Zero, 32)
        ldx.b #$03
        stx.w MDMAEN

        SetM8()

        // Set video mode
        lda.b #$01                          // Mode 1, 8x8 tiles
        sta.w BGMODE
        sta.w BG12NBA                         // BG1 CHR at $1000
        lda.b #$11                          // BG1 and sprites visible
        sta.w TM
        stz.w TS                              // no subscreen
        lda.b #$20                          // BG1 nametable at $2000, 32x32
        sta.w BG1SC

        // Sprite nametable address will already be $0000, which is correct

        // Clear vars
        stz.w DKFallFlag
        stz.w BlueFireballFlag

        // We'll be running from the other bank from now on
        lda.b #$81
        pha
        plb

        // Jump to NES version's init routine
        // (after its first wait for vblank)
        jml $81c7af


HandleVblank:
        jml HandleVblankImpl

DummyInterruptHandler:
        rti


// Bytes and words used in DMA
Zero:
        dw 0

ByteD240:                                   // D stands for decimal
        db 240


// SNES header
origin $7fc0
        // Name (21 bytes, padded with spaces)
        db "DONKEY KONG          "

        // ROM type
        db $30                              // LoROM, fast

        // Cartridge type
        db $00                              // ROM only

        // Size of ROM
        db $06                              // 64 KB

        // Size of RAM
        db $00                              // none

        // Country code
        db $01                              // North America, NTSC

        // Licensee code
        db $00

        // ROM version
        db $00

        // checksum complement and checksum
        dw 0
        dw 0


origin $7fe4
        // 65816 interrupt vectors
        dw DummyInterruptHandler            // COP
        dw DummyInterruptHandler            // BRK
        dw DummyInterruptHandler            // ABORT
        dw HandleVblank                     // NMI
        dw DummyInterruptHandler            // unused
        dw DummyInterruptHandler            // IRQ

origin $7ff4
        // 6502 interrupt vectors
        dw DummyInterruptHandler            // COP
        dw DummyInterruptHandler            // unused
        dw DummyInterruptHandler            // ABORT
        dw DummyInterruptHandler            // NMI
        dw start                            // RESET
        dw DummyInterruptHandler            // IRQ/BRK


// We should now be at 0x8000 in the ROM
assert(origin() == $8000)
base $818000

// replaces the NES version's writes to PPUCTRL
// we only worry about the parts the game actually uses
// all regs 8-bit on entry and exit
SetPPUCTRL:
        pha
        phx
        ldx.b #$80                          // Assume VRAM increment should be 1
        bit.b #$04                          // Bit 2 (VRAM inc) of PPUCTRL set?
        beq +
        ldx.b #$81                          // Set 32-word increment if so
+;      stx.w VMAIN
        and.b #$80                          // Mask off everything but NMI enable flag
        sta.w NMITIMEN
        plx
        pla
        rts


// replaces the NES version's writes to PPUCTRL
// we only worry about the parts the game actually uses
// all regs 8-bit on entry and exit
SetPPUMASK:
        pha
        phx
        ldx.b #$0f                          // Assume display on
        bit.b #$18                          // Check BG and sprite enable bits of PPUMASK
        bne +
        ldx.b #$80                          // Turn display off if bits weren't set
+;      stx.w INIDISP
        and.b #$10                          // Mask out all but sprite flag
        ora.b #$01                          // BG always on
        sta.w TM
        plx
        pla
        rts


// In:
//  A = $00 for level 1
//      $02 is unused (pie factory leftover?)
//      $04 for level 2
//      $06 for level 3
//      $08 for title screen
//      $0A for HUD
// Out:
//  X = PPUSTATUS (we'll ignore this)
//
// Registers can be clobbered
LoadGfx:
        cmp.b #$0a
        bcs .end
        tay
        lda.b #$80                          // Ensure VRAM increment is 1
        sta.w VMAIN
        stz.w CGADD
        stz.w BlueFireballFlag
        SetM16()

        lda.w #$2000
        sta.w VMADDL
        ldx.b #DMA_XFER16
        stx.w DMAP0
        ldx.b #VMDATAL
        stx.w BBAD0
        // bass v14 won't let me write lda.w MapTbl,y
        lda MapTbl,y
        sta.w A1T0L
        ldx.b #$81
        stx.w A1B0
        lda.w #32*30*2
        sta.w DAS0L

        ldx.b #DMA_XFER8
        stx.w DMAP1
        ldx.b #CGDATA
        stx.w BBAD1
        // bass v14 again won't allow lda.w here
        lda PalTbl,y
        sta.w A1T1L
        ldx.b #$81
        stx.w A1B1
        lda.w #512
        sta.w DAS1L

        ldx.b #$03
        stx.w MDMAEN
        SetM8()
.end:
        rts


// Replaces $F211 in the original code
// We have to add an extra byte since VMDATA expects 16-bit words
CopyOrFillVramLoop:
        bcs +
        iny
+;      lda ($00),y
        sta.w VMDATAL
        php                                 // need to preserve carry flag
        cmp.b #$62
        beq .girder
        lda.b #$08                          // palette 3 (DK palette)
        bra .store
.girder:
        lda.b #$00
.store:
        sta.w VMDATAH
        plp                                 // restore carry flag
        dex
        bne CopyOrFillVramLoop
        jmp $f21c


// This routine originally loaded the display list for when DK falls
// We have to patch it so DK has the correct palette
// Notably, our version does not remove the writes to palette VRAM
// (so it will clobber VRAM at $3fxx)
DKFalls:
        lda.b #1
        sta.w DKFallFlag

        // Original code which our hook patched over
        ldy.b #$16
        lda.b #$0c
        jmp $c823


// Replaces code at $d89a
// (original code still clobbers VRAM at $3fxx)
MakeFireballsBlue:
        lda.b #1
        sta.w BlueFireballFlag

        // Original code which our hook patched over
        lda.b #$19
        sta.b $00
        lda.b #$3f
        sta.b $01
        lda.b #$46
        jsr $c815
        rts


// Replaces code at $d7f2
// (original code still clobbers VRAM at $3fxx)
MakeFireballsRed:
        lda.b #0
        sta.w BlueFireballFlag

        // Original code which our hook patched over
        lda.b #$19
        sta.b $00
        lda.b #$3f
        sta.b $01
        lda.b #$43
        jsr $c815
        rts


// We don't have to worry about preserving X or Y here
HandleVblankImpl:
        SetM16()
        pha

        // Prepare to copy sprites from last frame to OAM
        stz.w OAMADDL
        PrepDma(0, DMA_XFER8, OAMDATA, MyOAM, 256)

        // Prepare to copy fireball palette
        ldx.b #160
        stx.w CGADD
        PrepDma(1, DMA_XFER8, CGDATA, Level1Pal+160*2, 32)
        ldx.w BlueFireballFlag
        beq +
        // Fireballs are blue
        lda.w #BlueFireballPal
        sta.w A1T1L
+
        // Let's do it to it
        ldx.b #$03
        stx.w MDMAEN

        // Do any palette updates
        ldx.w DKFallFlag
        beq .no_fall
        // Put DK's palette in sprite palette 4
        ldx.b #176
        stx.w CGADD
        PrepDma(0, DMA_XFER8, CGDATA, Level3Pal + 32*2, 32)
        ldx.b #$01
        stx.w MDMAEN
        ldx.b #0
        stx.w DKFallFlag
.no_fall:

        SetM8()
        jsr $c85f                           // run original vblank routine

        // Convert NES version's OAM to our OAM
        // Rather slow, but the game seems to run fine anyway
        SetM8()
        ldx.b #$00
.oam_loop:
        lda.w $0200,x                       // get Y coordinate
        clc
        adc.b #1
        bne +
        lda.b #241                          // don't let stuff wrap around from bottom
+;      inx
        sta.w MyOAM,x
        lda.w $0200,x                       // get tile number
        inx
        sta.w MyOAM,x
        lda.w $0200,x                       // get palette, flags
        and.b #$03                          // mask off all but the palette
        asl
        sta.b $00
        lda.w $0200,x
        and.b #$e0                          // mask off all but the v/h flip and priority flags
        eor.b #$20                          // invert priority flag
        ora.b $00                           // put the shifted palette in
        inx
        sta.w MyOAM,x
        lda.w $0200,x                       // get X coordinate
        dex
        dex
        dex
        sta.w MyOAM,x
        inx                                 // move to next sprite in OAM
        inx
        inx
        inx
        bne .oam_loop

        SetM16()
        pla
        rti


MapTbl:
        dw Level1Map                        // level 1
        dw TitleScreenMap                   // unused
        dw Level2Map                        // level 2
        dw Level3Map                        // level 3
        dw TitleScreenMap                   // title screen

// Same order as above
PalTbl:
        dw Level1Pal
        dw TitleScreenPal
        dw Level2Pal
        dw Level3Pal
        dw TitleScreenPal

TitleScreenMap:
        insert "title.map"
constant TitleScreenMapSize(pc() - TitleScreenMap)

TitleScreenPal:
        include "titlepal.asm"
constant TitleScreenPalSize(pc() - TitleScreenPal)

Level1Map:
        insert "level1.map"
constant Level1MapSize(pc() - Level1Map)

Level1Pal:
        include "level1pal.asm"
constant Level1PalSize(pc() - Level1Pal)

Level2Map:
        insert "level2.map"
constant Level2MapSize(pc() - Level2Map)

Level2Pal:
        include "level2pal.asm"
constant Level2PalSize(pc() - Level2Pal)

Level3Map:
        insert "level3.map"
constant Level3MapSize(pc() - Level1Map)

Level3Pal:
        include "level3pal.asm"
constant Level3PalSize(pc() - Level3Pal)


BlueFireballPal:
        include "blue_fireball_pal.asm"
constant BlueFireballPalSize(pc() - BlueFireballPal)


assert(origin() <= $c000)
origin $c000

// By sheer coincidence, origin will match the original CPU space locations

// Copy the PRG from the original game
insert "../original.nes", 16, $4000


// These were all originally STA PPUCTRL
origin $c7dc
        jsr SetPPUCTRL

origin $c7e9
        jsr SetPPUCTRL

origin $c864
        jsr SetPPUCTRL

origin $c8ec
        jsr SetPPUCTRL

origin $f1bb
        jsr SetPPUCTRL

origin $f202
        jsr SetPPUCTRL


// These were all originally STA PPUMASK
origin $c7f0
        jsr SetPPUMASK

origin $c88d
        jsr SetPPUMASK

origin $d19e
        jsr SetPPUMASK


// These were originally reads from PPUSTATUS
origin $f1b4
        lda.w RDNMI

origin $f228
        ldx.w RDNMI


// These originally wrote to PPUADDR
origin $f1ec
        sta.w VMADDH

origin $f1f2
        sta.w VMADDL


// This code prepares the display list when DK falls
origin $cd82
        jmp DKFalls


// This code makes fireballs blue (might make other display list changes too)
origin $d89a
        jmp MakeFireballsBlue


// This has to do with making fireballs red (but seems to be called at other times too)
origin $d7f2
        jmp MakeFireballsRed


// Misc. patches
origin $c807
        jmp LoadGfx

origin $c8f2
        rts                                 // changed from RTI

origin $f211
        jmp CopyOrFillVramLoop


// Clear nametable
// Can't find a correct way to do a 16-bit fill with DMA
origin $f1be
        SetMXY16()
        lda.w #$2000
        sta.w VMADDL
        lda.w #$0024
        ldx.w #0
-;      sta.w VMDATAL
        inx
        cpx.w #32*30
        bne -
        SetMXY8()
        rts
assert(origin() <= $f1ec)

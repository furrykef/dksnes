// Written for bass v14
// Note: $00 and $01 can freely be used for temp variables in some code
arch snes.cpu

include "snes.inc"

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
        stx DMAP0+{channel}*$10
        ldx.b #{dest_reg}
        stx BBAD0+{channel}*$10
        lda.w #{src_addr}
        sta A1T0L+{channel}*$10
        ldx.b #{src_addr} >> 16
        stx A1B0+{channel}*$10
        lda.w #{size}
        sta DAS0L+{channel}*$10
}


constant MyRAM(0x0800)

constant MyOAM(MyRAM)                       // 256 bytes (we're only using half of the low table)


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
        lda #0
        tcd
        ldx #$01ff
        txs
        sep #$30    // X,Y,A are 8 bit numbers
        lda #$8F    // screen off, full brightness
        sta $2100   // brightness + screen enable register
        stz $2101   // Sprite register (size + address in VRAM)
        stz $2102   // Sprite registers (address of sprite memory [OAM])
        stz $2103   //    ""                       ""
        stz $2105   // Mode 0, = Graphic mode register
        stz $2106   // noplanes, no mosaic, = Mosaic register
        stz $2107   // Plane 0 map VRAM location
        stz $2108   // Plane 1 map VRAM location
        stz $2109   // Plane 2 map VRAM location
        stz $210A   // Plane 3 map VRAM location
        stz $210B   // Plane 0+1 Tile data location
        stz $210C   // Plane 2+3 Tile data location
        stz $210D   // Plane 0 scroll x (first 8 bits)
        stz $210D   // Plane 0 scroll x (last 3 bits) #$0 - #$07ff
        lda #$FF    // The top pixel drawn on the screen isn't the top one in the tilemap, it's the one above that.
        sta $210E   // Plane 0 scroll y (first 8 bits)
        sta $2110   // Plane 1 scroll y (first 8 bits)
        sta $2112   // Plane 2 scroll y (first 8 bits)
        sta $2114   // Plane 3 scroll y (first 8 bits)
        lda #$07    // Since this could get quite annoying, it's better to edit the scrolling registers to fix this.
        sta $210E   // Plane 0 scroll y (last 3 bits) #$0 - #$07ff
        sta $2110   // Plane 1 scroll y (last 3 bits) #$0 - #$07ff
        sta $2112   // Plane 2 scroll y (last 3 bits) #$0 - #$07ff
        sta $2114   // Plane 3 scroll y (last 3 bits) #$0 - #$07ff
        stz $210F   // Plane 1 scroll x (first 8 bits)
        stz $210F   // Plane 1 scroll x (last 3 bits) #$0 - #$07ff
        stz $2111   // Plane 2 scroll x (first 8 bits)
        stz $2111   // Plane 2 scroll x (last 3 bits) #$0 - #$07ff
        stz $2113   // Plane 3 scroll x (first 8 bits)
        stz $2113   // Plane 3 scroll x (last 3 bits) #$0 - #$07ff
        lda #$80    // increase VRAM address after writing to $2119
        sta $2115   // VRAM address increment register
        stz $2116   // VRAM address low
        stz $2117   // VRAM address high
        stz $211A   // Initial Mode 7 setting register
        stz $211B   // Mode 7 matrix parameter A register (low)
        lda #$01
        sta $211B   // Mode 7 matrix parameter A register (high)
        stz $211C   // Mode 7 matrix parameter B register (low)
        stz $211C   // Mode 7 matrix parameter B register (high)
        stz $211D   // Mode 7 matrix parameter C register (low)
        stz $211D   // Mode 7 matrix parameter C register (high)
        stz $211E   // Mode 7 matrix parameter D register (low)
        sta $211E   // Mode 7 matrix parameter D register (high)
        stz $211F   // Mode 7 center position X register (low)
        stz $211F   // Mode 7 center position X register (high)
        stz $2120   // Mode 7 center position Y register (low)
        stz $2120   // Mode 7 center position Y register (high)
        stz $2121   // Color number register ($0-ff)
        stz $2123   // BG1 & BG2 Window mask setting register
        stz $2124   // BG3 & BG4 Window mask setting register
        stz $2125   // OBJ & Color Window mask setting register
        stz $2126   // Window 1 left position register
        stz $2127   // Window 2 left position register
        stz $2128   // Window 3 left position register
        stz $2129   // Window 4 left position register
        stz $212A   // BG1, BG2, BG3, BG4 Window Logic register
        stz $212B   // OBJ, Color Window Logic Register (or,and,xor,xnor)
        sta $212C   // Main Screen designation (planes, sprites enable)
        stz $212D   // Sub Screen designation
        stz $212E   // Window mask for Main Screen
        stz $212F   // Window mask for Sub Screen
        lda #$30
        sta $2130   // Color addition & screen addition init setting
        stz $2131   // Add/Sub sub designation for screen, sprite, color
        lda #$E0
        sta $2132   // color data for addition/subtraction
        stz $2133   // Screen setting (interlace x,y/enable SFX data)
        stz $4200   // Enable V-blank, interrupt, Joypad register
        lda #$FF
        sta $4201   // Programmable I/O port
        stz $4202   // Multiplicand A
        stz $4203   // Multiplier B
        stz $4204   // Multiplier C
        stz $4205   // Multiplicand C
        stz $4206   // Divisor B
        stz $4207   // Horizontal Count Timer
        stz $4208   // Horizontal Count Timer MSB (most significant bit)
        stz $4209   // Vertical Count Timer
        stz $420A   // Vertical Count Timer MSB
        stz $420B   // General DMA enable (bits 0-7)
        stz $420C   // Horizontal DMA (HDMA) enable (bits 0-7)
        lda #$01
        sta $420D   // Access cycle designation (slow/fast rom)

        // *** init video ***
        // display and NMI are off when we get here

        SetM16()

        // Clear VRAM
        stz VMADDL
        PrepDma(0, DMA_FILL8_16, VMDATAL, Zero, 0)
        ldx.b #$01
        stx MDMAEN

        // Transfer CHR to VRAM $0000
        stz VMADDL
        PrepDma(0, DMA_XFER16, VMDATAL, ChrData, ChrDataSize)
        ldx.b #$01
        stx MDMAEN

        // Init OAM, low and high tables
        stz OAMADDL
        PrepDma(0, DMA_FILL8_8, OAMDATA, ByteD240, 512)
        PrepDma(1, DMA_FILL8_8, OAMDATA, Zero, 32)
        ldx.b #$03
        stx MDMAEN

        SetM8()

        // Set video mode
        lda.b #$01                          // Mode 1, 8x8 tiles
        sta BGMODE
        sta BG12NBA                         // BG1 CHR at $1000
        lda.b #$11                          // BG1 and sprites visible
        sta TM
        stz TS                              // no subscreen
        lda.b #$20                          // BG1 nametable at $2000, 32x32
        sta BG1SC

        // Sprite nametable address will already be $0000, which is correct

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
        bne +
        ldx.b #$81                          // Set 32-word increment if not
+;      stx VMAIN
        and.b #$80                          // Mask off everything but NMI enable flag
        sta NMITIMEN
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
+;      stx INIDISP
        plx
        pla
        rts


// In:
//  A = 0 for level 1
//      2 is unused (pie factory leftover?)
//      4 for level 2
//      6 for level 3
//      8 for title screen
//      A for HUD
// Out:
//  X = PPUSTATUS (we'll ignore this)
//
// Registers can be clobbered
LoadGfx:
        cmp.b #$0a
        bcs .end
        tay
        lda.b #$80                          // Ensure VRAM increment is 1
        sta VMAIN
        stz CGADD
        SetM16()
        lda.w #$2000
        sta VMADDL
        ldx.b #DMA_XFER16
        stx DMAP0
        ldx.b #VMDATAL
        stx BBAD0
        lda GfxTbl,y
        sta A1T0L
        ldx.b #TitleScreenMap >> 16
        stx A1B0
        lda.w #TitleScreenMapSize
        sta DAS0L
        PrepDma(1, DMA_XFER8, CGDATA, TitleScreenPal, TitleScreenPalSize)
        ldx.b #$03
        stx MDMAEN
        SetM8()
.end:
        rts


// We don't have to worry about preserving X or Y here
HandleVblankImpl:
        SetM16()
        pha

        // Copy sprites from last frame to OAM
        stz OAMADDL
        PrepDma(0, DMA_XFER8, OAMDATA, MyOAM, 256)
        ldx #$01
        stx MDMAEN

        SetM8()
        jsr $c85f                           // run original vblank routine

        // Convert NES version's OAM to our OAM
        // @TODO@ -- ignores sprite priority
        // @TODO@ -- rather slow. Fine like this?
        SetM8()
        ldx.b #$00
.oam_loop:
        lda $0200,x                         // get Y coordinate
        clc
        adc.b #1
        inx
        sta MyOAM,x
        lda $0200,x                         // get tile number
        inx
        sta MyOAM,x
        lda $0200,x                         // get palette, flags
        and.b #$03                          // mask off all but the palette
        asl
        sta $00
        lda $0200,x
        and.b #$c0                          // mask off all but the v/h flip flags
        ora $00                             // put the shifted palette in
        inx
        sta MyOAM,x
        lda $0200,x                         // get X coordinate
        dex
        dex
        dex
        sta MyOAM,x
        inx                                 // move to next sprite in OAM
        inx
        inx
        inx
        bne .oam_loop

        SetM16()
        pla
        rti


GfxTbl:
        dw Level1Map                        // level 1
        dw TitleScreenMap                   // unused
        dw Level2Map                        // level 2
        dw Level3Map                        // level 3
        dw TitleScreenMap                   // title screen

TitleScreenMap:
        insert "title.map"
constant TitleScreenMapSize(pc() - TitleScreenMap)

TitleScreenPal:
        insert "title.pal"
constant TitleScreenPalSize(pc() - TitleScreenPal)

Level1Map:
        insert "level1.map"
constant Level1MapSize(pc() - Level1Map)

Level2Map:
        insert "level2.map"
constant Level2MapSize(pc() - Level2Map)

Level3Map:
        insert "level3.map"
constant Level3MapSize(pc() - Level1Map)


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


// These were originally reds from PPUSTATUS
origin $f1b4
        lda RDNMI

origin $f228
        ldx RDNMI


origin $c807
        jmp LoadGfx

origin $c8f2
        rts                                 // changed from RTI

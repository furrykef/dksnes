constant FLAG_XY8($10)
constant FLAG_M8($20)

macro SetM8() {
    sep #FLAG_M8
}

macro SetM16() {
    rep #FLAG_M8
}

macro SetXY8() {
    sep #FLAG_XY8
}

macro SetXY16() {
    rep #FLAG_XY8
}

macro SetMXY16() {
    rep #FLAG_M8 | FLAG_XY8
}


// Joypad bit numbers
constant JOY_R(1 << 4)
constant JOY_L(1 << 5)
constant JOY_X(1 << 6)
constant JOY_A(1 << 7)
constant JOY_RIGHT(1 << 8)
constant JOY_LEFT(1 << 9)
constant JOY_DOWN(1 << 10)
constant JOY_UP(1 << 11)
constant JOY_START(1 << 12)
constant JOY_SELECT(1 << 13)
constant JOY_Y(1 << 14)
constant JOY_B(1 << 15)


// Taken from MAME's snes.h and ASM-ified

// Definitions for PPU Memory-Mapped registers
constant INIDISP($2100)
constant OBSEL($2101)
constant OAMADDL($2102)
constant OAMADDH($2103)
constant OAMDATA($2104)
constant BGMODE($2105) // abcdefff(abcd: bg4-1 tile size | e: BG3 high priority | f: mode 
constant MOSAIC($2106)  // xxxxabcd(x: pixel size | abcd: affects bg 1-4 
constant BG1SC($2107)
constant BG2SC($2108)
constant BG3SC($2109)
constant BG4SC($210A)
constant BG12NBA($210B)
constant BG34NBA($210C)
constant BG1HOFS($210D)
constant BG1VOFS($210E)
constant BG2HOFS($210F)
constant BG2VOFS($2110)
constant BG3HOFS($2111)
constant BG3VOFS($2112)
constant BG4HOFS($2113)
constant BG4VOFS($2114)
constant VMAIN($2115) // i---ffrr(i: Increment timing | f: Full graphic | r: increment rate 
constant VMADDL($2116)  // aaaaaaaa(a: LSB of vram address 
constant VMADDH($2117)  // aaaaaaaa(a: MSB of vram address 
constant VMDATAL($2118)  // dddddddd(d: data to be written 
constant VMDATAH($2119)  // dddddddd(d: data to be written 
constant M7SEL($211A)  // ab----yx(a: screen over | y: vertical flip | x: horizontal flip 
constant M7A($211B)  // aaaaaaaa(a: COSINE rotate angle / X expansion 
constant M7B($211C)  // aaaaaaaa(a: SINE rotate angle / X expansion 
constant M7C($211D)  // aaaaaaaa(a: SINE rotate angle / Y expansion 
constant M7D($211E)  // aaaaaaaa(a: COSINE rotate angle / Y expansion 
constant M7X($211F)
constant M7Y($2120)
constant CGADD($2121)
constant CGDATA($2122)
constant W12SEL($2123)
constant W34SEL($2124)
constant WOBJSEL($2125)
constant WH0($2126)  // pppppppp(p: Left position of window 1 
constant WH1($2127)  // pppppppp(p: Right position of window 1 
constant WH2($2128)  // pppppppp(p: Left position of window 2 
constant WH3($2129)  // pppppppp(p: Right position of window 2 
constant WBGLOG($212A)  // aabbccdd(a: BG4 params | b: BG3 params | c: BG2 params | d: BG1 params 
constant WOBJLOG($212B)  // ----ccoo(c: Colour window params | o: Object window params 
constant TM($212C)
constant TS($212D)
constant TMW($212E)
constant TSW($212F)
constant CGWSEL($2130)
constant CGADSUB($2131)
constant COLDATA($2132)
constant SETINI($2133)
constant MPYL($2134)
constant MPYM($2135)
constant MPYH($2136)
constant SLHV($2137)
constant ROAMDATA($2138)
constant RVMDATAL($2139)
constant RVMDATAH($213A)
constant RCGDATA($213B)
constant OPHCT($213C)
constant OPVCT($213D)
constant STAT77($213E)
constant STAT78($213F)
constant APU00($2140)
constant APU01($2141)
constant APU02($2142)
constant APU03($2143)
constant WMDATA($2180)
constant WMADDL($2181)
constant WMADDM($2182)
constant WMADDH($2183)

// Definitions for CPU Memory-Mapped registers
constant OLDJOY1($4016)
constant OLDJOY2($4017)
constant NMITIMEN($4200)
constant WRIO($4201)
constant WRMPYA($4202)
constant WRMPYB($4203)
constant WRDIVL($4204)
constant WRDIVH($4205)
constant WRDVDD($4206)
constant HTIMEL($4207)
constant HTIMEH($4208)
constant VTIMEL($4209)
constant VTIMEH($420A)
constant MDMAEN($420B)
constant HDMAEN($420C)
constant MEMSEL($420D)
constant RDNMI($4210)
constant TIMEUP($4211)
constant HVBJOY($4212)
constant RDIO($4213)
constant RDDIVL($4214)
constant RDDIVH($4215)
constant RDMPYL($4216)
constant RDMPYH($4217)
constant JOY1L($4218)
constant JOY1H($4219)
constant JOY2L($421A)
constant JOY2H($421B)
constant JOY3L($421C)
constant JOY3H($421D)
constant JOY4L($421E)
constant JOY4H($421F)

// DMA
constant DMAP0($4300)
constant BBAD0($4301)
constant A1T0L($4302)
constant A1T0H($4303)
constant A1B0($4304)
constant DAS0L($4305)
constant DAS0H($4306)
constant DSAB0($4307)
constant A2A0L($4308)
constant A2A0H($4309)
constant NTRL0($430A)
constant DMAP1($4310)
constant BBAD1($4311)
constant A1T1L($4312)
constant A1T1H($4313)
constant A1B1($4314)
constant DAS1L($4315)
constant DAS1H($4316)
constant DSAB1($4317)
constant A2A1L($4318)
constant A2A1H($4319)
constant NTRL1($431A)
constant DMAP2($4320)
constant BBAD2($4321)
constant A1T2L($4322)
constant A1T2H($4323)
constant A1B2($4324)
constant DAS2L($4325)
constant DAS2H($4326)
constant DSAB2($4327)
constant A2A2L($4328)
constant A2A2H($4329)
constant NTRL2($432A)
constant DMAP3($4330)
constant BBAD3($4331)
constant A1T3L($4332)
constant A1T3H($4333)
constant A1B3($4334)
constant DAS3L($4335)
constant DAS3H($4336)
constant DSAB3($4337)
constant A2A3L($4338)
constant A2A3H($4339)
constant NTRL3($433A)
constant DMAP4($4340)
constant BBAD4($4341)
constant A1T4L($4342)
constant A1T4H($4343)
constant A1B4($4344)
constant DAS4L($4345)
constant DAS4H($4346)
constant DSAB4($4347)
constant A2A4L($4348)
constant A2A4H($4349)
constant NTRL4($434A)
constant DMAP5($4350)
constant BBAD5($4351)
constant A1T5L($4352)
constant A1T5H($4353)
constant A1B5($4354)
constant DAS5L($4355)
constant DAS5H($4356)
constant DSAB5($4357)
constant A2A5L($4358)
constant A2A5H($4359)
constant NTRL5($435A)
constant DMAP6($4360)
constant BBAD6($4361)
constant A1T6L($4362)
constant A1T6H($4363)
constant A1B6($4364)
constant DAS6L($4365)
constant DAS6H($4366)
constant DSAB6($4367)
constant A2A6L($4368)
constant A2A6H($4369)
constant NTRL6($436A)
constant DMAP7($4370)
constant BBAD7($4371)
constant A1T7L($4372)
constant A1T7H($4373)
constant A1B7($4374)
constant DAS7L($4375)
constant DAS7H($4376)
constant DSAB7($4377)
constant A2A7L($4378)
constant A2A7H($4379)
constant NTRL7($437A)

#!/usr/bin/env python
# NB: This tool and format ended up not being used.
#
# Rips display list from the NES ROM and converts it to our own format
# (Really the only "conversion" done is changing addresses to little-
#  endian and changing 8-bit values to 16-bit values; the rest will have
#  to be cleaned up by hand)
# Offsets are in CPU space, not file or ROM space
# Written for Python 3.4
import argparse
import sys

def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    args = get_args(argv)
    offset = int(args.offset, 16) - 0xc000 + 16
    with open(args.rom, 'rb') as rom:
        rom.seek(offset)
        with open(args.outfile, 'w') as outfile:
            while True:
                addr_h = rom.read(1)[0]
                if addr_h == 0:
                    # End of display list
                    outfile.write("    db 0\n")
                    break
                addr_l = rom.read(1)[0]
                addr = addr_h << 8 | addr_l
                outfile.write("    dw ${:04X}\n".format(addr))
                size = rom.read(1)[0]
                outfile.write("    db ${:02X}\n".format(size))
                if size & 0x40:
                    # Fill mode
                    data = rom.read(1)
                else:
                    # Copy mode
                    data = rom.read(size & 0x3f)
                data_str = ",".join("${:04X}".format(x) for x in data)
                outfile.write("    dw " + data_str + "\n\n")


def get_args(argv):
    parser = argparse.ArgumentParser(
        prog="riplvl",
        description="Rips screen data from the NES ROM and converts it "
                    "to our own format.",
        epilog="Offsets are in NES CPU space, not file or ROM space."
    )
    parser.add_argument('rom')
    parser.add_argument('offset')
    parser.add_argument('outfile')
    return parser.parse_args(argv)


if __name__ == '__main__':
    sys.exit(main())

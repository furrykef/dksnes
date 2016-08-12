#!/usr/bin/env python
# Converts graphics from 2 BPP NES format to 4 BPP SNES format.
# Written for Python 3.4
import argparse
import sys

def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    args = get_args(argv)
    with open(args.src, 'rb') as infile:
        with open(args.dest, 'wb') as outfile:
            while True:
                bitplane0 = infile.read(8)
                if len(bitplane0) == 0:
                    # EOF
                    break
                bitplane1 = infile.read(8)
                for b0, b1 in zip(bitplane0, bitplane1):
                    outfile.write(bytes([b0]))
                    outfile.write(bytes([b1]))
                # Comment out this line to get 2 BPP SNES format
                outfile.write(b'\0' * 16)


def get_args(argv):
    parser = argparse.ArgumentParser(
        prog="nes2snes",
        description="Converts graphics from 2 BPP NES format to 4 BPP "
                    "SNES format."
    )
    parser.add_argument('src')
    parser.add_argument('dest')
    return parser.parse_args(argv)


if __name__ == '__main__':
    sys.exit(main())

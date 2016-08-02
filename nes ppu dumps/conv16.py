#!/usr/bin/python
# Very quick and dirty script to convert a file of 8-bit values to 16-bit ones
import sys

def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    infilename, outfilename = argv
    with open(infilename, 'rb') as infile:
        with open(outfilename, 'wb') as outfile:
            while True:
                byte = infile.read(1)
                if len(byte) == 0:
                    break
                outfile.write(byte)
                outfile.write(b'\0')


if __name__ == '__main__':
    main()

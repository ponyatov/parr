
import os, sys

## parser stub

class parser:
    def parse(src): pass

## system init

if __name__ == '__main__':
    for srcfile in sys.argv[1:]:
        with open(srcfile) as src:
            parser.parse(src.read())

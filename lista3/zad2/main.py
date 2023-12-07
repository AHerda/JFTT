from my_lex import MyLexer
from my_par import MyParser
import sys


def main():
    lexer = MyLexer()
    parser = MyParser()
    if len(sys.argv) == 1:
        while True:
            text = ""
            try:
                while True:
                    text += input()
                    text += "\n"
                    if not text.endswith('\\\n'):
                        break
                parser.parse(lexer.tokenize(text))
            except Exception as e:
                parser.restart()
    elif len(sys.argv) == 2:
        lines = open(sys.argv[1]).readlines()
        i = 0
        print(lines)
        while True:
            text = ""
            try:
                while True:
                    text += lines[i]
                    i += 1
                    if not text.endswith('\\\n'):
                        break
                print(text[:-1])
                parser.parse(lexer.tokenize(text))
            except Exception as e:
                parser.restart()
            if i >= len(lines):
                sys.exit(0)
    else:
        print("Zła liczba argumentów")


if __name__ == "__main__":
    main()

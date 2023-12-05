from my_lex import MyLexer
from my_par import MyParser


def main():
    lexer = MyLexer()
    parser = MyParser()
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


if __name__ == "__main__":
    main()

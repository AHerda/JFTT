from sly import Lexer

#GF = 1234577
class MyLexer(Lexer):
    tokens = { NUM, ADD, SUB, MUL ,DIV, MOD, POW, LPAR, RPAR, RESULT, END, ERR}

    ignore_comment_line = r'^\#(\\\n|.)*\n'
    ignore_tbc = r'\\\n'

    ignore = r' \t'

    # regex for tokens
    @_(r'\d+')
    def NUM(self, t):
        t.value = int(t.value)
        return t

    ADD = r'\+'
    SUB = r'\-'
    MUL = r'\*'
    DIV = r'\/'
    POW = r'\^'
    MOD = r'\%'
    LPAR = r'\('
    RPAR = r'\)'
    RESULT = r'\n'
    END = r'^exit'
    ERR = r'.'

    def error(self, t):
        pass


if __name__ == '__main__':
    data = '#fas\\\n65\nafsa\n'
    lexer = MyLexer()
    for token in lexer.tokenize(data):
        print(token)

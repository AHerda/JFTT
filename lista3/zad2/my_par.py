from sly import Parser
from my_lex import MyLexer
from sys import exit

GF = 1234577

def mod(a: int, mod: int):
    return (a % mod + mod) % mod

def extended_gcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, x, y = extended_gcd(b % a, a)
        return (g, y - (b // a) * x, x)

def mod_inverse(a, m):
    g, x, y = extended_gcd(a, m)
    if g != 1:
        return -1
    else:
        return mod(x, m)

def invert(num, m):
    return mod_inverse(num, m)

class MyParser(Parser):
    tokens = MyLexer.tokens
    rpn = ""

    def reset(self):
        self.rpn = ""

    precedence = (
        ('left', 'ADD', 'SUB'),
        ('left', 'MUL', 'DIV', 'MOD'),
        ('right', 'NEG'),
        ('nonassoc', 'POW')
    )

    # Grammar rules and actions
    @_('END')
    def line(self, p):
        self.reset()
        self.restart()
        exit(0)

    @_('expr RESULT')
    def line(self, p):
        print(self.rpn)
        print(f"\t= {p[0]}\n")
        self.reset()

    @_('')
    def line(self, p):
        self.reset()

    @_('error RESULT')
    def line(self, p):
        self.my_error()

    @_('NUM')
    def expr(self, p):
        self.rpn += f"{mod(p[0], GF)} "
        return mod(p[0], GF)

    @_('SUB expr %prec NEG')
    def expr(self, p):
        self.rpn += f"~ "
        return mod(-p[1], GF)

    @_('expr ADD expr')
    def expr(self, p):
        self.rpn += "+ "
        return mod(p[0] + p[2], GF)

    @_('expr SUB expr')
    def expr(self, p):
        self.rpn += "- "
        return mod(p[0] - p[2], GF)

    @_('expr MUL expr')
    def expr(self, p):
        self.rpn += "* "
        return mod(p[0] * p[2], GF)

    @_('expr DIV expr')
    def expr(self, p):
        if p[2] == 0:
            self.my_error("Dzielenie przez 0")
            raise Exception
        else:
            self.rpn += "/ "
            result = invert(p[2], GF)
            if result == -1:
                self.my_error(f"{p[2]} nie jest odwracalne modulo {GF}\n")
                raise Exception
            else:
                result = mod(result, GF)
                return mod(p[0] * result, GF)

    @_('expr POW exponent')
    def expr(self, p):
        self.rpn += "^ "
        result = 1
        for i in range(0, p[2]):
            result = mod(result * p[0], GF)
        return result

    @_('expr MOD expr')
    def expr(self, p):
        if p[2] == 0:
            self.my_error("Modulo 0")
            raise Exception
        else:
            self.rpn += "% "
            return mod(p[0] % p[2], GF)

    @_('LPAR expr RPAR')
    def expr(self, p):
        return p[1]

    @_('NUM')
    def exponent(self, p):
        self.rpn += f"{mod(p[0], GF - 1)} "
        return mod(p[0], GF - 1)

    @_('SUB exponent %prec NEG')
    def exponent(self, p):
        self.rpn += f"~ "
        return mod(-p[1], GF - 1)

    @_('exponent ADD exponent')
    def exponent(self, p):
        self.rpn += "+ "
        return mod(p[0] + p[2], GF - 1)

    @_('exponent SUB exponent')
    def exponent(self, p):
        self.rpn += "- "
        return mod(p[0] - p[2], GF - 1)

    @_('exponent MUL exponent')
    def exponent(self, p):
        self.rpn += "* "
        return mod(p[0] * p[2], GF - 1)

    @_('exponent DIV exponent')
    def exponent(self, p):
        if p[2] == 0:
            self.my_error("Dzielenie przez 0")
            raise Exception
        else:
            self.rpn += "/ "
            result = invert(p[2], GF - 1)
            if result == -1:
                self.my_error(f"{p[2]} nie jest odwracalne modulo {GF - 1}")
                raise Exception
            else:
                result = mod(result, GF - 1)
                return mod(p[0] * result, GF - 1)

    @_('exponent MOD exponent')
    def exponent(self, p):
        if p[2] == 0:
            self.my_error("Modulo 0")
            raise Exception
        else:
            self.rpn += "% "
            return mod(p[0] % p[2], GF - 1)

    @_('exponent POW exponent')
    def exponent(self, p):
        self.my_error("Składanie potęg")

    @_('LPAR exponent RPAR')
    def exponent(self, p):
        return p[1]

    def my_error(self, s="Zła składnia"):
        while True:
            token = next(self.tokens, None)
            if not token or token.type == 'RESULT':
                break
        print(f"Błąd: {s}\n")
        self.restart()
        self.reset()

    def error(self, p):
        self.my_error()

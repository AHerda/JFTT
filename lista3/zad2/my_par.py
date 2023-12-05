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
        ('nonassoc', 'POW'),
        ('left', 'ADD', 'SUB'),
        ('left', 'MUL', 'DIV', 'MOD'),
        ('right', 'NEG')
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
        print(f"Wynik:\t{p[0]}\n")
        self.reset()

    @_('')
    def line(self, p):
        self.reset()

    @_('error RESULT')
    def line(self, p):
        self.error("Zła składnia")

    @_('ERR')
    def expr(self, p):
        self.error("Zły znak")

    @_('NUM')
    def expr(self, p):
        self.rpn += f"{mod(p[0], GF)} "
        return mod(p[0], GF)

    @_('SUB NUM %prec NEG')
    def expr(self, p):
        self.rpn += f"{mod(-p[1], GF)} "
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
            self.error("Dzielenie przez 0")
            raise Exception
        else:
            self.rpn += "/ "
            result = invert(p[2], GF)
            if result == -1:
                self.error(f"{p[2]} nie jest odwracalne modulo {GF}\n")
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
            self.error("Modulo 0")
            raise Exception
        else:
            self.rpn += "% "
            return mod(p[0] % p[2], GF)

    @_('LPAR expr RPAR')
    def expr(self, p):
        return p[1]

    @_('SUB LPAR expr RPAR %prec NEG')
    def expr(self, p):
        self.rpn += "~ "
        return mod(-p[2], GF)

    @_('NUM')
    def exponent(self, p):
        self.rpn += f"{mod(p[0], GF - 1)} "
        return mod(p[0], GF - 1)

    @_('SUB NUM %prec NEG')
    def exponent(self, p):
        self.rpn += f"{mod(-p[1], GF - 1)} "
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
            self.error("Dzielenie przez 0")
            raise Exception
        else:
            self.rpn += "/ "
            result = invert(p[2], GF - 1)
            if result == -1:
                self.error(f"{p[2]} nie jest odwracalne modulo {GF - 1}")
                raise Exception
            else:
                result = mod(result, GF - 1)
                return mod(p[0] * result, GF - 1)

    @_('exponent POW exponent')
    def expr(self, p):
        self.error("Składanie potęg")
        raise Exception

    @_('exponent MOD exponent')
    def exponent(self, p):
        if p[2] == 0:
            self.error("Modulo 0")
            raise Exception
        else:
            self.rpn += "% "
            return mod(p[0] % p[2], GF - 1)

    @_('LPAR exponent RPAR')
    def exponent(self, p):
        return p[1]

    @_('SUB LPAR exponent RPAR %prec NEG')
    def exponent(self, p):
        self.rpn += "~ "
        return mod(-p[2], GF - 1)

    def error(self, s="Zła składnia"):
        while True:
            tok = next(self.tokens, None)
            if not tok or tok.type == 'RESULT':
                break
        print("Błąd: ", s)
        self.restart()
        self.reset()

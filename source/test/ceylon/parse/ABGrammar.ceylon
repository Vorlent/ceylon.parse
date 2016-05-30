import ceylon.parse { ... }
import ceylon.collection { ArrayList }

class S(Integer pos = 0, Sym* children) extends Sym(pos, *children) {}
class A(Integer pos = 0, Sym* children) extends Sym(pos, *children) {}
class B(Integer pos = 0, Sym* children) extends Sym(pos, *children) {}
class ATerm(Integer pos = 0, shared actual Object? prevError = null) extends Sym(pos) {}
class BTerm(Integer pos = 0, shared actual Object? prevError = null) extends Sym(pos) {}
class ATermError(Object? replaces = null, Integer pos = 0)
        extends ATerm(pos) {
    shared actual String shortName {
        if (! replaces exists) { return super.shortName + "(Missing 'a')"; }

        if (is Crap replaces) {
            return "``super.shortName``(Bad token: '``replaces.data``')";
        } else {
            assert(exists replaces);
            return "``super.shortName``(Replaced: '``replaces``')";
        }
    }
}

class Spc(Integer pos = 0, shared actual Object? prevError = null) extends Sym(pos) {}
class MulA(Integer pos = 0, Sym* children) extends Sym(pos, *children) {}
class MMulA(Integer pos = 0, Sym* children) extends Sym(pos, *children) {}
class ParenBox(Integer pos = 0, Sym* children) extends Sym(pos, *children) {}

{Token<Object> *} tokenizeAB(String s, Integer pos, Atom k) {
    value results = ArrayList<Token<Object>>();

    if (eosAtom.subtypeOf(k),
        s.size <= pos) {
        object q satisfies ABGrammarToken<EOS>&EOSToken {
            shared actual String str = s;
            shared actual Integer position => pos;
        }
        results.add(q);
    }

    if (Atom(`ATerm`).subtypeOf(k),
        exists chr = s[pos],
        chr == 'a') {
        object q satisfies ABGrammarToken<ATerm> {
            shared actual String str = s;
            shared actual ATerm node => ATerm(pos);
            shared actual Integer position => pos + 1;
        }
        results.add(q);
    }

    if (Atom(`BTerm`).subtypeOf(k),
        exists chr = s[pos],
        chr == 'b') {
        object q satisfies ABGrammarToken<BTerm> {
            shared actual String str = s;
            shared actual BTerm node => BTerm(pos);
            shared actual Integer position => pos + 1;
        }
        results.add(q);
    }

    return results;
}

{Token<Object> *} forceTokenizeAB(String s, Integer pos, Atom k) {
    value results = ArrayList<Token<Object>>();
    if (eosAtom.subtypeOf(k)) {
        object q satisfies ABGrammarToken<EOS>&EOSToken {
            shared actual String str = s;
            shared actual Integer position = s.size;
            shared actual Integer lsd = s.size - pos;
        }
        results.add(q);
    }

    if (Atom(`ATerm`).subtypeOf(k)) {

        object q satisfies ABGrammarToken<ATerm> {
            shared actual String str = s;
            shared actual ATerm node => ATermError(null, pos);
            shared actual Integer position = pos;
            shared actual Integer lsd = 1;
        }
        results.add(q);

        object r satisfies ABGrammarToken<ATerm> {
            shared actual String str = s;
            shared actual ATerm node => ATermError(Crap(s[pos:1]), pos);
            shared actual Integer position = pos + 1;
            shared actual Integer lsd = 1;
        }

        if (s.longerThan(pos)) {
            results.add(r);
        }

        if (exists chr = s[pos + 1],
            chr == 'a') {

            object t satisfies ABGrammarToken<ATerm> {
                shared actual String str = s;
                shared actual ATerm node => ATerm(pos + 1, Crap(s[pos:1], pos));
                shared actual Integer position = pos + 2;
                shared actual Integer lsd = 1;
            }
            results.add(t);
        }
    }

    return results;
}

interface ABGrammarToken<T>
        satisfies Token<T>
        given T satisfies Object {
    shared formal String str;
    shared actual {Token<Object> *} next(Atom k)
        => tokenizeAB(str, position, k);
    shared actual {Token<Object> *} forceNext(Atom k) =>
        forceTokenizeAB(str, position, k);
}

class ABStartToken(shared actual String str)
        satisfies SOSToken&ABGrammarToken<SOS> {}

import ceylon.ast.core {
	Node
}
import ceylon.language.meta {

	type
}
import ceylon.parse {

	GrammarRule
}
void parse(String source) {
	value tokenizer = Tokenizer(source);
	value result = ceylonGrammar.parse<Node>(tokenizer).first;
}

shared void run() {
	value s1 = system.milliseconds;
	type(ceylonGrammar).getDeclaredMethods<Nothing, Object, Nothing>(`GrammarRule`);
	value s2 = system.milliseconds;
	print(s2-s1);
}
#include "temu.h"

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <sys/types.h>
#include <regex.h>

enum {
	NOTYPE = 256, 				  // Space
	DEC, HEX, REG,				  // Operand
	EQ, NEQ, AND, OR,             // Binary operator
	POS, NEG, DEREF, NOT,         // Unary operator

	/* TODO: Add more token types */

};

static struct rule {
	char *regex;
	int token_type;
} rules[] = {

	/* TODO: Add more rules.
	 * Pay attention to the precedence level of different rules.
	 */

	{" +",	NOTYPE},				// spaces

	// operator                        name                priority 
	{"\\(", '('},                   // left bracket        1
	{"\\)", ')'},                   // right bracket
	{"\\*", '*'},                   // multiply            3
	{"\\/", '/'},                   // divide 
	{"\\+", '+'},					// plus                4
	{"\\-", '-'},                   // minus
	{"==", EQ},						// equal               6
	{"!=", NEQ},                    // not equal
	{"&&", AND},                    // and                 11
	{"\\|\\|", OR},                 // or
	{"!", NOT},                     // not

	// operand
	{"0x[0-9a-fA-F]+", HEX},        // hexadecimal number
	{"[0-9]+", DEC},                // decimal number
	{"\\$[A-Za-z0-9]+", REG},       // register
};

#define NR_REGEX (sizeof(rules) / sizeof(rules[0]) )

static regex_t re[NR_REGEX];

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
	int i;
	char error_msg[128];
	int ret;

	for(i = 0; i < NR_REGEX; i ++) {
		ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
		if(ret != 0) {
			regerror(ret, &re[i], error_msg, 128);
			Assert(ret == 0, "regex compilation failed: %s\n%s", error_msg, rules[i].regex);
		}
	}
}

typedef struct token {
	int type;
	char str[32];
} Token;

Token tokens[32];
int nr_token;

static bool make_token(char *e) {
	int position = 0;
	int i;
	regmatch_t pmatch;
	
	nr_token = 0;

	while(e[position] != '\0') {
		/* Try all rules one by one. */
		for(i = 0; i < NR_REGEX; i ++) {
			if(regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
				char *substr_start = e + position;
				int substr_len = pmatch.rm_eo;

//				Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s", i, rules[i].regex, position, substr_len, substr_len, substr_start);
				position += substr_len;

				/* TODO: Now a new token is recognized with rules[i]. Add codes
				 * to record the token in the array `tokens'. For certain types
				 * of tokens, some extra actions should be performed.
				 */

				tokens[nr_token].type = rules[i].token_type;
				strncpy(tokens[nr_token].str, substr_start, substr_len);
				tokens[nr_token].str[substr_len] = '\0';
//				Log("token[%d].str = %s", nr_token, tokens[nr_token].str);
				nr_token++;

				break;
			}
		}

		if(i == NR_REGEX) {
			printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
			return false;
		}
	}

	return true; 
}

// stack for brackets matching
int stack[32], top = -1;
// brackets matching result
int match[32];

// check if the operator is unary
bool is_unary(int i)
{
	if(i == 0 || tokens[i - 1].type == '(' || tokens[i - 1].type == '+' || tokens[i - 1].type == '-' || tokens[i - 1].type == '*' || tokens[i - 1].type == '/' 
		|| tokens[i - 1].type == EQ || tokens[i - 1].type == NEQ || tokens[i - 1].type == AND || tokens[i - 1].type == OR 
		|| tokens[i - 1].type == NOT || tokens[i - 1].type == DEREF || tokens[i - 1].type == POS || tokens[i - 1].type == NEG)
	{
		return true;
	}
	return false;
}
uint32_t eval(int p, int q, bool *success)
{
	if(p > q)
	{
		// Bad expression
		*success &= false;
		return 0;
	}
	else if(p == q)
	{
		// Single token
		uint32_t num;
		if(tokens[p].type == DEC)
		{
			sscanf(tokens[p].str, "%u", &num);
		}
		else if(tokens[p].type == HEX)
		{
			if(tokens[p].str != NULL)
				Log("hex found: %s", tokens[p].str);
			sscanf(tokens[p].str, "%x", &num);
		}
		else if(tokens[p].type == REG)
		{
			// Register
			if(tokens[p].str != NULL)
				Log("reg found: %s", tokens[p].str);
			int i;
			for(i = 0; i < 32; i++)
			{
				if(strcmp(tokens[p].str, regfile[i]) == 0)
				{
					num = reg_w(i);
					break;
				}
			}
			if(i == 32)
			{
				// Bad expression
				*success &= false;
				num = 0;
			}
		}
		else
		{
			// Bad expression
			*success &= false;
			num = 0;
		}
		return num;
	}
	else if(tokens[p].type == '(' && tokens[q].type == ')' && match[p] == q)
	{
		// Remove the outermost brackets
		return eval(p + 1, q - 1, success);
	}
	else
	{
		// Find the dominant operator
		int mxpr = -1, mxi = p, cnt = 0, i;
		for(i = p; i <= q; ++i)
		{
			if(tokens[i].type == '(')
			{
				++cnt;
			}
			else if(tokens[i].type == ')')
			{
				--cnt;
			}
			else if(cnt == 0)
			{
				if(mxpr <= 11 && (tokens[i].type == AND || tokens[i].type == OR))
				{
					mxpr = 11;
					mxi = i;
				}
				else if(mxpr <= 6 && (tokens[i].type == EQ || tokens[i].type == NEQ))
				{
					mxpr = 6;
					mxi = i;
				}
				else if(mxpr <= 4 && (tokens[i].type == '+' || tokens[i].type == '-' ))
				{
					mxpr = 4;
					mxi = i;
				}
				else if(mxpr <= 3 && (tokens[i].type == '*' || tokens[i].type == '/'))
				{
					mxpr = 3;
					mxi = i;
				}
			}
		}

		if(mxpr == -1)
		{
			// Dominant operator not found
			if(is_unary(p))
			{
				// Unary operator
				uint32_t val = eval(p + 1, q, success);
				switch(tokens[p].type)
				{
					case POS: return val;
					case NEG: return -val;
					case DEREF: return mem_read(val, 4);
					case NOT: return !val;
				}
			}
			// Bad expression
			*success &= false;
			return 0;
		}

		// Calculate the value of the dominant operator
		uint32_t val1 = eval(p, mxi - 1, success);
		uint32_t val2 = eval(mxi + 1, q, success);
		switch(tokens[mxi].type)
		{
			case '+': return val1 + val2;
			case '-': return val1 - val2;
			case '*': return val1 * val2;
			case '/': return val1 / val2;
			case EQ: return val1 == val2;
			case NEQ: return val1 != val2;
			case AND: return val1 && val2;
			case OR: return val1 || val2;
			// Bad expression
			default: *success &= false; return 0;
		}
	}
}

uint32_t expr(char *e, bool *success) {
	if(!make_token(e)) {
		*success = false;
		return 0;
	}

	/* TODO: Insert codes to evaluate the expression. */
	int i;

	// Delete spaces
	for(i = 0; i < nr_token; i++)
	{
		if(tokens[i].type == NOTYPE)
		{
			int j;
			for(j = i; j < nr_token - 1; j++)
			{
				tokens[j] = tokens[j + 1];
			}
			nr_token--;
			i--;
		}
	}

	// Detect unary operator
	for(i = 0; i < nr_token; i++) if(is_unary(i))
	{
		switch (tokens[i].type)
		{
			case '+': tokens[i].type = POS; break;
			case '-': tokens[i].type = NEG; break;
			case '*': tokens[i].type = DEREF; break;
			case '!': tokens[i].type = NOT; break;
		}
	}

	// brackets matching
	top = -1;
	for(i = 0; i < nr_token; i++)
	{
		stack[i] = match[i] = -1;
	}
	for(i = 0; i < nr_token; i++)
	{
		if(tokens[i].type == '(')
		{
			stack[++top] = i;
		}
		else if(tokens[i].type == ')')
		{
			if(top == -1)
			{
				// Bad expression
				*success = false;
				return 0;
			}
			match[stack[top--]] = i;
		}
	}
	if(top != -1)
	{
		// Bad expression
		*success = false;
		return 0;
	}

	// Validate and calculate expression
	*success = true;
	return eval(0, nr_token - 1, success);
}


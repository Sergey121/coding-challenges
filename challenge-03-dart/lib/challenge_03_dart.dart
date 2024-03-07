enum TokenType {
  BraceOpen,
  BraceClose,
  BracketOpen,
  BracketClose,
  String,
  Number,
  Comma,
  Colon,
  True,
  False,
  Null,
}

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);
}

dynamic jsonParse(String content) {
  List<Token> tokens = _createTokens(content);

  if (tokens.isEmpty) {
    throw Exception('no tokens to parse.');
  }

  Token firstToken = tokens.first;

  if (firstToken.type != TokenType.BraceOpen &&
      firstToken.type != TokenType.BracketOpen) {
    throw Exception('Invalid token: ${firstToken.value}');
  }

  Token lastToken = tokens.last;

  if (lastToken.type != TokenType.BraceClose &&
      lastToken.type != TokenType.BracketClose) {
    throw Exception('Invalid token: ${lastToken.value}');
  }

  ASTNode ast = ASTNodeParser(tokens).parse();
  var res = _convertASTodeToValue(ast);

  return res;
}

dynamic _convertASTodeToValue(ASTNode node) {
  switch (node.type) {
    case ASTNodeType.Object:
      {
        ASTObjectNode object = node as ASTObjectNode;
        Map<String, dynamic> map = {};

        object.value.forEach((key, value) {
          map[key] = _convertASTodeToValue(value);
        });

        return map;
      }
    case ASTNodeType.Array:
      {
        ASTArrayNode array = node as ASTArrayNode;
        List<dynamic> list = [];

        array.value.forEach((element) {
          list.add(_convertASTodeToValue(element));
        });

        return list;
      }
    case ASTNodeType.String:
      {
        ASTStringNode string = node as ASTStringNode;
        return string.value;
      }
    case ASTNodeType.Number:
      {
        ASTNumberNode number = node as ASTNumberNode;
        return number.value;
      }
    case ASTNodeType.Boolean:
      {
        ASTBooleanNode boolean = node as ASTBooleanNode;
        return boolean.value;
      }
    case ASTNodeType.Null:
      {
        return null;
      }
  }
}

List<Token> _createTokens(String input) {
  List<Token> tokens = [];

  int position = 0;

  int numberOfOpenedAndClosedBraces = 0;
  int numberOfOpenedAndClosedBrackets = 0;

  try {
    while (position < input.length) {
      String char = input[position];

      if (char == '{') {
        tokens.add(Token(TokenType.BraceOpen, char));
        numberOfOpenedAndClosedBraces++;
        position++;
        continue;
      }

      if (char == '}') {
        tokens.add(Token(TokenType.BraceClose, char));
        numberOfOpenedAndClosedBraces--;
        position++;
        continue;
      }

      if (char == '[') {
        tokens.add(Token(TokenType.BracketOpen, char));
        numberOfOpenedAndClosedBrackets++;
        position++;
        continue;
      }

      if (char == ']') {
        tokens.add(Token(TokenType.BracketClose, char));
        numberOfOpenedAndClosedBrackets--;
        position++;
        continue;
      }

      if (char == ',') {
        tokens.add(Token(TokenType.Comma, char));
        position++;
        continue;
      }

      if (char == ':') {
        tokens.add(Token(TokenType.Colon, char));
        position++;
        continue;
      }

      if (char == '"') {
        String value = '';
        position += 1;
        if (position >= input.length) {
          break;
        }
        var next = input[position];

        while (next != '"') {
          value += next;

          if (next == '\t') {
            generateError('Unexpected tab character', position);
          }

          if (next == '\n') {
            generateError('Unexpected new line character', position);
          }

          position += 1;
          if (position >= input.length) {
            break;
          }
          next = input[position];

          if (next == '"' &&
              value[value.length - 1] == '\\' &&
              !(value.length >= 3 &&
                  value[value.length - 2] == '\\' &&
                  value[value.length - 3] != '\\')) {
            value = value.substring(0, value.length - 1);
            value += next;
            position += 1;
            if (position >= input.length) {
              break;
            }
            next = input[position];
          }
        }

        if (value.contains('\   ')) {
          generateError('Unexpected tab character', position);
        }

        // /(\\x[0-9A-Fa-f]{2})|(\\[0-7]{3})/g;
        var illegalEscapeRegex = RegExp(r'(\\x[0-9A-Fa-f]{2})|(\\[0-7]{3})');
        if (illegalEscapeRegex.hasMatch(value)) {
          generateError('Illegal escape character', position);
        }

        tokens.add(Token(TokenType.String, value));
        position++;
        continue;
      }

      if (RegExp(r'[-.\d\w]').hasMatch(char)) {
        var value = '';

        while (RegExp(r'[-+.\d\w]').hasMatch(char)) {
          value += char;
          position += 1;
          if (position >= input.length) {
            break;
          }
          char = input[position];
        }

        if (isNumber(value)) {
          if (RegExp(r'^-?0(\d|x)').hasMatch(value)) {
            generateError('Invalid number: $value', position);
          }
          tokens.add(Token(TokenType.Number, value));
        } else if (isBoleanTrue(value)) {
          tokens.add(Token(TokenType.True, value));
        } else if (isBoleanFalse(value)) {
          tokens.add(Token(TokenType.False, value));
        } else if (isNull(value)) {
          tokens.add(Token(TokenType.Null, value));
        } else {
          generateError('Invalid token: $value', position);
        }

        continue;
      }

      if (RegExp(r'\s').hasMatch(char)) {
        position++;
        continue;
      }

      generateError('Unexpected character: $char', position);
    }
  } on RangeError {
    print('Range error');
  }

  if (numberOfOpenedAndClosedBraces != 0) {
    generateError('Invalid number of braces', position);
  }

  if (numberOfOpenedAndClosedBrackets != 0) {
    generateError('Invalid number of brackets', position);
  }

  return tokens;
}

void generateError(String message, int position) {
  throw Exception('$message at position $position');
}

bool isNumber(String value) {
  return num.tryParse(value) != null;
}

bool isBoleanTrue(String value) {
  return value == 'true';
}

bool isBoleanFalse(String value) {
  return value == 'false';
}

bool isNull(String value) {
  return value == 'null';
}

enum ASTNodeType {
  Object,
  Array,
  String,
  Number,
  Boolean,
  Null,
}

abstract class ASTNode {
  ASTNodeType get type;
  dynamic get value;
}

class ASTObjectNode extends ASTNode {
  @override
  final ASTNodeType type = ASTNodeType.Object;
  @override
  final Map<String, ASTNode> value;

  ASTObjectNode(this.value);
}

class ASTArrayNode extends ASTNode {
  @override
  final ASTNodeType type = ASTNodeType.Array;
  @override
  final List<ASTNode> value;

  ASTArrayNode(this.value);
}

class ASTStringNode extends ASTNode {
  @override
  final ASTNodeType type = ASTNodeType.String;
  @override
  final String value;

  ASTStringNode(this.value);
}

class ASTNumberNode extends ASTNode {
  @override
  final ASTNodeType type = ASTNodeType.Number;
  @override
  final num value;

  ASTNumberNode(this.value);
}

class ASTBooleanNode extends ASTNode {
  @override
  final ASTNodeType type = ASTNodeType.Boolean;
  @override
  final bool value;

  ASTBooleanNode(this.value);
}

class ASTNullNode extends ASTNode {
  @override
  final ASTNodeType type = ASTNodeType.Null;
  @override
  final value = null;
}

class ASTNodeParser {
  final List<Token> tokens;
  int current = 0;

  ASTNodeParser(this.tokens);

  ASTNode parse() {
    return _parseValue(tokens);
  }

  Token _next(List<Token> tokens) {
    current++;
    return tokens[current];
  }

  ASTNode _parseValue(List<Token> tokens) {
    if (tokens.isEmpty) {
      throw Exception('No tokens to parse');
    }

    Token token = tokens[current];

    switch (token.type) {
      case TokenType.BraceOpen:
        {
          return _parseObject(tokens);
        }
      case TokenType.BracketOpen:
        {
          return _parseArray(tokens);
        }
      case TokenType.String:
        {
          return ASTStringNode(token.value);
        }
      case TokenType.Number:
        {
          try {
            return ASTNumberNode(num.parse(token.value));
          } catch (e) {
            throw Exception('Invalid number: ${token.value}');
          }
        }
      case TokenType.True:
        {
          return ASTBooleanNode(true);
        }
      case TokenType.False:
        {
          return ASTBooleanNode(false);
        }
      case TokenType.Null:
        {
          return ASTNullNode();
        }
      default:
        {
          throw Exception('Invalid token type: ${token.type}');
        }
    }
  }

  ASTArrayNode _parseArray(List<Token> tokens) {
    ASTArrayNode node = ASTArrayNode([]);

    Token token = _next(tokens);

    while (token.type != TokenType.BracketClose) {
      node.value.add(_parseValue(tokens));
      token = _next(tokens);

      if (token.type == TokenType.Comma) {
        token = _next(tokens);
        if (token.type == TokenType.BracketClose) {
          generateError('Unexpected token ${token.type} after comma', current);
        }
      }
    }

    return node;
  }

  ASTObjectNode _parseObject(List<Token> tokens) {
    ASTObjectNode object = ASTObjectNode({});

    Token token = _next(tokens);

    while (token.type != TokenType.BraceClose) {
      if (token.type == TokenType.String) {
        String key = token.value;
        token = _next(tokens);

        if (token.type == TokenType.Colon) {
          _next(tokens);
          object.value[key] = _parseValue(tokens);
          token = _next(tokens);
        } else {
          generateError('Invalid (expect colon) token ${token.type}', current);
        }

        if (token.type == TokenType.Comma) {
          token = _next(tokens);
          if (token.type == TokenType.BraceClose) {
            generateError(
                'Unexpected token ${token.type} after comma', current);
          }
        }
      } else {
        generateError('Invalid token type ${token.type}', current);
      }
    }

    return object;
  }
}

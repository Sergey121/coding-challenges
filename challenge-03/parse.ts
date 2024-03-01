import { ASTNode, Token } from './types';
import { isBooleanFalse, isBooleanTrue, isNull, isNumber } from './utils';

export const JSONParse = (input: string) => {
  const tokens = createTokens(input);

  if (!tokens.length) throw new Error('No tokens to parse');

  const firstType = tokens[0].type;

  if (firstType !== 'BraceOpen' && firstType !== 'BracketOpen') {
    throw new Error('Invalid token: ' + firstType);
  }

  const lstType = tokens[tokens.length - 1].type;
  if (lstType !== 'BraceClose' && lstType !== 'BracketClose') {
    throw new Error('Invalid token: ' + lstType);
  }

  const ast = createAST(tokens);
  return convertASTToValue(ast);
};

function convertASTToValue(node: ASTNode): any {
  switch (node.type) {
    case 'Object': {
      const obj: { [key: string]: any } = {};
      for (const key in node.value) {
        obj[key] = convertASTToValue(node.value[key]);
      }
      return obj;
    }
    case 'Array': {
      return node.value.map(convertASTToValue);
    }
    case 'String':
    case 'Number':
    case 'Boolean':
    case 'Null': {
      return node.value;
    }
  }
}

function generateError(message: string, position: number) {
  throw new Error(`${message} at position ${position}`);
}

const createTokens = (input: string): Token[] => {
  let position = 0;

  const tokens: Token[] = [];

  let numberOfOpenedAndClosedBraces = 0;
  let numberOfOpenedAndClosedBrackets = 0;

  while (position < input.length) {
    let char = input[position];

    if (char === '{') {
      tokens.push({ type: 'BraceOpen', value: char });
      position++;
      numberOfOpenedAndClosedBraces++;
      continue;
    }

    if (char === '}') {
      tokens.push({ type: 'BraceClose', value: char });
      position++;
      numberOfOpenedAndClosedBraces--;
      continue;
    }

    if (char === '[') {
      tokens.push({ type: 'BracketOpen', value: char });
      position++;
      numberOfOpenedAndClosedBrackets++;
      continue;
    }

    if (char === ']') {
      tokens.push({ type: 'BracketClose', value: char });
      position++;
      numberOfOpenedAndClosedBrackets--;
      continue;
    }

    if (char === ',') {
      tokens.push({ type: 'Comma', value: char });
      position++;
      continue;
    }

    if (char === ':') {
      tokens.push({ type: 'Colon', value: char });
      position++;
      continue;
    }

    if (char === '"') {
      let value = '';
      let next = input[++position];
      while (next !== '"') {
        value += next;

        if (next === '\t') {
          generateError('Unexpected tab character', position);
        }

        if (next === '\n') {
          generateError('Unexpected new line character', position);
        }

        next = input[++position];

        // check if the string is escaped like: "this is a \"string\"" or "\\\""
        if (
          next === '"' &&
          value[value.length - 1] === '\\' &&
          !(value[value.length - 2] === '\\' && value[value.length - 3] !== '\\')
        ) {
          next = input[++position];
        }
      }

      if (value.includes('\   ')) {
        generateError('Unexpected tab character', position);
      }

      const illegalEscapeRegex = /(\\x[0-9A-Fa-f]{2})|(\\[0-7]{3})/g;
      const hasIllegalEscape = illegalEscapeRegex.test(value);
      if (hasIllegalEscape) {
        generateError('Illegal escape sequence', position);
      }


      tokens.push({ type: 'String', value });
      position++;
      continue;
    }

    if (/[-.\d\w]/.test(char)) {
      let value = '';
      while (/[-+.\d\w]/.test(char)) {
        value += char;
        char = input[++position];
      }

      if (isNumber(value)) {
        if (/^-?0(\d|x)/.test(value)) {
          generateError(`Invalid number: ${value}`, position);
        }
        tokens.push({ type: 'Number', value });
      } else if (isBooleanTrue(value)) {
        tokens.push({ type: 'True', value });
      } else if (isBooleanFalse(value)) {
        tokens.push({ type: 'False', value });
      } else if (isNull(value)) {
        tokens.push({ type: 'Null', value });
      } else generateError('Unexpected value: ' + value, position);

      continue;
    }

    if (/\s/.test(char)) {
      position++;
      continue;
    }

    generateError(`Unexpected character "${char}"`, position);
  }

  if (numberOfOpenedAndClosedBraces !== 0) {
    generateError('Invalid number of braces', position);
  }

  if (numberOfOpenedAndClosedBrackets !== 0) {
    generateError('Invalid number of brackets', position);
  }

  return tokens;
};

const createAST = (tokens: Token[]): ASTNode => {
  let current = 0;

  const next = () => tokens[++current];

  const parseObject = (): ASTNode => {
    const node: ASTNode = { type: 'Object', value: {} };
    let token = next();

    while (token.type !== 'BraceClose') {
      if (token.type === 'String') {
        const key = token.value;
        token = next();
        if (token.type === 'Colon') {
          next();
          node.value[key] = parseValue();
          token = next();
        } else {
          generateError(`Invalid token ${token.type}`, current);
        }
        if (token.type === 'Comma') {
          token = next();
          if (token.type === 'BraceClose') {
            generateError(`Unexpected token ${token.type} after comma`, current);
          }
        }
      } else {
        generateError(`Invalid token ${token.type}`, current);
      }
    }

    return node;
  };

  const parseArray = (): ASTNode => {
    let token = next();
    const node: ASTNode = { type: 'Array', value: [] };

    while (token.type !== 'BracketClose') {
      node.value.push(parseValue());
      token = next();
      if (token.type === 'Comma') {
        token = next();
        if (token.type === 'BracketClose') {
          generateError(`Unexpected token ${token.type} after comma`, current);
        }
      }
    }

    return node;
  };

  const parseValue = (): ASTNode => {
    if (!tokens.length) {
      throw new Error('No tokens to parse');
    }

    const token = tokens[current];

    switch (token.type) {
      case 'BraceOpen': {
        return parseObject();
      }
      case 'BracketOpen': {
        return parseArray();
      }
      case 'String': {
        return { type: 'String', value: token.value };
      }
      case 'Number': {
        if (Number.isNaN(Number(token.value))) {
          generateError(`Invalid number ${token.value}`, current);
        }
        return { type: 'Number', value: Number(token.value) };
      }
      case 'True': {
        return { type: 'Boolean', value: true };
      }
      case 'False': {
        return { type: 'Boolean', value: false };
      }
      case 'Null': {
        return { type: 'Null', value: null };
      }
    }

    throw new Error(`parseValue: Invalid token ${token.type}`);
  };

  return parseValue();
};

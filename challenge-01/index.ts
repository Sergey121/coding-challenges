#!/usr/bin/env ts-node

import fs from 'fs';

import readline from 'readline';

type Stream = fs.ReadStream | NodeJS.ReadStream;

let command: string;
let fileName: string | undefined;

const isCommand = (arg: string) => arg.startsWith('-');

if (process.argv.length === 3) {
  [, , fileName] = process.argv;

  if (isCommand(fileName)) {
    command = fileName;
    fileName = undefined;
  }
} else if (process.argv.length === 4) {
  [, , command, fileName] = process.argv;
} else {
  throw new Error('Invalid number of arguments');
}

// find number of bytes in a file
const findNumberOfBytes = async (inputSource: Stream) => {
  let numberOfBytes = 0;

  return new Promise((resolve, reject) => {
    inputSource.on('data', chunk => {
      numberOfBytes += Buffer.byteLength(chunk);
    });
    inputSource.on('end', () => {
      resolve(numberOfBytes);
    });
    inputSource.on('error', reject);
  });
};

const readFileByLine = async (
  fileStream: Stream,
  {
    onLine,
    onClose,
    onError,
  }: {
    onLine: (line: string) => void;
    onClose: () => void;
    onError: (error: Error) => void;
  },
) => {
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity,
  });

  rl.on('line', onLine);

  rl.on('close', onClose);

  rl.on('error', onError);
};

// find number of lines and words in a file
const findNumberOfLinesAndWords = async (
  streamInput: Stream,
): Promise<{
  numberOfLines: number;
  numberOfWords: number;
}> => {
  let numberOfLines = 0;
  let numberOfWords = 0;
  return new Promise((resolve, reject) => {
    readFileByLine(streamInput, {
      onLine: line => {
        numberOfLines++;
        const trimmedLine = line.trim();
        if (!!trimmedLine) {
          const words = line.trim().split(/\s+/);
          numberOfWords += words.length;
        }
      },
      onClose: () => {
        resolve({ numberOfLines, numberOfWords });
      },
      onError: reject,
    });
  });
};

const writeToOutput = (str: string) => {
  process.stdout.write(`\t${str} ${fileName ? fileName : ''}\n`);
};

async function main() {
  let inputSource: Stream;

  if (fileName) {
    inputSource = fs.createReadStream(fileName);
  } else {
    inputSource = process.stdin;
  }

  if (!inputSource) {
    throw new Error('You must provide a file name or an input source');
  }

  if (!command) {
    const [numberOfBytes, { numberOfWords, numberOfLines }] = await Promise.all([
      findNumberOfBytes(inputSource),
      findNumberOfLinesAndWords(inputSource),
    ]);

    writeToOutput(`${numberOfLines}  ${numberOfWords}  ${numberOfBytes}`);
  } else {
    switch (command) {
      case '-c': {
        const numberOfBytes = await findNumberOfBytes(inputSource);
        writeToOutput(`${numberOfBytes}`);
        break;
      }
      case '-l': {
        const { numberOfLines } = await findNumberOfLinesAndWords(inputSource);
        writeToOutput(`${numberOfLines}`);
        break;
      }
      case '-w': {
        const { numberOfWords } = await findNumberOfLinesAndWords(inputSource);
        writeToOutput(`${numberOfWords}`);
        break;
      }
      case '-m': {
        throw new Error('Not implemented');
      }
      default: {
        throw new Error('Invalid command');
      }
    }
  }
}

void main();

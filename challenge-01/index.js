#!/usr/bin/env node
"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = __importDefault(require("fs"));
const readline_1 = __importDefault(require("readline"));
let command;
let fileName;
const isCommand = (arg) => arg.startsWith('-');
if (process.argv.length === 3) {
    [, , fileName] = process.argv;
    if (isCommand(fileName)) {
        command = fileName;
        fileName = undefined;
    }
}
else if (process.argv.length === 4) {
    [, , command, fileName] = process.argv;
}
else {
    throw new Error('Invalid number of arguments');
}
// find number of bytes in a file
const findNumberOfBytes = (inputSource) => __awaiter(void 0, void 0, void 0, function* () {
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
});
const readFileByLine = (fileStream, { onLine, onClose, onError, }) => __awaiter(void 0, void 0, void 0, function* () {
    const rl = readline_1.default.createInterface({
        input: fileStream,
        crlfDelay: Infinity,
    });
    rl.on('line', onLine);
    rl.on('close', onClose);
    rl.on('error', onError);
});
// find number of lines and words in a file
const findNumberOfLinesAndWords = (streamInput) => __awaiter(void 0, void 0, void 0, function* () {
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
});
const writeToOutput = (str) => {
    process.stdout.write(`\t${str} ${fileName ? fileName : ''}\n`);
};
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        let inputSource;
        if (fileName) {
            inputSource = fs_1.default.createReadStream(fileName);
        }
        else {
            inputSource = process.stdin;
        }
        if (!inputSource) {
            throw new Error('You must provide a file name or an input source');
        }
        if (!command) {
            const [numberOfBytes, { numberOfWords, numberOfLines }] = yield Promise.all([
                findNumberOfBytes(inputSource),
                findNumberOfLinesAndWords(inputSource),
            ]);
            writeToOutput(`${numberOfLines}  ${numberOfWords}  ${numberOfBytes}`);
        }
        else {
            switch (command) {
                case '-c': {
                    const numberOfBytes = yield findNumberOfBytes(inputSource);
                    writeToOutput(`${numberOfBytes}`);
                    break;
                }
                case '-l': {
                    const { numberOfLines } = yield findNumberOfLinesAndWords(inputSource);
                    writeToOutput(`${numberOfLines}`);
                    break;
                }
                case '-w': {
                    const { numberOfWords } = yield findNumberOfLinesAndWords(inputSource);
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
    });
}
void main();

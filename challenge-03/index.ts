import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { JSONParse } from './parse';

const tests = join(__dirname, 'tests');

const files = readdirSync(tests);

for (const file of files/*['fail26.json']*/) {
  try {
    const content = readFileSync(join(tests, file), 'utf-8');
    JSONParse(content);
    if (file.startsWith('fail')) {
      console.error(`\x1b[31m[File ${file} parsed successfully, but it should not.]\x1b[0m`);
    } else {
      console.debug(`\x1b[32m[File ${file} parsed successfully]\x1b[0m`);
    }
  } catch (error) {
    if (file.startsWith('fail')) {
      console.debug(`\x1b[32m[File ${file} not parsed successfully, this is ok]\x1b[0m`);
    } else {
      console.error(`\x1b[31m[Error parse file: ${file}]\x1b[0m`);
    }
  }
}

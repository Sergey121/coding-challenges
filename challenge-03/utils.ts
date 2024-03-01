export const isNumber = (value: string) => !isNaN(Number(value));
export const isBooleanTrue = (value: string) => value === 'true';
export const isBooleanFalse = (value: string) => value === 'false';
export const isNull = (value: string) => value === 'null';

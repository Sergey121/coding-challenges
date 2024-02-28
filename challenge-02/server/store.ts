import { ShortenedURL } from '@/shared/types';
import crypto from 'crypto';

const generateHashKey = (url: string) => {
  const hash = crypto.createHash('sha1');
  hash.update(url);
  return hash.digest('hex').slice(0, 5);
}
const urls = new Map<string, ShortenedURL>();

export const addUrl = (url: string): ShortenedURL => {
  const key = generateHashKey(url);
  if (urls.has(key)) {
    return urls.get(key) as ShortenedURL;
  }

  const shortenedUrl: ShortenedURL = {
    key,
    url,
    shortURL: `http://localhost:3000/${key}`,
  };

  urls.set(key, shortenedUrl);

  return shortenedUrl;
}

export const getURL = (key: string): ShortenedURL | undefined => {
  return urls.get(key);

}

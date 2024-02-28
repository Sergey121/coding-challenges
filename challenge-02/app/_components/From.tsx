'use client';

import React from 'react';
import { ChainIcon } from '@/app/_components/ChainIcon';
import { CopyInput } from '@/app/_components/CopyInput';
import { trpc } from '@/app/_trpc/client';
import { URL_REGEX } from '@/shared/utils';

export const Form = () => {
  const [url, setUrl] = React.useState('');
  const [error, setError] = React.useState('');

  const {
    mutate,
    data,
    error: responseError,
  } = trpc.makeUrlShort.useMutation({
    onError(error) {
      setError(error?.data?.zodError?.formErrors?.[0] || 'An error occurred');
    },
  });

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');

    if (!url || !url.trim()) {
      setError('Please enter a url');
      return;
    }

    URL_REGEX.lastIndex = 0;
    if (!URL_REGEX.test(url)) {
      setError('Please enter a valid url');
      return;
    }

    mutate(url);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (error) setError('');
    setUrl(e.target.value);
  };

  const shortUrl = data?.shortURL;

  return (
    <form onSubmit={handleSubmit} className="w-[400px]">
      <div className="flex items-center">
        <ChainIcon />
        <p className="text-zinc-800 pl-2">Shorten a long url</p>
      </div>
      <input
        className="p-2 mt-2 mb-2 w-full rounded border-zinc-600 border-2"
        placeholder="Enter a long url"
        value={url}
        onChange={handleChange}
      />
      {shortUrl && <CopyInput url={shortUrl} />}
      {error && <p className="text-red-500 text-sm">{error}</p>}
      <div className="flex justify-end items-end">
        <button className="rounded-lg bg-purple-100 p-2 text-purple-700 drop-shadow-lg hover:bg-purple-200">
          Submit
        </button>
      </div>
    </form>
  );
};

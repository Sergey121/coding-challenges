'use client';

import { CopyIcon } from '@/app/_components/CopyIcon';

type Props = {
  url: string;
};
export const CopyInput = (props: Props) => {
  const { url } = props;

  const handleCopy = () => {
    navigator.clipboard.writeText(url);
  };

  return (
    <div className="flex flex-row items-center relative">
      <input className="p-2 mt-2 mb-2 w-full rounded truncate overflow-ellipsis pr-[30px]" placeholder="Enter a long url" value={url} readOnly />
      <button type="button" onClick={handleCopy} className="absolute right-0 hover:opacity-80">
        <CopyIcon />
      </button>
    </div>
  );
};

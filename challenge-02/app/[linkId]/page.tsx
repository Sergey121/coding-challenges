import { redirect, RedirectType } from 'next/navigation';
import { serverClient } from '@/app/_trpc/serverClient';

type Props = {
  params: {
    linkId: string;
  };
};

export default async function HomeLinkId(props: Props) {
  const { linkId } = props.params;

  const url = await serverClient.getShortUrl(linkId);

  if (url?.url) {
    return redirect(url.url, RedirectType.replace);
  }

  return redirect('/', RedirectType.replace);
}

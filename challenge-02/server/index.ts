import { z } from 'zod';

import { publicProcedure, router } from './trpc';
import { addUrl, getURL } from '@/server/store';

export const appRouter = router({
  getShortUrl: publicProcedure.input(z.string()).query(async opts => {
    return getURL(opts.input);
  }),
  makeUrlShort: publicProcedure.input(z.string().url('Must be a valid url')).mutation(async opts => {
    return addUrl(opts.input);
  }),
});

export type AppRouter = typeof appRouter;

FROM node:20-bookworm-slim as builder

ARG VERSION=v1.0.10
ARG PUBLIC_BASE_DOMAIN

RUN mkdir -p /ente-repo
RUN apt update && apt install -y wget
RUN wget https://github.com/ente-io/ente/archive/refs/tags/photos-${VERSION}.tar.gz
RUN tar -xvzf photos-${VERSION}.tar.gz -C /ente-repo

WORKDIR /ente-repo/ente-photos-${VERSION}/web

RUN corepack enable

ENV NEXT_PUBLIC_ENTE_ENDPOINT=https://ente.${PUBLIC_BASE_DOMAIN}
ENV NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT=https://ente-albums.${PUBLIC_BASE_DOMAIN}

RUN yarn cache clean
RUN yarn install --network-timeout 1000000000
RUN yarn build:photos && yarn build:accounts && yarn build:auth && yarn build:cast

RUN mv apps /apps

FROM node:20-bookworm-slim

ARG PUBLIC_BASE_DOMAIN

WORKDIR /app

COPY --from=builder  /apps/photos/out /app/photos
COPY --from=builder  /apps/accounts/out /app/accounts
COPY --from=builder  /apps/auth/out /app/auth
COPY --from=builder  /apps/cast/out /app/cast

RUN npm install -g serve

ENV PHOTOS_PORT=3000
ENV ACCOUNTS_PORT=3001
ENV AUTH_PORT=3002
ENV CAST_PORT=3003
ENV ALBUMS_PORT=3004

ENV ENTE_API_ORIGIN=https://ente-api.${PUBLIC_BASE_DOMAIN}
ENV ENTE_ALBUMS_ORIGIN=https://ente-albums.${PUBLIC_BASE_DOMAIN}

CMD ["sh", "-c", "serve /app/photos -l tcp://0.0.0.0:${PHOTOS_PORT} & serve /app/accounts -l tcp://0.0.0.0:${ACCOUNTS_PORT} & serve /app/auth -l tcp://0.0.0.0:${AUTH_PORT} & serve /app/cast -l tcp://0.0.0.0:${CAST_PORT}"]

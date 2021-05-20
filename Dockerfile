# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/Release (looking for "LTS")
# https://github.com/TryGhost/Ghost/blob/v4.1.2/package.json#L38
# TODO: node 14 on alpine 3.13 has an issue with sharp/image resizing
# see: https://github.com/docker-library/ghost/issues/256
# sticking to Node 12 until the underlying sharp issue is resolved
FROM node:12-alpine3.12

# grab su-exec for easy step-down from root
RUN apk add --no-cache 'su-exec>=0.2'

RUN apk add --no-cache \
    # add "bash" for "[["
    bash

ENV NODE_ENV production

ENV GHOST_CLI_VERSION 1.17.1
RUN set -eux; \
    npm cache clean --force

RUN apk update
RUN apk add git

ENV GHOST_INSTALL /var/lib/ghost

ENV GHOST_VERSION 4.5.0

RUN set -eux; \
    mkdir -p "$GHOST_INSTALL"; \
    chown node:node "$GHOST_INSTALL"; \
    \
    # Tell Ghost to listen on all ips and not prompt for additional configuration
    cd "$GHOST_INSTALL"; \
    su-exec git clone --recurse-submodules https://github.com/nlaha/Ghost \
    su-exec mv Ghost/* ./* \
    su-exec yarn install \
    # make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
    su-exec node ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
    readlink -f "$GHOST_INSTALL/config.development.json"; \
    \
    # force install "sqlite3" manually since it's an optional dependency of "ghost"
    # (which means that if it fails to install, like on ARM/ppc64le/s390x, the failure will be silently ignored and thus turn into a runtime error instead)
    # see https://github.com/TryGhost/Ghost/pull/7677 for more details
    # scrape the expected version of sqlite3 directly from Ghost itself
    sqlite3Version="$(node -p 'require("./package.json").optionalDependencies.sqlite3')"; \
    if ! su-exec node yarn add "sqlite3@$sqlite3Version" --force; then \
    # must be some non-amd64 architecture pre-built binaries aren't published for, so let's install some build deps and do-it-all-over-again
    apk add --no-cache --virtual .build-deps g++ gcc libc-dev make python3 vips-dev; \
    \
    npm_config_python='python3' su-exec node yarn add "sqlite3@$sqlite3Version" --force --build-from-source; \
    \
    apk del --no-network .build-deps; \
    fi; \
    \
    su-exec node yarn cache clean; \
    su-exec node npm cache clean --force; \
    npm cache clean --force; \
    rm -rv /tmp/yarn* /tmp/v8*

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_INSTALL

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2368
CMD ["node", "current/index.js"]
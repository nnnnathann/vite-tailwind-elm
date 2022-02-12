FROM node:16 as dev
WORKDIR /var/www/app
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm
COPY .npmrc package.json pnpm-lock.yaml .pnpmfile.cjs ./
RUN pnpm install --frozen-lockfile --prod
COPY . .
RUN pnpm run ci
CMD [ "npm", "start" ]
FROM node:16 as builder

WORKDIR /var/www/app
COPY . /var/www/app
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm


FROM nginx:1.21-alpine as production
COPY ./docker/static/nginx.conf /etc/nginx/conf.d/default.conf
# Copy over the build artifacts to a static nginx server
COPY --from=builder /var/www/app/dist/static /usr/share/nginx/html
FROM node:12-alpine AS builder

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /app/
RUN npm install --silent

COPY . /app/
RUN npm run build


FROM nginx:alpine
RUN addgroup -g 1000 -S www-data ; adduser -u 1000 -D -S -G www-data www-data
COPY --from=builder /app/nginx/sites-enabled/ /etc/nginx/sites-enabled
COPY --from=builder /app/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist/frontend/ /var/www/app/
# Test configs
RUN /usr/sbin/nginx -t
CMD ["/usr/sbin/nginx"]

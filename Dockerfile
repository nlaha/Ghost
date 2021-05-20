FROM node:12.18-alpine
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN yarn global add knex-migrator grunt-cli ember-cli
RUN npm install && mv node_modules ../
ENV NODE_ENV=production
COPY . .
EXPOSE 2368
CMD ["npm", "start"]

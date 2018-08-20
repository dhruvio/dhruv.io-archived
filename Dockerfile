FROM tiangolo/node-frontend

RUN npm i --unsafe-perm -g elm

ENV PORT=3000 HOSTNAME=0.0.0.0
EXPOSE 3000

ADD . /app
WORKDIR /app

RUN npm install

CMD ["npm", "start"]

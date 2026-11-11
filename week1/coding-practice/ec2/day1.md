# Docker File for react-app

FROM node:22-alpine


WORKDIR /app


COPY package*.json .

RUN npm install

COPY . .

EXPOSE 5173 # vite default port

CMD ["npm","run","dev","--","--host","0.0.0.0"]
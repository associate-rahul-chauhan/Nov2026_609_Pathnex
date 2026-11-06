FROM node:22-alpine AS BUILD

WORKDIR /app

COPY package*.json ./

RUN npm install # if package.local prsent then can try npm ci

COPY . .

RUN npm run build

#stage 2: serve application using nginx

FROM nginx:alpine

copy --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

cmd ["nginx", "-g", "daemon off;"]
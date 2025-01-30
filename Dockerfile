# Stage 1: Build the Angular app
FROM node:16 AS build-stage
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build -- --prod

# Stage 2: Serve the Angular app with Nginx
FROM nginx:alpine
COPY --from=build-stage /app/dist/my-app /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
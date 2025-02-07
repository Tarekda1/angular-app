# Stage 1: Build the Angular app
FROM node:alpine AS build-stage
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --omit=dev

# Stage 2: Serve the Angular app with Nginx
FROM nginx:alpine
COPY --from=build-stage /app/dist/first-angular-app/browser  /usr/share/nginx/html
EXPOSE 8282
CMD ["nginx", "-g", "daemon off;"]
# Stage 1: Build the Angular app
FROM node:18-alpine AS build-stage 
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --omit=dev

# Stage 2: Serve with Nginx (named production)
FROM nginx:alpine AS production
COPY --from=build-stage /app/dist/first-angular-app/browser /usr/share/nginx/html
COPY ./nginx/default.conf /etc/nginx/conf.d/
EXPOSE 8282
CMD ["nginx", "-g", "daemon off;"]

# Stage 3: Development
FROM node:18-alpine AS development
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
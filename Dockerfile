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
# Copy default.conf (or your server config file) and nginx.conf
#COPY default.conf /etc/nginx/conf.d/   
# OR, if default.conf is in same directory as nginx.conf:
# COPY default.conf /etc/nginx/
#COPY default.conf /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8282
CMD ["nginx", "-g", "daemon off;"]
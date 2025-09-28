FROM node:18-alpine AS build
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci --silent

# Copy source and build
COPY . .
RUN npm run build
+

# Production stage - serve with nginx
FROM nginx:stable-alpine AS production
+
RUN rm -rf /usr/share/nginx/html/*
+
COPY --from=build /app/build /usr/share/nginx/html
+COPY nginx-spa.conf /etc/nginx/conf.d/default.conf
+
EXPOSE 80
+
CMD ["nginx", "-g", "daemon off;"]

# ---- Build Stage ----
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies first (layer cache)
COPY package*.json ./
RUN npm ci

# Build the production bundle
COPY . .
RUN npm run build

# ---- Runtime Stage ----
FROM nginx:alpine

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Nginx config: serves SPA + proxies /api to backend service
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

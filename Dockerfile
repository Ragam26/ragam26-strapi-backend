# Stage 1: Build
FROM node:24-alpine AS build
RUN apk add --no-cache build-base gcc autoconf automake libtool zlib-dev vips-dev git

WORKDIR /app
COPY package.json package-lock.json ./
# Install all dependencies (we will skip pruning to ensure ultimate stability)
RUN npm install

COPY . .
ENV NODE_ENV=production
RUN npm run build


# Stage 2: Hardened Runtime
FROM node:24-alpine
RUN apk add --no-cache vips-dev
WORKDIR /app

# Copy standard production files
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json

# STRAPI 5 SPECIFIC: Copy the hidden UI build and database folders
COPY --from=build /app/.strapi ./.strapi
COPY --from=build /app/database ./database

# Create persistence folders and set ownership
RUN mkdir -p /app/public/uploads /app/.cache \
    && chown -R node:node /app

USER node
EXPOSE 1337
ENV NODE_ENV=production

CMD ["npm", "run", "start"]
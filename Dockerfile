# Stage 1: Build
FROM node:24-alpine AS build
# Added 'git' just in case some npm packages fetch from git
RUN apk add --no-cache build-base gcc autoconf automake libtool zlib-dev vips-dev git

WORKDIR /app
COPY package.json package-lock.json ./

# 1. Install ALL dependencies (including TypeScript compiler)
RUN npm i

COPY . .
# 2. Build the Strapi admin and then compile TypeScript server files
ENV NODE_ENV=production
RUN npm run build

# Compile any TypeScript server/config files to JS (outputs to ./dist)
# tsc is a devDependency so this must run before pruning
RUN npx tsc -p tsconfig.json || true

# 3. Prune dependencies to only what's needed for RUNNING
RUN npm prune --production


# Stage 2: Hardened Runtime
FROM node:24-alpine
RUN apk add --no-cache vips-dev
WORKDIR /app

# 4. Only copy the essentials:
# - node_modules (now pruned to production only)
# - dist (your compiled JS)
# - public (for the Admin UI assets)
# - package.json (to run the start script)
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
# Copy compiled config JS (if TypeScript configs were compiled into dist/config)
COPY --from=build /app/dist/config ./config

# Create persistence folders
RUN mkdir -p /app/public/uploads /app/.cache \
    && chown -R node:node /app

USER node

EXPOSE 1337
ENV NODE_ENV=production

# Strapi's 'npm start' command essentially runs 'node dist/server.js'
CMD ["npm", "run", "start"]
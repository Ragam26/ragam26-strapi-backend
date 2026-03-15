FROM node:24-alpine

# Install all system dependencies required for Strapi and SQLite/Postgres native bindings
RUN apk add --no-cache build-base gcc autoconf automake libtool zlib-dev vips-dev git

WORKDIR /app

# Copy package files and install EVERYTHING
COPY package.json package-lock.json ./
RUN npm install

# Copy your entire source code into the image
COPY . .

# Build the Strapi admin panel and compile TypeScript
ENV NODE_ENV=production
RUN npm run build

# Set up persistence folders and permissions
RUN mkdir -p /app/public/uploads /app/.cache \
    && chown -R node:node /app

# Run as a non-root user for security
USER node

EXPOSE 1337

# Start the server
CMD ["npm", "run", "start"]
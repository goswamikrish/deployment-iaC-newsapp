# Stage 1: Build environment
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy application source code
COPY server.js ./

# Stage 2: Production environment using distroless image
FROM gcr.io/distroless/nodejs20-debian11

# Set working directory
WORKDIR /app

# Copy built application and dependencies from the build stage
COPY --from=build /app /app

# Expose the application port
EXPOSE 5000

# Start the application
CMD ["server.js"]

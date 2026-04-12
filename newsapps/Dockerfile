# Stage 1: Build the React application
FROM node:20-alpine AS build

# Set the working directory
WORKDIR /app

# Copy package management files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of your application code
COPY . .

# Build the React app for production
RUN npm run build

# Stage 2: Serve the application using a distroless web server
# We use Chainguard's Nginx image, which is a true distroless image (no shell, minimal dependencies, 0 CVEs)
FROM cgr.dev/chainguard/nginx:latest

# Copy the Nginx configuration to support React Router
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the compiled React build from Stage 1 to Nginx's HTML root
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 8080 (matches your nginx.conf)
EXPOSE 8080

# By default, the distroless Nginx image will start the Nginx server

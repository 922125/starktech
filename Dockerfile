# Stage 1: Build the frontend application
# Using a Node.js image to compile your JavaScript/frontend code
FROM node:18-alpine AS builder

# Set the working directory inside this build container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) first.
# This allows Docker to cache the npm install step if your dependencies haven't changed.
COPY package*.json ./

# Install your project's Node.js dependencies
RUN npm install

# Copy the rest of your application's source code into the container
COPY . .

# *** IMPORTANT: CUSTOMIZE THIS LINE ***
# This command runs your build script (e.g., build.js) to create the static assets.
# Replace 'npm run build' with the exact command you use locally to build your project.
# Examples: 'npm run build', 'node build.js', 'yarn build', etc.
RUN npm run build

# Stage 2: Serve the compiled frontend application using a lightweight Nginx web server
# This creates a very small final image, as it doesn't include Node.js or build tools.
FROM nginx:alpine

# *** IMPORTANT: CUSTOMIZE THIS LINE ***
# This copies the STATIC FILES produced by your build step (from Stage 1)
# into the Nginx web server's default serving directory.
# You MUST replace '/app/build' with the actual directory name where your build script
# (e.g., build.js) outputs the compiled static files.
# Common output directory names are 'build', 'dist', 'out', or 'public_html'.
COPY --from=builder /app/build /usr/share/nginx/html

# Optionally, if you have a custom Nginx configuration, you can copy it here.
# For example, if you have an 'nginx.conf' file in your repo root under an 'nginx' folder:
# COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port Nginx listens on. Standard for HTTP is 80.
# If your application needs to be served on a different port, change this.
EXPOSE 80

# Command to run Nginx when the container starts.
CMD ["nginx", "-g", "daemon off;"]

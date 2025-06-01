# Stage 1: Build the frontend application
# Uses a Node.js image to compile your JavaScript/frontend code
FROM node:18-alpine AS builder

# Set the working directory inside this build container
# This is where package.json should be and where npm commands will run from.
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) first.
# This allows Docker to cache the npm install step if your dependencies haven't changed.
COPY package*.json ./

# Install your project's Node.js dependencies
RUN npm install

# Copy the rest of your application's source code into the container.
# This will copy your 'src' directory (containing main.js) and other project files.
COPY . .

# *** YOU MUST VERIFY THIS COMMAND! ***
# This command runs your build script (e.g., build.js) to create the static assets.
# Common for Node.js frontends.
# If your actual command is different (e.g., 'node build.js', 'yarn build', 'npm run webpack'), CHANGE THIS.
RUN npm run build

# Stage 2: Serve the compiled frontend application using a lightweight Nginx web server
# This creates a very small final image, as it doesn't include Node.js or build tools.
FROM nginx:alpine

# *** YOU MUST VERIFY THIS PATH! ***
# This copies the STATIC FILES produced by your build step (from Stage 1)
# into the Nginx web server's default serving directory.
# 'build' is the most common output directory for 'npm run build'.
# If your build script outputs to a different directory (e.g., '/app/dist', '/app/out'), CHANGE THIS.
COPY --from=builder /app/build /usr/share/nginx/html

# Expose the port Nginx listens on. Standard for HTTP is 80.
EXPOSE 80

# Command to run Nginx when the container starts.
CMD ["nginx", "-g", "daemon off;"]

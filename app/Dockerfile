# app/Dockerfile

# Use official Node.js LTS image
FROM node:20-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package files first (better layer caching)
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy the rest of the app source
COPY . .

# The app listens on port 80 inside the container
EXPOSE 80

# Environment variable for app name (optional)
ENV APP_NAME="mynewdemo"

# Start the Node.js app
CMD ["npm", "start"]

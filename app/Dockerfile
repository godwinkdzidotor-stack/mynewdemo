# Use an official Node.js runtime as a parent image
FROM node:20-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install --only=production

# Bundle app source
COPY . .

# Expose the app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]

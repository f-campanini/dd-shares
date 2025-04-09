# Use Node.js version 12 as the base image
FROM node:12

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the application source code
COPY . .

# Expose the application port
EXPOSE 3000

# Set environment variables for Datadog APM
ENV DD_AGENT_HOST=172.17.0.3
ENV DD_TRACE_AGENT_PORT=8126
ENV NODE_ENV=production
ENV DD_TRACE_STARTUP_LOGS=true

# Command to run the application
CMD ["node", "--require", "dd-trace/init", "app.js"]

# Use a lightweight Node.js image to build the app dependencies.
FROM node:18-alpine AS builder

# Set the working directory inside the container.
WORKDIR /app

# Copy dependency manifests first so npm installs can be cached efficiently.
COPY package*.json ./
RUN npm ci

# Copy the application source code into the build stage.
COPY . .

# Start a smaller production image for the final runtime container.
FROM node:18-alpine AS production

# Create a dedicated non-root user for security.
RUN addgroup -g 1001 -S nodejs && adduser -u 1001 -S nodejs -G nodejs

# Set the runtime working directory.
WORKDIR /app

# Install only the production dependencies needed to run the app.
COPY package*.json ./
RUN npm ci --only=production

# Copy the built application code from the builder stage.
COPY --from=builder /app/index.js ./index.js

# Ensure the application files are owned by the non-root user.
RUN chown -R nodejs:nodejs /app

# Run the app as the unprivileged user.
USER nodejs

# Expose the application port.
EXPOSE 3100

# Check the app health endpoint to confirm the server is ready.
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget -qO- http://127.0.0.1:3100/health || exit 1

# Start the application.
CMD ["node", "index.js"]

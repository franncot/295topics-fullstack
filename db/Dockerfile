# Use the official MongoDB image as the base
FROM mongo:latest

# Copy the initialization script into the container
COPY ./mongo-init.js /docker-entrypoint-initdb.d/

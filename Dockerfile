# Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install newman + html reporter
RUN npm install -g newman newman-reporter-htmlextra

# Copy only what we need
COPY collections ./collections

# (optional) copy anything else you might reference, like README etc.
# COPY . .

# Run the collection (quote the file that has a space!)
CMD ["newman", "run", "collections/Finance API.postman_collection.json", "-e", "collections/DEV.postman_environment.json", "--reporters", "cli"]

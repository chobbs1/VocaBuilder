FROM node:22-alpine

WORKDIR /app

# Install dependencies first (cached layer)
COPY package.json package-lock.json* ./
RUN npm install

# Copy source
COPY . .

# Keep container running — start sandbox manually via:
#   docker exec -it voca-builder-backend-amplify-1 sh
#   npx ampx sandbox
CMD ["sh", "-c", "echo 'Container ready. Shell in to start sandbox.' && tail -f /dev/null"]

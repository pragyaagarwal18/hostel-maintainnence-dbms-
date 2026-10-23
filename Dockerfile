# ============================================================================
# Dockerfile for Hostel Maintenance & Complaint Management System
# Authors: Pragya Agarwal (24BCI0280) & Suhani Singh (24BCI0006)
# Course: BCSE302P Database Systems Lab | Slot: L25+L26
# ============================================================================

FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install dependencies first (layer caching)
COPY package*.json ./
RUN npm install --production

# Copy Prisma schema and generate client
COPY prisma ./prisma/
RUN npx prisma generate

# Copy source code and frontend static assets
COPY src ./src
COPY public ./public

# Expose server port
EXPOSE 5000

# Set environment defaults
ENV PORT=5000
ENV NODE_ENV=production

# Healthcheck for container stability
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5000/api/health || exit 1

# Start the Node.js Express server
CMD ["node", "src/server.js"]

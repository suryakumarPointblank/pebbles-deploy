# ── Builder stage ──────────────────────────────────────────────────────────────
FROM node:20-slim AS builder

# Build-time deps for native modules (canvas, sqlite3)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# ── Production stage ───────────────────────────────────────────────────────────
FROM node:20-slim

# Runtime libs required by canvas at process start
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libjpeg62-turbo \
    libgif7 \
    librsvg2-2 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY . .

# @ffprobe-installer expects a bundled binary + package.json; point it at the system ffprobe
RUN mkdir -p /app/node_modules/@ffprobe-installer/linux-x64 && \
    ln -sf /usr/bin/ffprobe /app/node_modules/@ffprobe-installer/linux-x64/ffprobe && \
    echo '{"name":"@ffprobe-installer/linux-x64","version":"5.1.8","ffprobe":"5.1.8","homepage":"https://ffbinaries.com/downloads"}' \
    > /app/node_modules/@ffprobe-installer/linux-x64/package.json

EXPOSE 5000

CMD ["node", "app.js"]

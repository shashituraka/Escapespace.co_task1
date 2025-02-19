# Stage 1: Node.js Scraper
FROM node:18-slim AS scraper

# Install Chromium and fonts
RUN apt-get update && \
    apt-get install -y chromium fonts-ipafont-gothic fonts-freefont-ttf && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Configure Puppeteer to use system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

COPY package.json .
RUN npm install

COPY scrape.js .

# Run scraper (URL provided at build time)
ARG SCRAPE_URL
ENV SCRAPE_URL=$SCRAPE_URL
RUN node scrape.js

# Stage 2: Python Server
FROM python:3.10-slim

WORKDIR /app

COPY --from=scraper /app/scraped_data.json .
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

EXPOSE 5000
CMD ["python", "server.py"]

# Use a base image with Python and necessary tools
FROM python:3.10-slim

# Install common dependencies and jq (needed for JSON parsing)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set the BROWSER build argument with a default value
ARG BROWSER=chrome

# Install Chrome and matching ChromeDriver if BROWSER=chrome
RUN if [ "$BROWSER" = "chrome" ]; then \
    apt-get update && apt-get install -y \
        fonts-liberation \
        libappindicator3-1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libcups2 \
        libgdk-pixbuf2.0-0 \
        libnspr4 \
        libnss3 \
        libxss1 \
        lsb-release \
        xdg-utils \
        wget \
        unzip \
        curl \
        gnupg && \
    rm -rf /var/lib/apt/lists/* && \
    \
    # Add Google Chrome official repo and key
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/* && \
    \
    # Get installed Chrome version (full)
    CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+\.\d+') && \
    echo "Installed Chrome version: $CHROME_VERSION" && \
    \
    # Get matching ChromeDriver download URL from Google's JSON
    CHROMEDRIVER_URL="https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json" && \
    MATCHING_VERSION=$(curl -s $CHROMEDRIVER_URL | jq -r --arg ver "$CHROME_VERSION" '.versions[] | select(.version == $ver) | .version') && \
    DOWNLOAD_URL=$(curl -s $CHROMEDRIVER_URL | jq -r --arg ver "$MATCHING_VERSION" '.versions[] | select(.version == $ver) | .downloads.chromedriver[] | select(.platform == "linux64") | .url') && \
    \
    # Download, unzip, and move ChromeDriver to /usr/bin
    wget -q "$DOWNLOAD_URL" -O chromedriver.zip && \
    unzip chromedriver.zip && \
    mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    rm -rf chromedriver.zip chromedriver-linux64; \
fi

# Install Firefox ESR and Geckodriver if BROWSER=firefox
RUN if [ "$BROWSER" = "firefox" ]; then \
    apt-get update && apt-get install -y firefox-esr && \
    GECKODRIVER_VERSION=$(wget -qO- https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep -oP '"tag_name":\s*"v\K[^"]+') && \
    wget -q https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz -O geckodriver.tar.gz && \
    tar -xzf geckodriver.tar.gz && \
    mv geckodriver /usr/bin/geckodriver && \
    chmod +x /usr/bin/geckodriver && \
    rm -f geckodriver.tar.gz && \
    rm -rf /var/lib/apt/lists/*; \
fi

# Set working directory inside the container
WORKDIR /app

# Copy Python dependencies and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && pip show selenium

# Copy your test files
COPY tests /app/tests

# Set entrypoint to run pytest via python module
ENTRYPOINT ["python", "-m", "pytest"]

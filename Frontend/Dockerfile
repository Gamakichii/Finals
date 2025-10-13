# Use an image with Chrome pre-installed
FROM selenium/standalone-chrome:latest

USER root

# Install necessary tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create extension directory
RUN mkdir -p /home/seluser/extension

# Copy the Chrome extension files
COPY extension_dist/ /home/seluser/extension/

# Create a script to start Chrome with the extension
RUN echo '#!/bin/bash\n\
google-chrome \
  --disable-dev-shm-usage \
  --no-sandbox \
  --disable-gpu \
  --remote-debugging-port=9222 \
  --remote-debugging-address=0.0.0.0 \
  --user-data-dir=/home/seluser/chrome-data \
  --load-extension=/home/seluser/extension \
  --disable-blink-features=AutomationControlled \
  --no-first-run \
  --no-default-browser-check \
  "https://www.facebook.com" \
  &\n\
\n\
# Keep container running\n\
tail -f /dev/null\n\
' > /home/seluser/start-chrome.sh && chmod +x /home/seluser/start-chrome.sh

# Change ownership to seluser
RUN chown -R seluser:seluser /home/seluser/extension /home/seluser

# Switch to non-root user
USER seluser

# Expose Chrome remote debugging port
EXPOSE 9222

# Start Chrome with extension
CMD ["/home/seluser/start-chrome.sh"]

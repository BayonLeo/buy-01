FROM jenkins/inbound-agent:latest

# Install dependencies for Node.js and Chrome/Chromium
USER root

RUN apt-get update \
  && apt-get install -y curl gnupg ca-certificates --no-install-recommends \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs --no-install-recommends \
  && apt-get install -y chromium --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Ensure node and npm are available
RUN node --version || true

USER jenkins

# This image runs the standard Jenkins inbound agent entrypoint
# Build: docker build -t jenkins-node-chrome:latest .

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Hermes Agent
RUN curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# Make sure hermes is in PATH
ENV PATH="/root/.local/bin:${PATH}"
ENV HERMES_HOME="/root/.hermes"

# Copy skills and entrypoint
COPY skills/ /root/.hermes/skills/
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port (for health checks / API server if enabled)
EXPOSE 8080

CMD ["/start.sh"]

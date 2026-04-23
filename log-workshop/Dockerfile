# =============================================================================
# Datadog Logs Workshop - Self-contained Container
# Includes: Datadog Agent + Log Generator
# =============================================================================

FROM gcr.io/datadoghq/agent:7

# Install bash utilities needed by the log generator and a text editor
USER root
RUN apt-get update && apt-get install -y bc nano && rm -rf /var/lib/apt/lists/*

# Create log directory
RUN mkdir -p /var/log/workshop && chmod 755 /var/log/workshop

# Copy log generator scripts
COPY log-generator.sh /opt/workshop/log-generator.sh
COPY config.sh /opt/workshop/config.sh
RUN chmod +x /opt/workshop/*.sh

# Copy Datadog agent main configuration (enables remote_updates)
COPY datadog/datadog.yaml /etc/datadog-agent/datadog.yaml

# Copy Datadog agent configuration for workshop logs
COPY datadog/conf.d/workshop-logs-docker.yaml /etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml

# Copy entrypoint wrapper
COPY docker-entrypoint.sh /opt/workshop/docker-entrypoint.sh
RUN chmod +x /opt/workshop/docker-entrypoint.sh

# Set environment variables for the log generator
ENV LOG_DIR=/var/log/workshop

ENTRYPOINT ["/opt/workshop/docker-entrypoint.sh"]

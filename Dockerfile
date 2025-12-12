FROM grafana/grafana:latest

# Switch to root to set permissions
USER root

# Set environment variables for multi-tenant configuration
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_USERS_ALLOW_ORG_CREATE=false
ENV GF_AUTH_ANONYMOUS_ENABLED=false
ENV GF_AUTH_DISABLE_LOGIN_FORM=false
ENV GF_SECURITY_COOKIE_SECURE=true
ENV GF_SECURITY_STRICT_TRANSPORT_SECURITY=true

# Copy provisioning configuration and set correct ownership
COPY --chown=grafana:grafana provisioning/ /etc/grafana/provisioning/

# Railway uses PORT env var, Grafana needs GF_SERVER_HTTP_PORT
ENV GF_SERVER_HTTP_PORT=${PORT:-3000}

# Switch back to grafana user
USER grafana

# Expose Grafana port
EXPOSE 3000

# Health check (uses PORT env var or defaults to 3000)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-3000}/api/health || exit 1

FROM grafana/grafana:latest

# Set environment variables for multi-tenant configuration
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_USERS_ALLOW_ORG_CREATE=false
ENV GF_AUTH_ANONYMOUS_ENABLED=false
ENV GF_AUTH_DISABLE_LOGIN_FORM=false
ENV GF_SECURITY_COOKIE_SECURE=true
ENV GF_SECURITY_STRICT_TRANSPORT_SECURITY=true

# Copy provisioning configuration
COPY provisioning/ /etc/grafana/provisioning/

# Expose Grafana port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

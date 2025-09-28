#!/bin/sh
set -e

# Replace a baked backend URL in built assets with runtime value if provided
if [ -n "$REACT_APP_BACKEND_URL_RUNTIME" ]; then
  echo "[entrypoint] Replacing backend URL in static files with: $REACT_APP_BACKEND_URL_RUNTIME"
  # Replace in index.html and JS bundles
  for f in /usr/share/nginx/html/index.html /usr/share/nginx/html/*.html /usr/share/nginx/html/static/js/*.js; do
    if [ -f "$f" ]; then
      sed -i "s|http://backend:3500/api/tasks|$REACT_APP_BACKEND_URL_RUNTIME|g" "$f" || true
    fi
  done
fi

# Start nginx
exec nginx -g 'daemon off;'

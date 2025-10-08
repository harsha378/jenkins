#!/bin/bash

CURRENT_TARGET=$(grep -A1 "upstream backend" nginx.conf | grep "server" | awk '{print $2}' | cut -d':' -f1)

if [ "$CURRENT_TARGET" = "app-blue" ]; then
    NEW_TARGET="app-green"
    echo "Switching from BLUE to GREEN"
else
    NEW_TARGET="app-blue"
    echo "Switching from GREEN to BLUE"
fi

# Update nginx config
sed -i "s/server $CURRENT_TARGET:3000;/server $NEW_TARGET:3000;/g" nginx.conf

# Reload nginx
docker exec nginx-lb nginx -s reload

echo "Switched to $NEW_TARGET"

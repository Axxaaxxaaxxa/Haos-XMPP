#!/bin/bash
set -e

DOMAIN=$(jq --raw-output '.domain' /data/options.json)
ADMIN_USER=$(jq --raw-output '.admin_user' /data/options.json)
ADMIN_PASSWORD=$(jq --raw-output '.admin_password' /data/options.json)

echo "Starting Prosody for domain: ${DOMAIN}"

mkdir -p /var/run/prosody
mkdir -p /etc/prosody/certs

# Copy Let's Encrypt certs if available
if [ -f "/ssl/fullchain.pem" ]; then
    echo "Copying SSL certs..."
    cp "/ssl/fullchain.pem" "/etc/prosody/certs/${DOMAIN}.crt"
    cp "/ssl/privkey.pem" "/etc/prosody/certs/${DOMAIN}.key"
    chmod 640 "/etc/prosody/certs/${DOMAIN}.key"
    SSL_CONFIG="ssl = { key = \"/etc/prosody/certs/${DOMAIN}.key\"; certificate = \"/etc/prosody/certs/${DOMAIN}.crt\"; };"
else
    echo "No SSL certs found, running without TLS..."
    SSL_CONFIG=""
fi

cat > /etc/prosody/prosody.cfg.lua <<PROSODY
admins = { "${ADMIN_USER}@${DOMAIN}" }

modules_enabled = {
    "roster"; "saslauth"; "tls"; "dialback"; "disco";
    "carbons"; "pep"; "private"; "blocklist";
    "vcard4"; "vcard_legacy"; "version"; "uptime";
    "time"; "ping"; "register"; "admin_adhoc"; "mam";
}

allow_registration = false
daemonize = false
log = { info = "*stdout" }

VirtualHost "${DOMAIN}"
    ${SSL_CONFIG}

Component "conference.${DOMAIN}" "muc"
    modules_enabled = { "muc_mam" }
PROSODY

prosodyctl register "${ADMIN_USER}" "${DOMAIN}" "${ADMIN_PASSWORD}" 2>/dev/null || true

exec prosody

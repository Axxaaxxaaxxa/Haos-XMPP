#!/bin/bash
set -e

DOMAIN=$(bashio::config 'domain')
ADMIN_USER=$(bashio::config 'admin_user')
ADMIN_PASSWORD=$(bashio::config 'admin_password')

# Generate prosody config
cat > /etc/prosody/prosody.cfg.lua <<EOF
admins = { "${ADMIN_USER}@${DOMAIN}" }

modules_enabled = {
    "roster";
    "saslauth";
    "tls";
    "dialback";
    "disco";
    "carbons";
    "pep";
    "private";
    "blocklist";
    "vcard4";
    "vcard_legacy";
    "version";
    "uptime";
    "time";
    "ping";
    "register";
    "admin_adhoc";
    "http_files";
    "mam";
}

allow_registration = false
daemonize = false
pidfile = "/var/run/prosody/prosody.pid"
log = { info = "*stdout" }

VirtualHost "${DOMAIN}"
    ssl = {
        key = "/var/lib/prosody/${DOMAIN}.key";
        certificate = "/var/lib/prosody/${DOMAIN}.crt";
    }

Component "conference.${DOMAIN}" "muc"
    modules_enabled = { "muc_mam" }
EOF

# Create admin user if not exists
prosodyctl register "${ADMIN_USER}" "${DOMAIN}" "${ADMIN_PASSWORD}" || true

# Start Prosody
exec prosody

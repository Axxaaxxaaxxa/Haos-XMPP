#!/bin/bash
set -e

DOMAIN=$(jq --raw-output '.domain' /data/options.json)
ADMIN_USER=$(jq --raw-output '.admin_user' /data/options.json)
ADMIN_PASSWORD=$(jq --raw-output '.admin_password' /data/options.json)

echo "Starting Prosody for domain: ${DOMAIN}"

mkdir -p /var/run/prosody

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

Component "conference.${DOMAIN}" "muc"
    modules_enabled = { "muc_mam" }
PROSODY

prosodyctl register "${ADMIN_USER}" "${DOMAIN}" "${ADMIN_PASSWORD}" 2>/dev/null || true

exec prosody

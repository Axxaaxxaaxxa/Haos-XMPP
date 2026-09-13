#!/usr/bin/with-contenv bashio

DOMAIN=$(bashio::config 'domain')
ADMIN_USER=$(bashio::config 'admin_user')
ADMIN_PASSWORD=$(bashio::config 'admin_password')

bashio::log.info "Starting Prosody XMPP for domain: ${DOMAIN}"

# Generate prosody config
cat > /etc/prosody/prosody.cfg.lua <<PROSODY
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
    "mam";
}

allow_registration = false
daemonize = false
pidfile = "/var/run/prosody/prosody.pid"
log = { info = "*stdout" }

VirtualHost "${DOMAIN}"

Component "conference.${DOMAIN}" "muc"
    modules_enabled = { "muc_mam" }
PROSODY

# Create admin user
prosodyctl register "${ADMIN_USER}" "${DOMAIN}" "${ADMIN_PASSWORD}" || true

# Start Prosody
exec prosody

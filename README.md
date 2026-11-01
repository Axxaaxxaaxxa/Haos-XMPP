# Haos-XMPP

Home Assistant Add-on: schlanker XMPP-Server auf Basis von [Prosody](https://prosody.im/).

## Installation

1. In Home Assistant: Einstellungen → Add-ons → Add-on-Store → ⋮ → Repositories
2. Dieses Repository hinzufügen: `https://github.com/Axxaaxxaaxxa/Haos-XMPP`
3. "Prosody XMPP Server" installieren

## Konfiguration

| Option | Beschreibung |
|---|---|
| `domain` | XMPP-Domain, z. B. `xmpp.example.com` |
| `admin_user` | Name des Admin-Accounts (wird beim Start angelegt) |
| `admin_password` | Passwort des Admin-Accounts |

## Ports

| Port | Zweck |
|---|---|
| 5222 | Client-zu-Server (c2s, STARTTLS) |
| 5269 | Server-zu-Server (s2s) |
| 5280 | HTTP |

## TLS-Zertifikat

Beim Start liest das Add-on die Dateien aus `/ssl` (schreibgeschützt eingebunden):

- `/ssl/xmpp_fullchain.pem`
- `/ssl/xmpp_privkey.pem`

Das Zertifikat muss die konfigurierte `domain` abdecken. Eigene Dateinamen sind wichtig, wenn weitere Add-ons (z. B. DuckDNS oder ein Reverse-Proxy) ebenfalls Zertifikate nach `/ssl` schreiben. Sonst überschreiben sie sich gegenseitig, und Clients melden "Domain kann nicht verifiziert werden".

Beim Let's-Encrypt-Add-on dafür `certfile: xmpp_fullchain.pem` und `keyfile: xmpp_privkey.pem` setzen.

## Fehlersuche

- Log im Add-on prüfen: "Contents of /ssl" zeigt, welche Dateien das Add-on sieht.
- Zertifikat prüfen, das tatsächlich ausgeliefert wird:

```bash
openssl s_client -connect <domain>:5222 -starttls xmpp -xmpphost <domain> </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

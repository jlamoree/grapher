#!/usr/bin/env bash
le_data="/etc/letsencrypt/live/{{ certbot_domain }}"
tls_combo="/etc/pki/tls/private/{{ certbot_domain }}-combo.pem"

podman run -it --rm --volume /etc/letsencrypt:/etc/letsencrypt:z \
  --volume /var/log/letsencrypt:/var/log/letsencrypt:z \
  --volume /var/lib/letsencrypt:/var/lib/letsencrypt:z \
  --env AWS_CONFIG_FILE=/var/lib/letsencrypt/.aws/config \
  --env AWS_SHARED_CREDENTIALS_FILE=/var/lib/letsencrypt/.aws/credentials \
  docker.io/certbot/dns-route53:v1.27.0 \
  certonly \
  --non-interactive --agree-tos --email "{{ certbot_email }}" \
  --dns-route53 \
  -d "{{ certbot_domain }}"

cat "${le_data}/fullchain.pem" "${le_data}/privkey.pem" > "$tls_combo"
chmod 440 "$tls_combo"
chown root:haproxy "$tls_combo"
semanage fcontext -a -t etc_t "$tls_combo"
restorecon -v "$tls_combo"

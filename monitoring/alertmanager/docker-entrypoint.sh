#!/bin/ash

cat > /etc/alertmanager/config.yml <<EOF
global:
  slack_api_url: $ALERTMANAGER_SLACK_API_URL

route:
  receiver: 'default'

receivers:
- name: 'default'
  slack_configs:
  - channel: '#aleksandr_loktionov'
  email_configs:
  - to: gcpaleksandrloktionov@gmail.com
    smarthost: smtp.mailgun.org:2525
    from: alertmanager@example.com
    auth_username: $ALERTMANGER_EMAIL_AUTH_USERNAME
    auth_password: $ALERTMANGER_EMAIL_AUTH_PASSWORD
EOF

exec "$@"

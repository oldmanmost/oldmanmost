#!/bin/bash

# Устанавливаем Xray
echo "Устанавливаем Xray..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Генерируем ключи
echo "Генерируем ключи..."
UUID=$(xray uuid)
KEYS=$(xray x25519)
PRIVATE_KEY=$(echo "$KEYS" | grep "Private key:" | awk '{print $3}')
PUBLIC_KEY=$(echo "$KEYS" | grep "Public key:" | awk '{print $3}')
SHORT_ID=$(openssl rand -hex 8)

# IPv6 адрес сервера
SERVER_IP="2a12:4045:7344:4c34::1"

# Создаём конфиг
cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "tag": "vless-reality-ipv6",
      "listen": "::",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          { "id": "$UUID", "flow": "xtls-rprx-vision", "email": "main_device" }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "target": "www.kernel.org:443",
          "serverNames": ["www.kernel.org"],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": ["$SHORT_ID"],
          "maxTimeDiff": 0
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "routeOnly": true
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct", "settings": { "domainStrategy": "UseIPv6" } }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      { "type": "field", "protocol": ["bittorrent"], "outboundTag": "block" },
      { "type": "field", "ip": ["geoip:private"], "outboundTag": "block" }
    ]
  }
}
EOF

# Перезапускаем Xray
systemctl restart xray

# Выводим финальную ссылку
echo ""
echo "=========================================="
echo "ВСЁ ГОТОВО! Скопируй эту ссылку в Hiddify:"
echo "=========================================="
echo "vless://$UUID@[$SERVER_IP]:443?type=tcp&security=reality&pbk=$PUBLIC_KEY&fp=chrome&sni=www.kernel.org&sid=$SHORT_ID&flow=xtls-rprx-vision#Reality-IPv6"
echo "=========================================="

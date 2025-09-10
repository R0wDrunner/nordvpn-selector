#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <country_code> <protocol> <action>"
    echo "Example: $0 DE udp connect"
    exit 1
fi

COUNTRY_CODE=$1
PROTOCOL=$2
ACTION=$3

if [ "$ACTION" != "connect" ]; then
    echo "Unsupported action: $ACTION"
    echo "Only 'connect' is supported for now."
    exit 1
fi

RECOMMENDATION_URL="https://api.nordvpn.com/v1/servers/recommendations?country_code=${COUNTRY_CODE}&limit=1"

API_RESPONSE=$(curl -s "$RECOMMENDATION_URL")
echo "API Response: $API_RESPONSE" # Print the full API response for debugging

HOSTNAME=$(echo "$API_RESPONSE" | jq -r '.[0].hostname')

if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" == "null" ]; then
    echo "Failed to retrieve hostname for country code: $COUNTRY_CODE"
    echo "Ensure 'jq' is installed for proper JSON parsing. (sudo apt install jq)"
    exit 1
fi

echo "Recommended NordVPN server for $COUNTRY_CODE: $HOSTNAME"

OPENVPN_CONFIG_DIR=""
if [ "$PROTOCOL" == "udp" ]; then
    OPENVPN_CONFIG_DIR="/etc/openvpn/ovpn_udp"
elif [ "$PROTOCOL" == "tcp" ]; then
    OPENVPN_CONFIG_DIR="/etc/openvpn/ovpn_tcp"
else
    echo "Unsupported protocol: $PROTOCOL"
    echo "Please choose 'udp' or 'tcp'."
    exit 1
fi

CONFIG_FILE=$(find "$OPENVPN_CONFIG_DIR" -type f -name "${HOSTNAME}*.ovpn" 2>/dev/null | head -n 1)

if [ -z "$CONFIG_FILE" ]; then
    echo "OpenVPN configuration file not found for $HOSTNAME in $OPENVPN_CONFIG_DIR."
    echo "Please ensure the NordVPN configuration files are downloaded and placed in the correct directories."
    exit 1
fi

echo "Connecting to NordVPN using configuration: $CONFIG_FILE"
sudo openvpn --config "$CONFIG_FILE"

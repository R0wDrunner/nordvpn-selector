# nordvpn-selector
Simple bash script to select the recommended Server from NordVPN for the given country code, and connect to it via OpenVPN

## Features

*   Connects to the fastest recommended NordVPN server for a specified country
*   Supports both UDP and TCP protocols
*   Automates the process of finding and connecting to an OpenVPN configuration of NordVPN

Simple usage:
```bash
./nvpn.sh <country_code> <protocol> <command>
```

Example:
```bash
./nvpn.sh US udp connect
```

## How it works

Uses NordVPN's API Endpoint https://api.nordvpn.com/v1/servers/recommendations

Note: That Endpoint seems to be a bit lagging behind to the Nord's internal one https://my.nordaccount.com/api/v1/servers/recommendations - which is only usable with session tokens and not public

(It also uses IDs for the countries, which I was too lazy for)

## Recommendation
I also recommend adding an auth file somewhere, adding your Service Credentials from NordVPN through here:

https://my.nordaccount.com/dashboard/nordvpn/manual-configuration/service-credentials/

The file simply has to have the given "username" and password in one line each, and in your ovpn configurations you can modify the line containing `auth-user-pass` to be `auth-user-pass /path/to/your/auth`

An example one-liner to modify all .ovpn files in `/etc/openvpn/ovpn_udp/` and `/etc/openvpn/ovpn_tcp/` (assuming your auth file is at `/etc/openvpn/auth`):

```bash
sudo find /etc/openvpn/ovpn_* -type f -exec sed -i 's/^auth-user-pass$/auth-user-pass \/etc\/openvpn\/auth/' {} \;
```

This command simply replaces the literal string `auth-user-pass` (at the beginning of a line) with `auth-user-pass /etc/openvpn/auth` in all found configuration files

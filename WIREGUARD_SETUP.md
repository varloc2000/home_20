# WireGuard + SLZB-06MU Setup Guide

## Current Issue
- SLZB device reports "Remote peer is offline"
- WireGuard handshake not completing
- Zigbee2MQTT can't reach device

## Fixed Configuration

### 1. Updated Files
- ✅ `.env` - Changed device IP from `192.168.0.231` to `10.8.0.2`
- ✅ `.env` - Uncommented WireGuard credentials
- ✅ `docker-compose.prod.yml` - Added routing rules and persistent keepalive

### 2. Deploy Updated Configuration

```bash
# On Hetzner server
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Create SLZB Client in WireGuard

1. Access WireGuard admin panel: `https://vpn.home20.run.place`
2. Login with password from `CI_VPN_ADMIN_PASSWORD`
3. Create a new client named "SLZB-06MU"
4. **Important**: The client should get IP `10.8.0.2`
5. Download or note the client configuration

### 4. Configure SLZB Device

In your SLZB-06MU web interface:

**WireGuard Settings:**
- **Enabled**: ✅ Yes
- **Server Endpoint**: `46.224.211.0:51820`
- **Server Public Key**: (from WireGuard admin panel)
- **Client Private Key**: (from generated config)
- **Client IP Address**: `10.8.0.2/24`
- **Allowed IPs**: `0.0.0.0/0` ⚠️ NOT `0.0.0.0, 0.0.0.0`
- **Persistent Keepalive**: `25` seconds

**Network Settings:**
- Keep your LAN mode enabled
- TCP Server Port: `6638`

### 5. Verify Connection

**Check WireGuard logs:**
```bash
docker logs wg-easy
```

**Check Zigbee2MQTT logs:**
```bash
docker logs zigbee2mqtt
```

**Test connectivity from server to SLZB:**
```bash
docker exec -it zigbee2mqtt ping 10.8.0.2
docker exec -it zigbee2mqtt nc -zv 10.8.0.2 6638
```

### 6. Common Issues

#### "Remote peer is offline"
- Check server IP is correct: `46.224.211.0`
- Verify port 51820/udp is open on Hetzner firewall
- Check WireGuard public key matches server

#### Handshake but no connectivity
- Verify Allowed IPs is `0.0.0.0/0` (with slash zero)
- Check persistent keepalive is set (25 seconds)
- Ensure SLZB IP is exactly `10.8.0.2`

#### Zigbee2MQTT can't connect
- Verify serial port: `tcp://10.8.0.2:6638`
- Check SLZB TCP server is enabled on port 6638
- Test: `telnet 10.8.0.2 6638` from zigbee2mqtt container

## Expected Result

When working correctly, SLZB logs should show:
```
WG | WireGuard connection started
WG | Handshake completed
WG | Peer is online
```

Zigbee2MQTT logs should show:
```
Zigbee2MQTT:info  Starting Zigbee2MQTT version...
Zigbee2MQTT:info  Connecting to MQTT server at mqtt://localhost:1883
Zigbee2MQTT:info  Connected to MQTT server
```

## Network Diagram

```
SLZB-06MU (Home)          Hetzner Server
   10.8.0.2          <-->    10.8.0.1
      |                          |
   WireGuard VPN (10.8.0.0/24)  |
                                 |
                        +-----------------+
                        |   wg-easy       |
                        |   traefik-net   |
                        +-----------------+
                                 |
                        +-----------------+
                        | zigbee2mqtt     |
                        | homeassistant   |
                        | mosquitto       |
                        +-----------------+
```

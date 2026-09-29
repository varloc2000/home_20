#!/bin/bash
# WireGuard + SLZB Connection Checker

echo "🔍 Checking WireGuard + SLZB Connection..."
echo ""

# Check if running on server
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Run this on your Hetzner server."
    exit 1
fi

# Check WireGuard container
echo "1️⃣ Checking WireGuard container..."
if docker ps | grep -q wg-easy; then
    echo "✅ wg-easy is running"
    echo "   Last 5 log lines:"
    docker logs wg-easy --tail 5 2>&1 | sed 's/^/   /'
else
    echo "❌ wg-easy is not running"
    echo "   Run: docker-compose -f docker-compose.prod.yml up -d wg-easy"
fi
echo ""

# Check port 51820
echo "2️⃣ Checking UDP port 51820..."
if ss -ulnp | grep -q 51820; then
    echo "✅ Port 51820/udp is listening"
    ss -ulnp | grep 51820 | sed 's/^/   /'
else
    echo "❌ Port 51820/udp is not listening"
fi
echo ""

# Check WireGuard interface
echo "3️⃣ Checking WireGuard interface..."
if docker exec wg-easy wg show 2>/dev/null | grep -q interface; then
    echo "✅ WireGuard interface configured"
    docker exec wg-easy wg show 2>/dev/null | head -20 | sed 's/^/   /'
else
    echo "⚠️  WireGuard interface not found or no peers"
fi
echo ""

# Check Zigbee2MQTT container
echo "4️⃣ Checking Zigbee2MQTT container..."
if docker ps | grep -q zigbee2mqtt; then
    echo "✅ zigbee2mqtt is running"
    echo "   Serial port config:"
    docker exec zigbee2mqtt cat /app/data/configuration.yaml 2>/dev/null | grep -A 2 "serial:" | sed 's/^/   /'
else
    echo "❌ zigbee2mqtt is not running"
fi
echo ""

# Test connectivity to SLZB
echo "5️⃣ Testing connection to SLZB (10.8.0.2:6638)..."
if docker exec zigbee2mqtt timeout 3 nc -zv 10.8.0.2 6638 2>&1 | grep -q succeeded; then
    echo "✅ Can connect to SLZB on 10.8.0.2:6638"
else
    echo "❌ Cannot connect to SLZB on 10.8.0.2:6638"
    echo "   Trying ping..."
    if docker exec zigbee2mqtt timeout 3 ping -c 2 10.8.0.2 2>&1 | grep -q "bytes from"; then
        echo "   ✅ Can ping 10.8.0.2 (device is reachable)"
        echo "   ⚠️  But TCP port 6638 is not responding"
        echo "   → Check SLZB TCP server is enabled"
    else
        echo "   ❌ Cannot ping 10.8.0.2"
        echo "   → WireGuard peer not connected"
    fi
fi
echo ""

# Check environment variables
echo "6️⃣ Checking environment variables..."
if [ -f .env ]; then
    echo "✅ .env file found"
    echo "   CI_DEVICE_IP: $(grep CI_DEVICE_IP .env | cut -d'=' -f2)"
    echo "   CI_DEVICE_PORT: $(grep CI_DEVICE_PORT .env | cut -d'=' -f2)"
    echo "   CI_SSH_HOST: $(grep CI_SSH_HOST .env | grep -v '^#' | cut -d'=' -f2)"
else
    echo "❌ .env file not found"
fi
echo ""

# Summary
echo "📋 Next Steps:"
echo "   1. Ensure SLZB WireGuard config has:"
echo "      - Server: 46.224.211.0:51820"
echo "      - Client IP: 10.8.0.2/24"
echo "      - Allowed IPs: 0.0.0.0/0"
echo "      - Keepalive: 25"
echo ""
echo "   2. Check WireGuard admin panel: https://vpn.home20.run.place"
echo "   3. Verify SLZB client is created and active"
echo "   4. Check Zigbee2MQTT logs: docker logs zigbee2mqtt -f"

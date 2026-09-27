# Home Assistant + Mosquitto + Zigbee2MQTT Stack

Production-ready Docker Compose configuration running **Home Assistant**, **Mosquitto MQTT Broker**, and **Zigbee2MQTT** in host network mode.

## 🚀 Service Architecture

* **Home Assistant Core**: Smart home hub (`http://localhost:8123`)
* **Mosquitto**: Local MQTT broker (`ports: 1883, 9001`)
* **Zigbee2MQTT**: Zigbee bridge & management UI (`http://localhost:8085`)

---

## 📁 Repository Structure

```text
.
├── docker-compose.yml
├── .gitignore
├── homeassistant/
│   └── config/
│       ├── configuration.yaml
│       └── automations.yaml
├── mosquitto/
│   └── config/
│       └── mosquitto.conf
└── zigbee2mqtt/
    └── data/
        ├── configuration.yaml
        └── secret.yaml         # Ignored by Git (contains adapter IP)

## Quick Start

### 1. Clone repository
git clone <repository-url> ~/homeassistant
cd ~/homeassistant

### 2. Create local secrets
cat <<EOF> zigbee2mqtt/data/secret.yaml
adapter_port: tcp://YOUR_ADAPTER_IP:6638
EOF

### 3. Start services
docker compose up -d
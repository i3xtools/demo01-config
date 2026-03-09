# Demo 01 — CNC Job Shop

ISA-95 structured demo: ERP database + 2 MTConnect CNC machines merged into a single i3X API.

## Architecture

```
nginx (reverse proxy)
  │
  └── i3xag :9000 (aggregator)
        ├── i3xdb :8080    ← SQLite ERP database (ISA-95 hierarchy)
        ├── i3xmt-okuma    ← Okuma LB3000 lathe (MTConnect/MQTT)
        └── i3xmt-mazak    ← Mazak INTEGREX i-200 5-axis (MTConnect/MQTT)
```

i3xag reparents the MTConnect device trees under the ERP equipment records:

```
Precision Parts MFG (Enterprise)
└── Main Plant (Site)
    ├── Turning Department (Area)
    │   └── CNC Lathes (WorkCenter)
    │       └── CL-01 Okuma LB3000 (Equipment)     ← from i3xdb
    │           └── OKUMA (Device)                  ← from i3xmt, reparented here
    │               ├── Controller
    │               ├── Axes (Linear, Rotary)
    │               └── ...
    ├── Milling Department (Area)
    │   └── 5-Axis Machining (WorkCenter)
    │       └── 5AX-01 Mazak INTEGREX (Equipment)   ← from i3xdb
    │           └── MAZAK (Device)                   ← from i3xmt, reparented here
    │               ├── Controller
    │               ├── Axes (Linear, Rotary)
    │               └── ...
    └── Quality Lab (Area)
        └── CMM-01 Zeiss Contura (Equipment)
```

## Directory structure

```
demo01-config/
├── docker-compose.yml
├── .env.example
└── volumes/
    ├── i3xdb/
    │   ├── config.yaml          # i3xdb mapping (exported from desktop app)
    │   └── precision_cnc.db     # SQLite database
    ├── i3xmt/
    │   ├── okuma-config.yaml    # i3xmt mapping (exported from desktop app)
    │   └── mazak-config.yaml    # i3xmt mapping (exported from desktop app)
    └── i3xag/
        └── config.yaml          # aggregator config with reparent rules
```

## Setup

```bash
cp .env.example .env
# Edit .env with your MQTT broker address and device UUIDs
docker compose up -d
```

The aggregated API is available at `http://localhost:9000`.

## ERP Database

SQLite with 12 tables following ISA-95:

| Table | Role | Rows |
|-------|------|------|
| enterprises | Enterprise | 1 |
| sites | Site | 1 |
| areas | Area | 3 |
| work_centers | Work Center | 3 |
| equipment | Work Unit | 3 |
| customers | Customer | 3 |
| materials | Material | 4 |
| parts | Part Catalog | 5 |
| personnel | Personnel | 5 |
| job_orders | Work Order | 5 |
| operations | Op Segment | 15 |
| quality_inspections | QA | 3 |

## i3xmt configs

The `okuma-config.yaml` and `mazak-config.yaml` files should be exported from the i3xmt desktop app after connecting to the MQTT broker and mapping the device model. If omitted, i3xmt auto-discovers the device model from MTConnect Probe messages.

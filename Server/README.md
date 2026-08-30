# Couchbase Mobile Sync Server

An automated, 100% open-source, offline-first backend stack featuring **Couchbase Server Community Edition**, **Sync Gateway**, and an automated cluster initialization container managed via **Docker Compose**.

---

## 🚀 Quick Start / Deployment

Deploying the stack requires copying the environment configuration file, setting your credentials, and starting the containers.

```bash
# 1. Clone the repository and navigate to the project directory
cd Server

# 2. Copy sample.env to create your local .env file
cp sample.env .env

# 3. Edit .env and customize your admin credentials
nano .env

# 4. Make the initialization script executable
chmod +x init-couchbase.sh

# 5. Launch the stack in detached mode
docker compose up -d

```

To monitor initialization logs and service health:

```bash
docker compose logs -f couchbase-init

```

---

## 📦 System Components

The stack consists of three main containers orchestrated under the unified `couchbase` Docker network namespace:

* **`couchbase-server`** (`couchbase:community-7.6.2`)
The core persistence engine storing JSON documents, managing spatial indexes, and serving queries.
* **`couchbase-init`** (`couchbase:community-7.6.2`)
An ephemeral provisioning container. On initial startup, it waits for `couchbase-server` to become reachable, initializes the cluster, configures RAM quotas, and creates the `default` bucket using `.env` credentials before exiting.
* **`sync-gateway`** (`couchbase/sync-gateway:3.1.0-community`)
The secure, mobile-facing synchronization layer. It exposes HTTP and WebSocket endpoints to process delta syncs, access control, and bi-directional replication with client devices running Couchbase Lite.

---

## 🏗️ Architecture & Network Topography

All components communicate over an isolated bridge network (`couchbase_net`). Below is the port layout and internal/external traffic flow:

```
                  +-------------------------------------------------+
                  |                   HOST NETWORK                  |
                  +-------------------------------------------------+
                                |                     |
                  (Public WebSocket/REST)             (Admin UI)
                            :4984                       :8091
                                |                     |
+-------------------------------|---------------------|-------------------+
| couchbase_net                 v                     v                   |
|                      +------------------+  +------------------+         |
|                      |   sync-gateway   |  | couchbase-server |         |
|                      +------------------+  +------------------+         |
|                                |                     ^                  |
|                                |   Internal Traffic  |                  |
|                                +---------------------+                  |
|                                     Ports 8091/11210                    |
|                                                                         |
|                      +------------------+                               |
|                      |  couchbase-init  |-----(Runs once at startup)----+
|                      +------------------+                               |
+-------------------------------------------------------------------------+

```

### Port Mapping Reference

| Service | Port | Traffic Type | Description |
| --- | --- | --- | --- |
| **Sync Gateway** | `4984` | External / Public | Client Replication & Public REST API (WebSockets) |
| **Sync Gateway** | `4985` | Host / Restricted | Admin REST API |
| **Couchbase Server** | `8091` | Host / Public | Web Administration Console & Cluster Management API |
| **Couchbase Server** | `11210` | Internal Network | Direct Memcached/Data Service Port (used by Sync Gateway) |

---

## 🛠️ Customization & Configuration

### 1. Credentials (`.env`)

Store sensitive environment variables locally. Ensure `.env` is never committed to source control.

```ini
COUCHBASE_ADMIN_USER=Administrator
COUCHBASE_ADMIN_PASSWORD=YourSecurePassword123!

```

### 2. Auto-Provisioning (`init-couchbase.sh`)

Customize this script to adjust initial database resource allocations, bucket configurations, or additional indexing options:

* **RAM Quotas:** Adjust `--cluster-ramsize` and `--bucket-ramsize` depending on host hardware constraints.
* **Bucket Settings:** Rename the bucket or add primary indexes post-creation.

### 3. Sync & Access Control (`sync-gateway-config.json`)

Modify routing rules, channels, user authentication, and data access policies:

* **Channels & Sync Function:** Update the JavaScript `sync` function to implement document-level read/write authorization rules.
* **Authentication:** Transition from default `GUEST` user access to JWT token authentication or basic user credentials for production environments.

```

<ElicitationsGroup message="Would you like any adjustments to this README or help with production readiness?">
  <Elicitation label="Add sample.env template code" query="Show me the sample.env template file contents."/>
  <Elicitation label="Configure SSL/TLS certificates for production" query="How do I configure SSL/TLS certificates for Couchbase Sync Gateway in production?"/>
</ElicitationsGroup>

```
#!/bin/bash
set -e

echo "Waiting for Couchbase Server to be reachable..."
until curl -s http://couchbase-server:8091/ui/index.html > /dev/null; do
  sleep 3
done

echo "Attempting cluster initialization..."
if ! couchbase-cli cluster-init -c couchbase-server:8091 \
    --cluster-username "$COUCHBASE_ADMIN_USER" \
    --cluster-password "$COUCHBASE_ADMIN_PASSWORD" \
    --services data,index,query \
    --cluster-ramsize 1024 \
    --cluster-index-ramsize 256 \
    --index-storage-setting default; then
  echo "Cluster already initialized or initialization failed, continuing..."
fi

echo "Creating 'default' bucket..."
if ! couchbase-cli bucket-create -c couchbase-server:8091 \
    --username "$COUCHBASE_ADMIN_USER" \
    --password "$COUCHBASE_ADMIN_PASSWORD" \
    --bucket default \
    --bucket-type couchbase \
    --bucket-ramsize 512; then
  echo "Bucket 'default' already exists, continuing..."
fi

echo "Creating dedicated RBAC user for Sync Gateway..."
couchbase-cli user-manage -c couchbase-server:8091 \
    --username "$COUCHBASE_ADMIN_USER" \
    --password "$COUCHBASE_ADMIN_PASSWORD" \
    --set \
    --rbac-username "$COUCHBASE_SYNC_USER" \
    --rbac-password "$COUCHBASE_SYNC_PASSWORD" \
    --roles bucket_full_access[default] \
    --auth-domain local

echo "Couchbase initialization complete!"

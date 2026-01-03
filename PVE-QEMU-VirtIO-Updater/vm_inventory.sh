#!/bin/env bash

# Invoentory of VMs on the ProxmoxVE Cluster
windows_vms=$(get_windows_vms)
if [[ -z "$windows_vms" || "$windows_vms" == "{}" ]]; then
    log_info "No Windows VMs found in the ProxmoxVE cluster."
    exit 0
fi

# Check if all found Windows VMs exist in JSON inventory
for vmid in $(echo "$windows_vms" | jq -r '
    .[] | .vmid'); do
    if ! jq -e --arg vmid "$vmid" '.vms[] | select(.vmid == ($vmid | tonumber))' "$INVENTORY_FILE" >/dev/null; then
        # ToDo: Add Logic to fetch VM details and create new json entry for the VM
    fi
done
function get_windows_vms() {
    # List all nodes in the cluster
    for node in $(pvesh get /nodes --output-format json | jq -r '.[].node'); do
      echo "Node: $node"

      # List all QEMU VMs on this node
      pvesh get /nodes/$node/qemu --output-format json |
        jq -r '.[].vmid' |
        while read vmid; do
          # Get VM config and extract ostype and name
          cfg=$(pvesh get /nodes/$node/qemu/$vmid/config --output-format json)
          ostype=$(jq -r '.ostype // empty' <<<"$cfg")
          name=$(jq -r '.name // empty' <<<"$cfg")

          # Match Windows types (win10, win11, w2k8, w2k3, etc.)
          if [[ "$ostype" =~ ^w(2k|in) || "$ostype" == "wxp" || "$ostype" == "wvista" ]]; then
            echo "  VMID: $vmid  Name: $name  OSType: $ostype"
          fi
        done
    done
}

function get_windows_virtio_version() {
    local node=$1
    local vmid=$2
    # Use guest-agent to get the VirtIO driver version inside the Windows VM
    version=$(qm guest exec $vmid --cmd "powershell -Command \"(Get-WmiObject Win32_PnPSignedDriver | Where-Object { \$_.DeviceName -like '*VirtIO*' } | Select-Object -First 1).DriverVersion\"" 2>/dev/null | tr -d '\r')
    echo "$version"
}

function test_vm_gh_connection() {
    local node=$1
    local vmid=$2
    # Test if the VM can reach GitHub
    result=$(qm guest exec $vmid --cmd "powershell -Command \"try { \$response = Invoke-WebRequest -Uri 'https://api.github.com' -UseBasicParsing -TimeoutSec 5; if (\$response.StatusCode -eq 200) { Write-Output 'Success' } else { Write-Output 'Fail' } } catch { Write-Output 'Fail' }\"" 2>/dev/null | tr -d '\r')
    echo "$result"
}

function update_vm_description_with_virtio_update_nag() {
    local node=$1
    local vmid=$2
    
    current_vm_config=$(pvesh get /nodes/$node/qemu/$vmid/config --output-format json)
    
    current_description=$(echo "$current_vm_config" | jq -r '.description // empty')
    
    update_banner='<img src="/pve2/images/virtio-update-'$vmid'.svg" alt="VirtIO Update" />'
    
    # Check if description exists and is not empty
    if [ -z "$current_description" ] || [ "$current_description" = "null" ]; then
        # No existing description, just set the banner
        new_description="$update_banner"
    else
        # Check if banner already exists to avoid duplicates
        if echo "$current_description" | grep -q "virtio-update"; then
            echo "Update banner already present in VM $vmid"
            return 0
        fi
        
        # Prepend banner to existing description with separator
        new_description="${update_banner}<hr/>${current_description}"
    fi
    
    # Update the description (escape quotes properly)
    qm set $vmid -description "$new_description"
    
    log_info "Updated description for VM $vmid with VirtIO update nag."
}

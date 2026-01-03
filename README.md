# PVE-QEMU-VirtIO-Updater

[![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Proxmox](https://img.shields.io/badge/Proxmox-VE-orange.svg)](https://www.proxmox.com/)

Keep your VirtIO drivers and QEMU Guest Agent up to date on Proxmox VE. Inspired by how vCenter shows "VMware Tools update available"

## What is this?

I got tired of manually checking if my Windows VMs on Proxmox had outdated VirtIO drivers. VMware's vCenter does this elegantly with a nice warning in the VM Overview, so I decided to build something similar for ProxmoxVE.

## Current Status

⚠️ **Work in Progress** - I'm building this as I have time.

**What works:**
- PowerShell updater script for VirtIO
- SVG update notifications in Proxmox (Kind of 🙃)
- PVE description updates (won't (shouldn't) break your existing VM notes) -> Prepend Notification Banner

## Quick Start

### Option 1: Update from inside a Windows VM

```powershell
# Just run this in PowerShell 7
.\updater-win.ps1

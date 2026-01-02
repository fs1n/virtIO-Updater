#!/bin/env bash

function check_script_dependencies() {
    local dependencies=( "curl" "jq")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: $dep is not installed." >&2
            return 1
        fi
    done
    return 0
}
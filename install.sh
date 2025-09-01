#!/bin/bash

KLIPPER_PATH="${HOME}/klipper"
INSTALL_PATH="${HOME}/klipper-backups"
CONFIG_PATH="${HOME}/printer_data"

set -eu
export LC_ALL=C

function preflight_checks {
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

function check_download {
    local installdirname installbasename
    installdirname="$(dirname ${INSTALL_PATH})"
    installbasename="$(basename ${INSTALL_PATH})"

    if [ ! -d "${INSTALL_PATH}" ]; then
        echo "[DOWNLOAD] Downloading repository..."
        if git -C $installdirname clone https://github.com/SAinc/klipper-backups.git $installbasename; then
            chmod +x ${INSTALL_PATH}/install.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] repository already found locally. Continuing...\n\n"
    fi
}

function link_config {
    echo "[INSTALL] Linking configs to Klipper..."
    # for file in "${INSTALL_PATH}"/config; do ln -sfn "${file}" "${CONFIG_PATH}"; done
    ln -sfn "${INSTALL_PATH}/config" "${CONFIG_PATH}/"
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}

# Run steps
preflight_checks
check_download
link_config
restart_klipper
#!/bin/bash

# Get the directory where this script is located
CONFIG_DIR="$(dirname "$(realpath "$0")")"
MIN_LOOP_DEVICE=50  # Minimum allowed loop device number

# Function to validate a config file
validate_config() {
    local file="$1"
    source "$file"

    if [[ -z "$IMAGE_FILE" || -z "$LOOP_DEVICE" || -z "$MOUNT_POINT" ]]; then
        echo "Skipping $file: Missing IMAGE_FILE, LOOP_DEVICE, or MOUNT_POINT"
        return 1
    fi

    # Ensure IMAGE_FILE exists
    if [[ ! -f "$IMAGE_FILE" ]]; then
        echo "Skipping $file: IMAGE_FILE ($IMAGE_FILE) does not exist"
        return 1
    fi

    # Ensure MOUNT_POINT exists
    if [[ ! -d "$MOUNT_POINT" ]]; then
        echo "Skipping $file: MOUNT_POINT ($MOUNT_POINT) does not exist"
        return 1
    fi

    # Extract numeric part of LOOP_DEVICE (e.g., "77" from "/dev/loop77")
    local loop_number
    loop_number=$(echo "$LOOP_DEVICE" | grep -oP '(?<=/dev/loop)\d+')

    # Ensure it's a valid number and meets the minimum requirement
    if [[ -z "$loop_number" || "$loop_number" -lt "$MIN_LOOP_DEVICE" ]]; then
        echo "Skipping $file: LOOP_DEVICE ($LOOP_DEVICE) must be /dev/loopX where X is a non-negative number >= $MIN_LOOP_DEVICE"
        return 1
    fi

    return 0
}

# Function to setup a loop device
setup_loop_device() {
    local loop_device="$1"
    local image_file="$2"

    if losetup | grep -q "$loop_device"; then
        echo "$loop_device is already assigned"
    else
        echo "Setting up $loop_device for $image_file"
        losetup "$loop_device" "$image_file"
    fi
}

# Function to mount the filesystem
mount_fs() {
    local loop_device="$1"
    local mount_point="$2"

    if mount | grep -q "$mount_point"; then
        echo "$mount_point is already mounted"
    else
        echo "Mounting $loop_device to $mount_point"
        mount "$loop_device" "$mount_point"
    fi
}

# Function to unmount the filesystem
unmount_fs() {
    local mount_point="$1"

    if mount | grep -q "$mount_point"; then
        echo "Unmounting $mount_point"
        umount "$mount_point"
    else
        echo "$mount_point is not mounted"
    fi
}

# Function to release the loop device
release_loop_device() {
    local loop_device="$1"

    if losetup | grep -q "$loop_device"; then
        echo "Releasing loop device $loop_device"
        losetup -d "$loop_device"
    fi
}

case "$1" in
    start)
        for file in "$CONFIG_DIR"/*.req; do
            [ -f "$file" ] || continue

            if validate_config "$file"; then
                setup_loop_device "$LOOP_DEVICE" "$IMAGE_FILE"
                mount_fs "$LOOP_DEVICE" "$MOUNT_POINT"
            fi
        done
        ;;
    
    stop)
        for file in "$CONFIG_DIR"/*.req; do
            [ -f "$file" ] || continue

            if validate_config "$file"; then
                unmount_fs "$MOUNT_POINT"
                release_loop_device "$LOOP_DEVICE"
            fi
        done
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac


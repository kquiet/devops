#!/bin/bash

usage() {
    echo "Usage: $0 <remote_proxy_ip> <remote_proxy_port> <remote_proxy_open_port>"
    echo "<remote_proxy_ip>: Required. remote proxy ip."
    echo "<remote_proxy_port>: Required. remote proxy port."
    echo "<remote_proxy_open_port>: Required. remote proxy port to open."
}

# Check if the correct number of parameters is supplied
if [ $# -ne 3 ]; then
    echo "Error: Incorrect number of parameters."
    usage
    exit 1
fi

REMOTE_PROXY_IP=$1
REMOTE_PROXY_PORT=$2
REMOTE_PROXY_OPEN_PORT=$3

# Function to check if any network (Wi-Fi or Ethernet) is connected
is_network_connected() {
    local wifi_device=$(nmcli -t -f type,device,state dev | grep -E '^wifi:.*:connected$' | cut -d: -f2)
    local wifi_ssid=$(nmcli -t -f type,connection,state dev | grep '^wifi:.*:connected$' | cut -d: -f2)
    local ethernet_device=$(nmcli -t -f type,device,state dev | grep '^ethernet:.*:connected$' | cut -d: -f2)
    local is_any_device_connected=1
    if [ -n "$wifi_device" ]; then
        echo "Wi-Fi connected: $wifi_device, SSID: $wifi_ssid"
        is_any_device_connected=0
        try_login_wifi_zoo_guest "$wifi_ssid"
    fi
    if [ -n "$ethernet_device" ]; then
        echo "Ethernet connected: $ethernet_device"
        is_any_device_connected=0
    fi
    return $is_any_device_connected
}


last_login=0
execution_count=0
time_limit=60  # in seconds
max_executions=2
try_login_wifi_zoo_guest() {
    local wifi_ssid="$1"  # Capture the first argument as input_string
    if [[ "${wifi_ssid,,}" =~ ^zoo-guest ]]; then
        echo "Current wifi is zoo-guest, continue to try_login_wifi_zoo_guest..."
    else
        echo "Current wifi is not zoo-guest, exit try_login_wifi_zoo_guest"
        return 1
    fi
    
    current_time=$(date +%s)  # Get the current time in seconds since the epoch
    time_diff=$((current_time - last_login))
    echo "time_limit=$time_limit,max_executions=$max_executions,last_login:$last_login,execution_count=$execution_count,time_diff=$time_diff"

    if (( time_diff >= time_limit )); then
        # Reset the counter if the time limit has passed
        execution_count=0
        last_login=$current_time
    fi

    if (( execution_count < max_executions )); then
        # Execute the function logic
        echo "Trying to login zoo-guest..."
        curl -L -k -X POST https://guestwifi.zoo.internal/login.html -d "buttonClicked=4&err_flag=0&err_msg=&info_flag=0&info_msg=&redirect_url=http%3A%2F%2Fnmcheck.gnome.org&network_name=Guest+Network&username=79ac&password=79ac"

        # Update the counter and last execution time
        execution_count=$((execution_count + 1))
        last_login=$current_time
        return 0
    else
        echo "Login attempt skipped to comply with rate limit."
        return 1
    fi
}


# Function to handle termination signals
handle_termination() {
    echo "Stopping SSH command..."
    # terminate all child processes of this script
    pkill -P $$
    # Wait for the main process to terminate gracefully
    for i in {1..15}; do
        if ! kill -0 $pid 2>/dev/null; then
            echo "SSH command stopped gracefully"
            exit
        fi
        sleep 1
    done
    # Force kill all processes if main process did not terminate gracefully
    echo "Force killing SSH command..."
    pkill -9 -P $$
    wait $pid
    exit
}


# Trap termination signals and call handle_termination function
trap handle_termination SIGTERM SIGINT SIGQUIT

# Loop to check network status and run SSH command when connected
while true; do
    if is_network_connected; then
        echo "Establishing SSH remote port forward..."
        ssh -v -i /home/devops/.ssh/id_rsa_devops_inter -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -NR "127.0.0.1:$REMOTE_PROXY_OPEN_PORT:localhost:22" -p "$REMOTE_PROXY_PORT" "devops_inter@$REMOTE_PROXY_IP" 2>&1  | (
            while read -r line; do
                echo "$line"  # for logging
                
                # Check if the line contains the warning
                if echo "$line" | grep -q "remote port forwarding failed for listen port $REMOTE_PROXY_OPEN_PORT"; then
                    echo "Detected port forwarding failed. Exiting SSH command now..."
                    kill $! # won't trigger trap handler in this script file as it sends SIGTERM to the background process spawned in the script
                    break  # Exit the loop to allow retrying
                fi
            done
        ) &
        pid=$!
        wait $!
        echo "SSH command exited. Retrying in 15 seconds..."
    else
        echo "No network connection. Checking again in 15 seconds..."
    fi
    sleep 15
done

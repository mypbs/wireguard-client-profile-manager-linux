#!/bin/bash

# Directory containing WireGuard configuration files
WG_CONFIG_DIR="/etc/wireguard"
WG_CMD="wg-quick"

# Function to display the menu
show_menu() {
    echo "Available WireGuard connections:"
    echo "--------------------------------"
    local i=1
    for config in "$WG_CONFIG_DIR"/*.conf; do
        echo "$i) $(basename "${config%.conf}")"
        ((i++))
    done
    echo "0) Exit"
}

# Function to get the connection status
get_status() {
    local interface="$1"
    if sudo wg show "$interface" &> /dev/null; then
        echo "Connected"
    else
        echo "Disconnected"
    fi
}

# Function to connect to VPN
connect_vpn() {
    local interface="$1"
    echo "Starting WireGuard connection: $interface"
    sudo $WG_CMD up "$interface"
    echo "Connected to $interface"
    while true; do
        read -rp "Do you want to disconnect from $interface? (y/n): " action
        if [[ "$action" == "y" || "$action" == "Y" ]]; then
            disconnect_vpn "$interface"
            break
        elif [[ "$action" == "n" || "$action" == "N" ]]; then
            echo "Returning to main menu..."
            break
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
}

# Function to disconnect from VPN
disconnect_vpn() {
    local interface="$1"
    echo "Stopping WireGuard connection: $interface"
    sudo $WG_CMD down "$interface"
    echo "Disconnected from $interface"
    read -rp "Press Enter to return to the main menu..."
}

# Main loop
while true; do
    show_menu
    read -rp "Select a VPN to manage (1-$(ls "$WG_CONFIG_DIR"/*.conf | wc -l) or 0 to exit): " choice

    if [[ "$choice" -eq 0 ]]; then
        echo "Exiting."
        break
    fi

    # Get the selected configuration file name
    config_file=$(ls "$WG_CONFIG_DIR"/*.conf | sort | sed -n "${choice}p")
    
    if [[ -z "$config_file" ]]; then
        echo "Invalid selection. Please choose a number between 1 and $(ls "$WG_CONFIG_DIR"/*.conf | wc -l)."
        continue
    fi

    # Extract the interface name from the config file name
    interface_name=$(basename "$config_file" .conf)

    # Display current status
    status=$(get_status "$interface_name")
    echo "Current status of $interface_name: $status"

    if [[ "$status" == "Connected" ]]; then
        while true; do
            read -rp "Do you want to disconnect from $interface_name? (y/n): " action
            if [[ "$action" == "y" || "$action" == "Y" ]]; then
                disconnect_vpn "$interface_name"
                break
            elif [[ "$action" == "n" || "$action" == "N" ]]; then
                echo "Returning to main menu..."
                break
            else
                echo "Invalid input. Please enter 'y' or 'n'."
            fi
        done
    else
        read -rp "Do you want to connect to $interface_name? (y/n): " action
        if [[ "$action" == "y" || "$action" == "Y" ]]; then
            connect_vpn "$interface_name"
        fi
    fi

    echo # Add a blank line for better readability
done

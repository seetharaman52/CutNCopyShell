#!/bin/bash
function error_exit {
  echo "Error: $1" >&2
  exit 1
}

function install_filmux {
    cp filmux /usr/local/bin/ || error_exit "Failed to copy powerctl to /usr/local/bin."
	chmod +x /usr/local/bin/filmux || error_exit "Failed to set execute permissions on filmux."
	echo "filmux installed successfully to /usr/local/bin."
}

if [ -x /usr/local/bin/filmux ]; then
	echo "filmux is already installed."
 	exit 0
fi

echo "Run this script by 'sudo bash install.sh'"
read -p "Do you want to install filmux? (Yes | No): " user_input
user_input=$(echo "$user_input" | tr '[:lower:]' '[:upper:]')
if [ "$user_input" = "YES" ]; then
	install_filmux
elif [ "$user_input" = "NO" ]; then
	echo "You chose not to install filmux! Bye!"
	exit
else
	error_exit "Invalid input. Please 'Yes' or 'No'."
fi

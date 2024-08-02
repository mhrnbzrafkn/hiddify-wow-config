#!/bin/bash

# Colors for output
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
rest='\033[0m'

# Embedded JSON object
json='{
	"outbounds": [
      {
        "type": "selector",
        "tag": "select",
        "outbounds": [
          "auto",
          "Warp-IR",
          "Warp-Main"
        ],
        "default": "auto"
      },
      {
        "type": "urltest",
        "tag": "auto",
        "outbounds": [
          "Warp-IR",
          "Warp-Main"
        ],
        "url": "http://cp.cloudflare.com/",
        "interval": "10m0s",
        "idle_timeout": "1h40m0s"
      },
      {
        "type": "wireguard",
        "tag": "Warp-IR",
        "local_address": [
          "172.16.0.2/32",
          "2606:4700:110:8bb9:5be4:34a7:7c22:8b08/128"
        ],
        "private_key": "sP+drbIEBZjWP4Bf4yHdV9qypcF43Hh27HsGZMMer1E=",
        "server": "188.114.96.193",
        "server_port": 859,
        "peer_public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
        "reserved": "nU9D",
        "mtu": 1280,
        "fake_packets": "5-10"
      },
      {
        "type": "wireguard",
        "tag": "Warp-Main",
        "detour": "Warp-IR",
        "local_address": [
          "172.16.0.2/32",
          "2606:4700:110:828e:ca4a:fafb:c2e0:572a/128"
        ],
        "private_key": "wBEUS04DBgXp5FEGc8J71SjlFZLwxvW/T2e3vy4AmVE=",
        "server": "188.114.96.193",
        "server_port": 859,
        "peer_public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
        "reserved": "vwN0",
        "mtu": 1280,
        "fake_packets": "5-10"
      }
    ]
}'

# Detect CPU architecture
case "$(uname -m)" in
x86_64 | x64 | amd64)
	cpu=amd64
	;;
i386 | i686)
	cpu=386
	;;
armv8 | armv8l | arm64 | aarch64)
	cpu=arm64
	;;
armv7l)
	cpu=arm
	;;
*)
	echo "The current architecture is $(uname -m), not supported"
	exit 1
	;;
esac

# Download warpendpoint program
cfwarpIP() {
	if [[ ! -f "$PREFIX/bin/warpendpoint" ]]; then
		echo "Downloading warpendpoint program"
		if [[ -n $cpu ]]; then
			curl -L -o warpendpoint -# --retry 2 https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/$cpu
			cp warpendpoint $PREFIX/bin
			chmod +x $PREFIX/bin/warpendpoint
		fi
	fi
}

# Generate random IPv4 addresses
endipv4() {
	n=0
	iplist=100
	while true; do
		temp[$n]=$(echo 162.159.192.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
		temp[$n]=$(echo 162.159.193.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
		temp[$n]=$(echo 162.159.195.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
		temp[$n]=$(echo 188.114.96.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
		temp[$n]=$(echo 188.114.97.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
		temp[$n]=$(echo 188.114.98.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
		temp[$n]=$(echo 188.114.99.$(($RANDOM % 256)))
		n=$(($n + 1))
		if [ $n -ge $iplist ]; then
			break
		fi
	done
	while true; do
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 162.159.192.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 162.159.193.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 162.159.195.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 188.114.96.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 188.114.97.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 188.114.98.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
		if [ "$(echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u | wc -l)" -ge $iplist ]; then
			break
		else
			temp[$n]=$(echo 188.114.99.$(($RANDOM % 256)))
			n=$(($n + 1))
		fi
	done
}

# Process the IP results
endipresult() {
	echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u >ip.txt
	ulimit -n 102400
	chmod +x warpendpoint >/dev/null 2>&1
	if command -v warpendpoint &>/dev/null; then
		warpendpoint
	else
		./warpendpoint
	fi

	clear
	cat result.csv | awk -F, '$3!="timeout ms" {print} ' | sort -t, -nk2 -nk3 | uniq | head -11 | awk -F, '{print "Endpoint "$1" Packet Loss Rate "$2" Average Delay "$3}'
	Endip_v4=$(cat result.csv | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" | head -n 1)
	Endip_v6=$(cat result.csv | grep -oE "\[.*\]:[0-9]+" | head -n 1)
	delay=$(cat result.csv | grep -oE "[0-9]+ ms|timeout" | head -n 1)
	echo ""
	echo -e "${green}Results Saved in result.csv${rest}"
	echo ""
	if [ "$Endip_v4" ]; then
		echo -e "${purple}************************************${rest}"
		echo -e "${purple}*           ${yellow}Best IPv4:Port${purple}         *${rest}"
		echo -e "${purple}*                                  *${rest}"
		echo -e "${purple}*          ${cyan}$Endip_v4${purple}     *${rest}"
		echo -e "${purple}*           ${cyan}Delay: ${green}[$delay]        ${purple}*${rest}"
		echo -e "${purple}************************************${rest}"
	elif [ "$Endip_v6" ]; then
		echo -e "${purple}********************************************${rest}"
		echo -e "${purple}*          ${yellow}Best [IPv6]:Port                ${purple}*${rest}"
		echo -e "${purple}*                                          *${rest}"
		echo -e "${purple}* ${cyan}$Endip_v6${purple} *${rest}"
		echo -e "${purple}*           ${cyan}Delay: ${green}[$delay]               ${purple}*${rest}"
		echo -e "${purple}********************************************${rest}"
	else
		echo -e "${red} No valid IP addresses found.${rest}"
	fi
	rm warpendpoint >/dev/null 2>&1
	rm -rf ip.txt
}

# Update config file with the new server details
update_config() {
    local new_server=$1
    local new_server_port=$2

    # Use jq to update the JSON
    echo "$json" | jq --arg new_server "$new_server" --argjson new_server_port "$new_server_port" \
    '.outbounds[2].server = $new_server | .outbounds[2].server_port = $new_server_port | .outbounds[3].server = $new_server | .outbounds[3].server_port = $new_server_port'

    # Check if jq command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to update JSON object."
        exit 1
    fi
}

# Main script execution
cfwarpIP
endipv4
endipresult

echo -e "${purple}************************************${rest}"
# Prompt user for new server and server_port values
read -r -p "Enter new server: " new_server
read -r -p "Enter new server_port: " new_server_port

# Update the configuration file
clear
update_config "$new_server" "$new_server_port"

# Delete the result.csv file
rm -f result.csv
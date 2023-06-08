#!/bin/env bash
######################################################################
## this script takes output from nmap in the greppable format `-oG` ##
## and then returns the open webserver ports, as well as the        ##
## responding service banner.  If it detects TCP/80 or TCP/443      ##
## it then attempts to enumerate any redirects for the domain.      ##
######################################################################

# Global Variable declarations
C99_API="PUT-API-KEY-HERE"
debug_mode=false
file="$1"
output_file="$2"
filename=$(basename "$file")  # Extract the filename from the path
domain="${filename%.*}"   # Remove the file extension from the filename
path=$(dirname "$file")
ua="Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"

debug_mode_actions() {
  main
  echo "Debug mode enabled. Here are all variables..."
  echo "Path is: $path"
  echo "Open ports are: $ports"
  echo "Numeric ports are: $numeric_ports"
  echo "Server Daemon service banner is: $daemon"
  echo "Domain is: $domain"
  echo "Redirected URL is: $redirect_url"
  echo "WAF is: $waf"
}

main() {
  # function variables
  ports=$(grep -i open "$path/$domain.txt" | awk -F'\t' '{print $NF}') # get ports line from nmap output
  numeric_ports=$(echo "$ports" | grep -oE '[0-9]+' | tr '\n' ' '| sed 's/[ \t]*$//') # extract only port numbers
  daemon=$(echo "$ports"| tr "," "\n" | awk -F'//' '{print $3}' | uniq | sed 's:/*$::')

  # begin
  if [[ "$numeric_ports" == *"80"* || "$numeric_ports" == *"443"* ]]; then
    redirect_url=$(curl -A "$ua" -sL -w "%{url_effective}" -o /dev/null "$domain")
    waf=$(curl -sS "https://api.c99.nl/firewalldetector?key=$C99_API&url=$redirect_url")
    if [ ! -f "$output_file" ]; then
        # If the output file doesn't exist, create it and add a header line
        echo "domain,ports,server,redirect,waf_tech" > "$output_file"
    fi
  # Append the result to the output file
  echo "$domain,\"$numeric_ports\",\"$daemon\",\"$redirect_url\",\"$waf\"" >> "$output_file"

  else
    echo "No Web Service ports detected for $domain"
    exit 1
  fi
}


# Check if the first argument (input file) is provided and exists
if [ -z "$file" ] || [ ! -f "$file" ]; then
  echo "Input file not found or not specified."
  echo "Expected syntax is parse.sh <input file> <output file> "
  exit 1
fi

#check if the second argument (output file) is provided
if [ -z "$output_file" ]; then
  output_file="out.csv"
  echo "Output file not specified, default value of <out.csv> will be used"
fi


debug_mode="$3"
if [ -z "$debug_mode" ] || [ "$debug_mode" = "false" ]; then
  main

else
  debug_mode_actions
fi

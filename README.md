# scaling-eureka
Bash script for parsing and transforming nmap output for webservers to discover the WAF technology in use as well as the service banner

## This script requires a c99.nl api key to be able to function correctly and return the waf technology 


# How It Works
This script takes the "greppable" output format from nmap (-oG foo) and then outputs a csv file of the server hostname, the open ports, the numeric values for the open ports, the webserver daemon (where nmap can detect it), where the hostname redirects to, and the WAF technology in use on the url.


# Usage
This script expects 3 positional arguments with the third being optional:
 - input file (file containing the -oG nmap output for a single domain
 - output file (file to output the data in CSV format to.  Defaults to ./out.csv if not specified)
 - debug (Optional, if specified it will print the different variables for each run to STDOUT. useful for debugging wierd service daemon report issues)

bash parse.sh infile outfile '(true|y)'

#!/usr/bin/env bash
# Test which Vercel/CDN IPs are reachable through corporate ethernet.
# Reads IP addresses and domains from blocked-ips.txt (same directory).
#
# Usage: ./test-blocked-ips.sh
#
# Each line: openssl s_client test → prints PASS or FAIL for each IP.
# A FAIL means 0 bytes read during TLS handshake (firewall dropping traffic).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IP_FILE="${SCRIPT_DIR}/blocked-ips.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ ! -f "$IP_FILE" ]]; then
  echo "Error: $IP_FILE not found"
  exit 1
fi

echo "============================================="
echo " TLS Handshake Test — Corporate Ethernet"
echo " $(date)"
echo " Reading from: $IP_FILE"
echo "============================================="
echo ""

pass=0
fail=0
blocked_domains=()

while IFS=$'\t' read -r ip domain; do
  # Skip comments and empty lines
  [[ "$ip" =~ ^#.*$ || -z "$ip" ]] && continue

  # Attempt TLS handshake, capture bytes read
  result=$(echo | timeout 5 openssl s_client -connect "$ip:443" -servername "$domain" 2>&1 || true)
  bytes_read=$(echo "$result" | grep -oP 'has read \K[0-9]+' || echo "0")

  if [[ "$bytes_read" -gt 0 ]]; then
    printf "${GREEN}PASS${NC}  %-18s  %-25s  read %s bytes\n" "$ip" "$domain" "$bytes_read"
    pass=$((pass + 1))
  else
    printf "${RED}FAIL${NC}  %-18s  %-25s  read 0 bytes — ${YELLOW}BLOCKED${NC}\n" "$ip" "$domain"
    fail=$((fail + 1))
    # Collect unique blocked domains for the IT summary
    if [[ ! " ${blocked_domains[*]} " =~ " ${domain} " ]]; then
      blocked_domains+=("$domain")
    fi
  fi
done < "$IP_FILE"

echo ""
echo "============================================="
printf " Results: ${GREEN}%d PASS${NC}, ${RED}%d FAIL${NC}\n" "$pass" "$fail"
if [[ "$fail" -gt 0 ]]; then
  echo ""
  echo -e " ${YELLOW}→ Send to IT:${NC}"
  echo "   The IP range 64.239.0.0/16 (Amazon/Vercel anycast)"
  echo "   is not routable through corporate ethernet."
  echo "   TLS handshakes fail with 0 bytes from server."
  echo "   Affected developer documentation sites:"
  for d in "${blocked_domains[@]}"; do
    echo "     - $d"
  done
  echo "   Workaround: VPN connection routes correctly."
fi
echo "============================================="

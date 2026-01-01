#!/bin/bash
URL="https://raw.githubusercontent.com/ahhfzwl/tunnelbroker.net/main/ip.txt"
PING_COUNT=3
PING_TIMEOUT=1
CONCURRENCY=8
TOP_N=5

echo "5正在获取节点列表..."

curl -fsSL "$URL" \
| sed -n 's/^\(.*\)\([0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}\)$/\1|\2/p' \
| tr '\n' '\0' \
| xargs -0 -n 1 -P "$CONCURRENCY" sh -c '
item="$1"
loc="${item%|*}"
ip="${item#*|}"

res=$(ping -c '"$PING_COUNT"' -W '"$PING_TIMEOUT"' "$ip" 2>/dev/null)
if [ $? -ne 0 ]; then exit 0; fi

avg=$(echo "$res" | awk -F"/" "/rtt|round-trip/ {print \$5}")
[ -n "$avg" ] && printf "%8.2f|%-35s|%s\n" "$avg" "$loc" "$ip"
' sh \
| sort -n \
| head -n "$TOP_N" \
| awk -F'|' '{printf "%-35s %-15s %s ms\n", $2, $3, $1}'

echo
echo "完成（最低延迟前 $TOP_N 个）"

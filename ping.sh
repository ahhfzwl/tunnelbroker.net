#!/bin/bash
# --------------------------------------------------
# Tunnelbroker 节点并发延迟测试（稳定终版）
# 并发 + 排序 + 前 5
# --------------------------------------------------

URL="https://raw.githubusercontent.com/ahhfzwl/tunnelbroker.net/main/ip.txt"

PING_COUNT=3
PING_TIMEOUT=1
CONCURRENCY=8
TOP_N=5

echo "58正在获取节点列表..."
echo

# 1. awk 解析 → 使用 NUL 分隔（关键修复点）
curl -fsSL "$URL" | awk '
match($0, /([0-9]{1,3}\.){3}[0-9]{1,3}/) {
    ip = substr($0, RSTART, RLENGTH)
    loc = $0
    sub(ip, "", loc)
    gsub(/[[:space:]]+$/, "", loc)
    printf "%s|%s\0", loc, ip
}
' \
| xargs -0 -P "$CONCURRENCY" -n 1 sh -c '
    item="$1"
    loc="${item%|*}"
    ip="${item#*|}"

    result=$(ping -c '"$PING_COUNT"' -W '"$PING_TIMEOUT"' "$ip" 2>/dev/null) || exit 0

    avg=$(echo "$result" | awk -F"/" "/rtt|round-trip/ {print \$5}")
    [ -n "$avg" ] && printf "%8.2f|%-35s|%s\n" "$avg" "$loc" "$ip"
' sh \
| sort -n \
| head -n "$TOP_N" \
| awk -F'|' '{printf "%-35s %-15s %s ms\n", $2, $3, $1}'

echo
echo "完成（最低延迟前 $TOP_N 个）"

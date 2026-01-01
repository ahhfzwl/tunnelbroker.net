#!/bin/bash
# ---------------------------------------
# Tunnelbroker IP 解析 + 延迟测试（稳定版）
# ---------------------------------------

URL="https://raw.githubusercontent.com/ahhfzwl/tunnelbroker.net/main/ip.txt"

PING_COUNT=3
PING_TIMEOUT=1

echo "53正在获取节点列表..."
echo

# 1. 提取 IP + 地区（awk 只做解析）
curl -fsSL "$URL" | awk '
match($0, /([0-9]{1,3}\.){3}[0-9]{1,3}/) {
    ip = substr($0, RSTART, RLENGTH)
    loc = $0
    sub(ip, "", loc)
    gsub(/[[:space:]]+$/, "", loc)
    print loc "|" ip
}
' | while IFS='|' read -r location ip; do

    printf "%-35s %-15s " "$location" "$ip"

    # 2. shell 中执行 ping（关键）
    result=$(ping -c "$PING_COUNT" -W "$PING_TIMEOUT" "$ip" 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "不可达"
        continue
    fi

    # 3. 提取平均延迟
    avg=$(echo "$result" | awk -F'/' '/rtt|round-trip/ {print $5}')

    if [ -n "$avg" ]; then
        echo "$avg ms"
    else
        echo "超时"
    fi

done

echo
echo "测试完成"

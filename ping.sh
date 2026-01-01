#!/bin/bash
# ---------------------------------------
# Tunnelbroker 节点解析 + 延迟测试
# 修复：国家码与 IP 粘连问题
# ---------------------------------------

URL="https://raw.githubusercontent.com/ahhfzwl/tunnelbroker.net/main/ip.txt"

PING_COUNT=3
PING_TIMEOUT=1

echo "47正在获取节点列表..."
echo

curl -fsSL "$URL" | awk -v c="$PING_COUNT" -v t="$PING_TIMEOUT" '
{
    # 从整行中提取 IPv4
    if (match($0, /([0-9]{1,3}\.){3}[0-9]{1,3}/)) {

        ip = substr($0, RSTART, RLENGTH)

        # 去掉 IP，剩余部分作为地区
        location = $0
        sub(ip, "", location)
        gsub(/[[:space:]]+$/, "", location)

        # ping 测试
        cmd = "ping -c " c " -W " t " " ip " 2>/dev/null"

        if ((cmd | getline) > 0) {
            while ((cmd | getline line) > 0) {
                if (line ~ /rtt|round-trip/) {
                    split(line, a, "/")
                    printf "%-35s %-15s %6.2f ms\n", location, ip, a[5]
                }
            }
            close(cmd)
        } else {
            printf "%-35s %-15s 不可达\n", location, ip
        }
    }
}
'

echo
echo "测试完成"

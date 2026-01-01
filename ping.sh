#!/bin/bash
# -------------------------------------------------
# 从 Tunnelbroker 节点列表中精准解析 IP 并测试延迟
# -------------------------------------------------

URL="https://raw.githubusercontent.com/ahhfzwl/tunnelbroker.net/main/ip.txt"

PING_COUNT=3      # ping 次数
PING_TIMEOUT=1    # 单次超时（秒）

# 依赖检查
for cmd in curl awk ping; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "缺少命令：$cmd"
        exit 1
    fi
done

echo "正在获取节点列表..."
echo

curl -fsSL "$URL" | awk -v c="$PING_COUNT" -v t="$PING_TIMEOUT" '
# -------------------------------------------------
# 只匹配：行尾是 IPv4 的行
# -------------------------------------------------
/([0-9]{1,3}\.){3}[0-9]{1,3}$/ {

    ip = $NF

    # 去掉行尾 IP，剩下的是地区描述
    sub(/[0-9.]+$/, "", $0)
    gsub(/[[:space:]]+$/, "", $0)
    location = $0

    # 执行 ping
    cmd = "ping -c " c " -W " t " " ip " 2>/dev/null"

    if ((cmd | getline) > 0) {
        # 读取 ping 输出，寻找 rtt / round-trip 行
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
'

echo
echo "测试完成"

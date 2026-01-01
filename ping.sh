#!/bin/bash

# IP 列表地址
IP_URL="https://raw.githubusercontent.com/ahhfzwl/tunnelbroker.net/main/ip.txt"

# ping 次数
PING_COUNT=3
# 单次超时时间（秒）
PING_TIMEOUT=1

# 检查 curl 是否存在
if ! command -v curl >/dev/null 2>&1; then
    echo "错误：未安装 curl"
    exit 1
fi

echo "从远程地址读取 IP 列表..."
echo

# 下载 IP 列表并逐行处理
curl -fsSL "$IP_URL" | while read -r ip; do
    # 跳过空行和注释
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue

    printf "%-16s : " "$ip"

    # 执行 ping
    RESULT=$(ping -c "$PING_COUNT" -W "$PING_TIMEOUT" "$ip" 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo "不可达"
        continue
    fi

    # 提取平均延迟
    AVG=$(echo "$RESULT" | awk -F'/' 'END {print $5}')

    if [[ -n "$AVG" ]]; then
        echo "${AVG} ms"
    else
        echo "超时"
    fi
done

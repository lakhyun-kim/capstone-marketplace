#!/bin/bash
INPUT=$(cat)
command -v jq >/dev/null || { echo "NET: 검사기 오류(jq 없음) - 안전을 위해 차단" >&2; exit 2; }
TEXT=$(printf '%s' "$INPUT" | jq -r '.tool_input | [.. | strings] | join("\n")') \
  || { echo "NET: 입력 해석 실패 - 차단" >&2; exit 2; }

ALLOW="openapi.seoul.go.kr"
HOSTS=$(printf '%s\n' "$TEXT" | grep -oiE "https?://[^/[:space:]\"'<>]+" | sed -E 's#^[A-Za-z]+://##; s#^[^@]*@##; s#:[0-9]+$##' | tr 'A-Z' 'a-z' | sort -u)
for h in $HOSTS; do
  [ "$h" = "$ALLOW" ] || { echo "NET: 허용되지 않은 호출 대상($h). $ALLOW 만 허용됩니다" >&2; exit 2; }
done
exit 0

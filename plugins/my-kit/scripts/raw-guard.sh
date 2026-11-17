#!/bin/bash
INPUT=$(cat)
command -v jq >/dev/null || { echo "RAW: 검사기 오류(jq 없음) - 안전을 위해 차단" >&2; exit 2; }
TEXT=$(echo "$INPUT" | jq -r '.tool_input | tostring') || { echo "RAW: 입력 해석 실패 - 차단" >&2; exit 2; }

PAT='mydata/raw|(^|[^A-Za-z0-9_.-])raw/'
echo "$TEXT" | grep -Eq "$PAT"; RC=$?
[ "$RC" -eq 1 ] && exit 0      # 1 = 패턴 없음 → 통과
if [ "$RC" -eq 0 ]; then
  echo "RAW: 원본(raw/) 접근은 차단됩니다. pseudo/ 가명 데이터를 쓰세요" >&2
else
  echo "RAW: 검사기 오류(grep 종료 코드 $RC) - 안전을 위해 차단" >&2
fi
exit 2

#!/bin/bash
INPUT=$(cat)
command -v jq >/dev/null || { echo "KEY: 검사기 오류(jq 없음) - 안전을 위해 차단" >&2; exit 2; }
TEXT=$(printf '%s' "$INPUT" | jq -r '(.tool_input // {prompt: .prompt}) | [.. | strings] | join("\n")') \
  || { echo "KEY: 입력 해석 실패 - 차단" >&2; exit 2; }

# git 저장소에서 git commit 이면 커밋에 들어갈 내용(staged diff)도 함께 본다
if printf '%s' "$TEXT" | grep -Eq 'git[[:space:]].*commit' && git rev-parse --git-dir >/dev/null 2>&1; then
  DIFF=$(git diff --cached 2>/dev/null) || { echo "KEY: 커밋 내용 검사 실패 - 차단" >&2; exit 2; }
  TEXT="$TEXT
$DIFF"
fi

# 1) 등록된 키 값 그대로 (claude mcp add --env 로 ~/.claude.json 에 들어간 값)
KEYVAL=${SEOUL_API_KEY:-$(jq -r '[.. | objects | .SEOUL_API_KEY? | strings] | first // empty' "$HOME/.claude.json" 2>/dev/null)}
if [ ${#KEYVAL} -ge 8 ]; then
  printf '%s' "$TEXT" | grep -qF -- "$KEYVAL"; RC=$?
  [ "$RC" -eq 0 ] && { echo "KEY: 서울 API 키 값이 들어 있어 차단합니다" >&2; exit 2; }
  [ "$RC" -eq 1 ] || { echo "KEY: 검사기 오류(grep $RC) - 차단" >&2; exit 2; }
fi

# 2) 키를 값으로 적는 모양, URL 경로에 든 키, 키가 저장된 사용자 설정 파일, 프로세스 환경 변수 엿보기
PAT="SEOUL_API_KEY[\"' ]*[=:][\"' ]*[A-Za-z0-9]{8,}|openapi\.seoul\.go\.kr:8088/[A-Za-z0-9]{8,}/|\.claude\.json|/proc/[^[:space:]]*/environ|(^|[^A-Za-z0-9_])ps[[:space:]]+[A-Za-z]*e"
printf '%s' "$TEXT" | grep -Eq -- "$PAT"; RC=$?
[ "$RC" -eq 1 ] && exit 0      # 1 = 패턴 없음 → 통과
if [ "$RC" -eq 0 ]; then
  echo "KEY: 키를 파일, 명령, 커밋, 프롬프트에 적는 요청은 차단됩니다. 키는 MCP 등록(--env)으로만 넣습니다" >&2
else
  echo "KEY: 검사기 오류(grep 종료 코드 $RC) - 안전을 위해 차단" >&2
fi
exit 2

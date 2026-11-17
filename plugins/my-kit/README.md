# my-kit

캡스톤 트랙 B에서 만든 plugin입니다. (무엇을 하는지 한두 문장으로 고쳐 쓰세요.)

## 들어 있는 것
- agents: anomaly-checker consult-prep portfolio-analyst price-summarizer risk-reviewer spending-analyst 
- skills: periodic-report proposal-draft 
- 가드레일 훅: dlp-guard.sh key-guard.sh net-guard.sh raw-guard.sh 

## 설치 (Claude 세션 안에서)
/plugin marketplace add ~/claude-lab/capstone/marketplace
/plugin install my-kit@capstone-local

## 필요한 설정
- 키나 토큰이 필요하면 설치할 때 묻는 칸에 넣습니다. 이 저장소에는 키를 넣지 않습니다.
- 업무 폴더에 필요한 것: (예: 트랙 A는 pseudo 링크와 segments.md)
- plugin에 넣을 수 없는 설정(권한 deny, MCP 허용 목록)은 업무 폴더의 .claude/settings.json 에 둡니다.
- 버전: 0.1.0 (고치면 .claude-plugin/plugin.json 의 version 과 함께 올립니다)

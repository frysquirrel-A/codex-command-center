# Codex Command Center

Codex 런타임 상태(큐/핸드오프/워치독/리소스)를 한 화면에서 보는 로컬 대시보드입니다.

## 빠른 시작 (로컬)

1. Python 3.10+ 설치
2. PowerShell에서 아래 실행

```powershell
Set-Location "$PSScriptRoot"
.\start_control_center.ps1
```

또는:

```powershell
.\launch_control_center.cmd
```

3. 브라우저에서 열기

```
http://127.0.0.1:8787
```

## 원격 접속(선택)

Cloudflare Tunnel을 쓰려면 `bin/cloudflared.exe`가 필요합니다.

1. Cloudflared 다운로드 후 `bin/cloudflared.exe`에 위치
2. 아래 실행

```powershell
.\start_public_tunnel_cloudflared.ps1
```

상태 확인: `state/public_tunnel_status.json`

## 폴더 구조

- `static/` UI (HTML/CSS/JS)
- `src/` 서버 (Python)
- `state/` 실행 중 생성되는 로컬 상태 파일

## 참고

이 저장소는 실행에 필요한 코드만 포함하며, `state/`, `bin/` 등 런타임/바이너리 파일은 Git에서 제외됩니다.

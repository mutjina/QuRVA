# Project Template / 프로젝트 템플릿

이 repository는 Codex와 함께 새로운 프로젝트를 시작할 때 사용하는 기본 템플릿이다.

## Purpose / 목적

- 새 프로젝트를 일정한 구조로 시작하기
- 프로젝트 목적과 실행 방법을 README.md에 기록하기
- 진행 상황과 중요한 결정을 PROJECT_NOTES.md에 기록하기
- Codex가 따라야 할 기본 작업 규칙을 AGENTS.md에 저장하기
- Git으로 프로젝트 변경 이력을 관리하기

## Included Files / 포함된 파일

- `README.md`
  - 프로젝트의 목적, 설치 방법, 실행 방법, 구조를 기록한다.

- `PROJECT_NOTES.md`
  - 현재 진행 상태, 완료된 작업, 중요한 결정, 미해결 문제, 다음 작업을 기록한다.

- `AGENTS.md`
  - Codex가 프로젝트에서 따라야 할 작업 규칙을 기록한다.

- `.gitignore`
  - Git에 포함하지 않을 파일과 폴더를 지정한다.

## How to Use / 사용 방법

1. 이 template repository를 이용해 새로운 GitHub repository를 만든다.
2. 새 repository를 VS Code에서 Clone한다.
3. README.md의 내용을 실제 프로젝트에 맞게 수정한다.
4. Codex에게 AGENTS.md와 PROJECT_NOTES.md를 참고하여 작업하도록 한다.
5. 의미 있는 작업이 끝날 때마다 PROJECT_NOTES.md를 업데이트한다.
6. 변경 내용을 Git commit 및 push하여 관리한다.

## Recommended Project Structure / 권장 프로젝트 구조

```text
project-name/
├── AGENTS.md
├── PROJECT_NOTES.md
├── README.md
├── .gitignore
├── src/
├── data/
└── output/

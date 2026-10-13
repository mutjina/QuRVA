# Project Instructions / 프로젝트 작업 지침

## Documentation / 문서 관리

- Keep `README.md` updated with the project purpose, setup, usage, dependencies, and structure.
  - `README.md`에는 프로젝트 목적, 설치/실행 방법, 사용법, 필요한 패키지, 프로젝트 구조를 최신 상태로 유지한다.

- At the start of each task, read `PROJECT_NOTES.md` to understand the current project status.
  - 각 작업을 시작할 때 `PROJECT_NOTES.md`를 읽어 현재 프로젝트 상태를 파악한다.

- After meaningful changes, update `PROJECT_NOTES.md`.
  - 의미 있는 변경 후에는 `PROJECT_NOTES.md`를 업데이트한다.

- Record completed work, important decisions, unresolved issues, and next steps in `PROJECT_NOTES.md`.
  - 완료된 작업, 중요한 결정, 미해결 문제, 다음 작업을 `PROJECT_NOTES.md`에 기록한다.

- Do not leave important project context only in chat.
  - 중요한 프로젝트 정보는 채팅에만 남기지 않는다.


## Project Structure / 프로젝트 구조

- Store source code in `src/`.
  - 소스 코드는 `src/`에 저장한다.

- Store input or research data in `data/`.
  - 입력 데이터 또는 연구 데이터는 `data/`에 저장한다.

- Store generated results, figures, and exported files in `output/`.
  - 생성된 결과, 그림, 내보낸 파일은 `output/`에 저장한다.


## Git and Security / Git 및 보안

- Do not commit secrets, API keys, passwords, virtual environments, caches, or local configuration files.
  - 비밀번호, API key, 가상환경, 캐시, 로컬 설정 파일은 Git에 올리지 않는다.

- Keep `.gitignore` appropriate for the project.
  - 프로젝트에 맞게 `.gitignore`를 유지한다.


## Python Virtual Environment / Python 가상환경

- For Python projects, use a project-specific virtual environment named `.venv`.
  - Python 프로젝트에서는 프로젝트별 가상환경 `.venv`를 사용한다.

- At the beginning of a project, if `.venv` does not exist, create it with:
  - 프로젝트 시작 시 `.venv`가 없으면 다음 명령으로 생성한다.

  `python -m venv .venv`

- If `.venv` already exists, do not create a new virtual environment. Use the existing `.venv`.
  - `.venv`가 이미 존재하면 새 가상환경을 만들지 말고 기존 `.venv`를 사용한다.

- Install project dependencies only inside `.venv`.
  - 프로젝트에 필요한 패키지는 `.venv` 안에 설치한다.

- Maintain `requirements.txt` for Python dependencies.
  - Python 패키지 의존성은 `requirements.txt`로 관리한다.

- After adding or changing Python packages, update `requirements.txt`.
  - Python 패키지를 추가하거나 변경한 경우 `requirements.txt`를 업데이트한다.

- When `.venv` is newly created and `requirements.txt` exists, install dependencies from it.
  - `.venv`를 새로 만들었고 `requirements.txt`가 존재하면 해당 파일에서 패키지를 설치한다.

- Do not commit `.venv` to Git.
  - `.venv`는 Git에 올리지 않는다.

## Git Initial Setup / Git 초기 설정

- Before the first commit on a new computer, verify that Git user information is configured.
  - 새 컴퓨터에서 처음 Commit하기 전에 Git 사용자 정보가 설정되어 있는지 확인한다.

  `git config --global user.name`
  
  `git config --global user.email`

- If not configured, set them once on that computer:
  - 설정되어 있지 않으면 해당 컴퓨터에서 한 번만 설정한다.

  `git config --global user.name "Your Name"`
  
  `git config --global user.email "your-email@example.com"`
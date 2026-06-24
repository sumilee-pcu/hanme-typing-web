# Render 배포 실습 가이드

이 문서는 Flutter 웹 앱을 Render Static Site로 배포하는 수업용 절차입니다.

## 핵심 개념

Flutter 앱은 Android/iOS 앱으로도 빌드할 수 있지만, `flutter build web`을 실행하면 정적 웹 파일이 `build/web`에 생성됩니다. Render Static Site는 이 정적 파일 폴더를 CDN으로 배포합니다.

## 사전 준비

- GitHub 저장소
- Render 계정
- Flutter 프로젝트 코드

## 방법 1. Dashboard에서 수동 설정

Render Dashboard에서 다음 순서로 진행합니다.

1. New > Static Site
2. GitHub 저장소 연결
3. 설정값 입력

```text
Name: retro-hangul-typing
Branch: main
Root Directory: 비워둠
Build Command: bash scripts/render_build.sh
Publish Directory: build/web
```

4. Create Static Site
5. 빌드 로그 확인
6. 배포 URL 열기

## 방법 2. render.yaml 사용

저장소 루트에 `render.yaml`이 있으면 Render Blueprint로 설정을 코드화할 수 있습니다.

```yaml
services:
  - type: web
    name: retro-hangul-typing
    runtime: static
    buildCommand: bash scripts/render_build.sh
    staticPublishPath: build/web
    previews:
      generation: automatic
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
```

## 빌드 스크립트가 하는 일

`scripts/render_build.sh`는 Render 빌드 환경에서 다음 작업을 수행합니다.

1. Flutter SDK가 없으면 stable 채널을 내려받음
2. Flutter web 빌드 활성화
3. 패키지 설치
4. `flutter build web --release` 실행
5. `build/web` 폴더 생성

## 수업 설명 포인트

- Render는 서버 앱뿐 아니라 정적 사이트도 배포할 수 있다.
- Flutter 웹 빌드 결과물은 정적 파일이다.
- Static Site의 핵심 설정은 Build Command와 Publish Directory다.
- GitHub에 push하면 Render가 자동으로 다시 빌드/배포한다.
- 환경변수는 공개되어도 되는 값과 서버 전용 비밀값을 구분해야 한다.

## 문제 해결

### Publish directory does not exist

`flutter build web`이 실패해서 `build/web`이 생성되지 않은 상태입니다. 빌드 로그에서 Flutter 설치 또는 패키지 설치 실패 원인을 확인합니다.

### flutter: command not found

Render 빌드 환경에 Flutter가 기본 설치되어 있지 않다는 뜻입니다. 이 프로젝트는 `scripts/render_build.sh`에서 Flutter를 내려받도록 구성했습니다.

### 첫 배포가 오래 걸림

첫 빌드에서 Flutter SDK를 내려받기 때문에 시간이 걸릴 수 있습니다. 이후 빌드는 캐시 상황에 따라 더 빨라질 수 있습니다.

### 새 배포가 안 보임

Render Deployments 탭에서 최신 배포 로그를 확인하고, 필요하면 Manual Deploy를 실행합니다.

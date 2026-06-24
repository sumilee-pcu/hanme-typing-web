# 레트로 한글 타자

Flutter로 만든 모바일 우선 한글 타자연습 MVP입니다. 과거 한글 타자연습 프로그램의 감성은 참고하되, 원본 실행파일/이미지/사운드/문장/단어 목록을 사용하지 않는 클린룸 재구현을 원칙으로 합니다.

## MVP 기능

- 자리 연습
- 낱말 연습
- 긴글 연습
- 단어 방어 게임
- 타수, 정확도, 점수, 진행률 HUD
- 모드별 결과 시트
- 모바일/웹 반응형 레이아웃

## 판정 기준

- 타수는 글자 수가 아니라 두벌식 한글 입력 기준의 자모 환산 타수/분으로 계산합니다.
- 복합 모음과 겹받침은 구성 자모 수에 맞춰 2타로 계산합니다.
- 한글 IME가 조합 중인 글자는 오답으로 표시하지 않고, 조합이 확정된 뒤 판정합니다.
- 오타는 지운 뒤 다시 입력해도 누적 기록에 남습니다.

## 실행

```bash
flutter run
```

웹 서버로 실행:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 3123
```

프로덕션 웹 빌드:

```bash
flutter build web
```

빌드 결과 미리보기:

```bash
cd build/web
python3 -m http.server 3123
```

## 검증

```bash
flutter analyze
flutter test
```

## Render 배포

Render Static Site 설정:

```text
Build Command: bash scripts/render_build.sh
Publish Directory: build/web
```

자세한 수업용 절차는 [Render 배포 실습 가이드](docs/RENDER_DEPLOY.md)를 참고하세요.

## 문서

- [PRD](docs/PRD.md)
- [Render 배포 실습 가이드](docs/RENDER_DEPLOY.md)

## 저작권/상표 원칙

- 원본 프로그램의 바이너리, 리소스, 그래픽, 사운드, 문장 데이터, 단어 목록을 포함하지 않습니다.
- 공개 제품명은 기존 상표 또는 서비스명과 혼동되지 않도록 별도 검토합니다.
- 연습 콘텐츠는 직접 작성하거나 명확한 라이선스가 있는 자료만 사용합니다.
- 앱 기본 글꼴은 Google Fonts의 Noto Serif KR을 사용합니다. Noto 글꼴은 SIL Open Font License로 배포됩니다.

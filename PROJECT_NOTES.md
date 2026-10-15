# Project Notes / 프로젝트 진행 기록

## Current Status / 현재 상태
- 작업 재개: 사용자 exe 시작 문제(명령창만 표시) 및 자동 최대화 요청에 대응 중이다. 기존 콘솔 빌드 대신 Windows GUI 타깃, deployed uiwait, 시작 로그/영어 오류창을 적용했다. 실제 별도 Runtime-only 환경 검증은 여전히 필요하다.
- 사용자 요청으로 여기까지 작업 내용을 저장하고 종료한다. 코드와 Windows 실행/배포 파일은 로컬에 저장되어 있다. Git commit/push는 수행하지 않았다.
- 최신 사용자 요청에 따라 현재 코드의 Windows exe 빌드를 완료했다. output/release/QuRVA.exe 및 배포 묶음 output/QuRVA-Windows.zip을 생성했다. 별도 MATLAB Runtime-only 컴퓨터의 실행 검증은 남아 있다.
- 2026-10-15: MATLAB 첫 구현 완료. 영어 UI, TIFF 한 장 읽기, 수동 망막 경계/시신경 위치, 설정 tooltip, 골격 미리보기, 전체·방사형·coherence 분석 및 CSV/설정/ROI 내보내기를 연결했다. 실제 연구 영상 검증은 미수행이다.

## Completed / 완료된 작업
- exe 시작 대응 완료: Windows GUI 타깃으로 재빌드(20,429,452 bytes), PE subsystem=2 확인. 새 exe 직접 실행 시 시작 로그에 Creating application window → Application window ready 도달을 확인했다. MATLAB에서 WindowState=maximized assertion 통과. 별도 Runtime-only 컴퓨터의 실제 영상 분석 검증은 여전히 남아 있다.
- 최신 코드 MATLAB Compiler 빌드 성공: QuRVA.exe 20,384,406 bytes. unresolvedSymbols 및 excludedFiles 목록에 문제 항목 없음. output/release에 실행 안내, GPL 라이선스/출처, 소스 ZIP, SHA256을 함께 준비했다. 필요한 Runtime은 Windows 64-bit R2026b다.
- Open TIFF와 Save results의 최근 폴더를 Input/Output으로 분리해 MATLAB 사용자 preference에 저장하도록 변경했다. 앱 재시작 후 유지하며 성공적으로 읽기/저장한 경우만 갱신한다. 대화상자 취소 시 유지, 기억한 폴더 삭제 시 pwd로 대체한다. 저장 대화상자는 타임스탬프 하위 폴더가 아닌 사용자가 선택한 부모 폴더에서 열린다.
- 사용자 요청으로 상단 실행 버튼 행을 45→70 높이로 키우고 글씨를 14pt bold로 변경했다. 결과 메뉴 행은 36→32로 줄여 실행/결과 위계를 구분했다. Windows 삭제는 아직 요청 확정이 아니므로 유지한다.
- checkCompactExport 통과: 하위 폴더 없이 파일 6개만 저장, CSV 내용 그대로 유지, JSON 경계/시신경 좌표 일치, 중간 MAT/QC 폴더 제외를 확인했다. exe는 생성하지 않았다.
- 실제 네이티브 테마는 UI 생성 직후 아직 갱신 전일 수 있어, 생성 후 drawnow로 테마를 적용한 다음 Image 패널 BackgroundColor를 읽도록 보완했다. 다크 테마에서 결과 HTML 배경 일치(33/255)와 실제 스크린샷을 확인했다. 비공개 테마 설정 API는 사용하지 않는다.
- 결과 HTML의 흰 배경을 제거하고 MATLAB Figure.Color를 전달해 배경색/글자/헤더/경계선을 테마에 맞췄다. 비어 있는 초기 표도 같은 테마를 적용한다.
- Coherence nTiles=0 구간과 0행 Windows에 원인 및 확인할 설정을 영어로 표시한다. NaN을 0으로 대체하지 않는다. localCoherence의 빈 branch/window 배열 크기를 명시해 혈관 가지가 없어도 빈 결과를 정상 반환하도록 호환성 수정했다.
- checkCoherenceEmpty 통과: 최소 가지 수 미달 시 6개 구간 nTiles=0 및 요약 NaN/Windows 0행, 평행 가지의 유효 창 coherence=1, 빈 skeleton의 정상 반환, UI 배경 일치. checkResultsScroll 재검증도 통과. 실제 사용자 영상의 어떤 필터 때문에 창이 없는지는 아직 특정하지 않았다.
- 사용자 오류 수정: inputs의 암묵적 createMask가 표시 이미지 크기를 참조하는 대신 원본 크기에 poly2mask를 적용하고 시신경 중심은 같은 좌표계에서 inpolygon으로 검사한다. 축소 미리보기 표시 후 원본 내부 점(1500,600)이 거절되던 조건을 재현해 회귀 검증 통과. 실제 밖의 점은 계속 거절한다.
- 사용자 로그에서 MATLAB:string:CannotConvertMissingElementToChar가 qurvaTableData의 char(string(...))에서 발생함을 확인. 결측 문자열은 빈 표시, 숫자 NaN은 NaN 표시로 변환하고 원본 테이블은 유지한다. 해당 결측값 회귀 검증 통과. 모든 결과 payload가 만들어진 뒤 메뉴를 활성화하도록 변경했다.
- 결과 HTML 표의 가로/세로 스크롤을 view에 한정하고 설명 영역을 그 밖에 고정했다. 오른쪽 열의 hover/click/focus 설명도 화면 폭 내에서 줄바꿈하도록 변경했다.
- checkResultsScroll 실제 uihtml 검증 통과: 40번째 열까지 가로 스크롤한 상태에서 mouseenter 설명이 바뀌고 설명 영역이 화면 폭 안에 유지됨을 DOM 좌표로 확인했다. 이번 수정은 MATLAB에서만 검증했고 exe는 생성하지 않았다.
- 결과 표시를 균등 너비 가운데 정렬 메뉴와 로컬 HTML 표로 변경했다. 각 열에 과학적 의미/단위 tooltip을 제공한다(전역/방사형의 junction 정의 차이 포함). 데이터는 HTML 문자열에 삽입하지 않고 textContent로 표시한다.
- 저장 오류 대응: 전체 원본 크기의 double RGB 배열 대신 최대 변 4096의 분석 격자 uint8 미리보기를 사용한다. PNG 저장 직전에도 크기/형식을 제한하고 복사 전에 PNG를 작성한다. 분석 격자 및 원본 ROI 좌표는 유지한다. 앱 오류창은 영어로 표시하고 원본 진단은 tempdir/QuRVA-errors.log에 기록한다. 사용자 실제 대형 TIFF 재확인 필요.
- MATLAB 회귀 검증 통과: RGB/uint16 열기, 설정 JSON 저장/불러오기 및 새 영상에서 값 유지, 4096/24-bit PNG 제한, 영어 오류 변환, 전체 합성 분석의 51/24/10/5열과 전체 열 도움말 정의, PNG 포함 결과 내보내기, 메뉴 읽음/무효화 상태. exe는 생성하지 않았다.
- checkImageImport 검증 통과: RGB 세 채널 선택, grayscale uint16, 채널 변경 시 결과 무효화, 라벨 tooltip, 제목 가운데 정렬. 수정한 output/build/QuRVA.exe 재빌드 성공. 실제 사용자 TIFF 검증은 필요하다.
- 사용자 피드백 반영: RGB TIFF 거절을 제거하고 Analysis channel(Red/Green/Blue) 선택을 추가했다. 원본과 같은 Red를 초기 선택하며 혈관 신호 채널을 사용자가 확인한다. indexed TIFF도 RGB로 변환해 읽는다. 분석은 선택한 단일 채널을 사용하며 설정 내 channel에 기록한다. 채널 변경은 ROI를 유지하고 기존 결과를 무효화한다.
- Analysis settings 제목을 가운데 정렬하고 별도 물음표를 제거했다. 변수 라벨에 직접 영어 tooltip을 표시한다. 이 결정이 이전 ? 아이콘 계획을 대체한다.
- MATLAB Compiler standalone 빌드 성공: output/build/QuRVA.exe 생성(약 20 MB). 별도 Runtime 환경에서 실제 실행은 아직 검증하지 않았다.
- MATLAB R2026b 및 Image Processing, Statistics and Machine Learning, Signal Processing, Curve Fitting Toolbox 설치 확인. MATLAB Compiler 설치 및 라이선스 확인(license test=1).
- src/QuRVAApp.m, runQuRVA.m, qurvaAnalyze.m, buildQuRVA.m, smokeQuRVA.m 추가. 공개 수정판 소스/모델과 GPL 라이선스 확보. 출처 및 변경은 src/vendor/UPSTREAM.md에 기록했다.
- 합성 영상에서 UI 생성과 전체 분석 smoke 검증 통과: CSV 51/24/10/5열, 방사형 6구간, coherence 창 121개, 전체 혈관 모드 골격 유지 및 설정 저장 확인. MATLAB 정적 검사에는 스타일/성능 권고만 있었으며 구문 오류는 없었다.
- 단일 영상 또는 한 구간 결과에서 원본 struct2table이 실패하는 문제를 발견하여 3개 upstream 함수에 AsArray=true 호환성 수정. 원본 과학적 지표 정의는 유지했다.
- README를 실제 실행 방법, 의존성, 출력, 범위, 라이선스 안내로 교체. 생성 output과 MATLAB 캐시를 .gitignore에 추가했다.
- 공개 main 브랜치의 statsFromQuRVA_v2.m, capillaryMetrics.m, radialTopology.m, localCoherence.m, batchLocalCoherence.m 실제 본문을 읽어 CSV 스키마를 정적 확인했다. 전역 51열, 방사형 24열, coherence 구간 요약 10열, 창별 5열이다. MATLAB 실행/생성 CSV와의 대조는 미수행이다.
- 소스 검토 발견: 전역에는 allSkelLen_mm, meanCapRadius_um, sdCapRadius_um, capSkelPixels 및 loop QC 필드도 포함된다. 창별 coherence CSV에는 위치 좌표가 없다. radialTopology는 가지/loop 전체를 중심점 기준 구간에 배정하며 전역과 분기점 집계 방식이 다르다(전역 연결된 분기점 군집 수, 방사형 분기점 픽셀 수).
- 가이드와 소스 차이: radiusThreshUM=0은 현재 소스에서 전체 혈관 포함이 아니라 모세혈관 골격을 비운다. radialTopology 내부 기본값은 basePxUM=2/1.4491, radiusThreshUM=9, minLoopUM2=12로 가이드 예시/코드 주석과 다르다. 신규 구현 시 명시적인 전체 혈관 모드 및 일관된 설정이 필요하다.
- 사용자 제공 `Modified QuRVA Guide_타마라.docx` 본문을 읽었다. 문서 내 수정판 저장소: https://github.com/tamim4rtinez/QuRVA_modified_segmentation . 공개 파일 목록에서 추가 분석 스크립트 존재를 확인했으나 함수 본문 대조 및 실행 검증은 아직 수행하지 않았다.
- 가이드는 원본 분할 결과에 statsFromQuRVA_v2(전역 모세혈관/분지/loop/굴곡도/거리), radialTopology(방사형 구간 분석), localCoherence 및 batchLocalCoherence(국소 방향 정렬도)를 추가한 작업 흐름을 설명한다. 원본의 tuft/무혈관 예측은 후속 분석의 주목적이 아니다.
- 문서 검토 쟁점: .m/.mat 혼동, loop 면적 단위 오기, gapPix 예시 불일치(3 대 2), scaleFactor 동일 여부만으로 원본 해상도 일치를 입증할 수 없음, 혈관 마스크 팽창이 골격과 후속 지표에 영향을 주지 않는다는 주장은 검증 필요.
- 원본 저장소 확인: https://github.com/javimazzaf/QuRVA (v1.2).
- 관련 논문 확인: Mazzaferri et al., Scientific Reports (2018), https://www.nature.com/articles/s41598-018-22251-7 .
- 원본 README 확인: flat-mount tif/jpg 영상을 폴더 단위로 처리하고 정량 보고서 및 영역 이미지를 저장한다. parameters.ini에서 설정을 조정하며, model.mat 및 재학습 스크립트가 포함된다.

## Important Decisions / 중요한 결정
- 사용자 요청: MATLAB 및 exe 앱 창은 실행 즉시 최대화한다. runQuRVA의 isdeployed 경로에서 uiwait로 이벤트 처리를 유지하며 buildQuRVA는 standaloneWindowsApplication으로 콘솔 창 없는 Windows GUI 앱을 빌드한다.
- 사용자 저장 간소화 요청 반영: 앞으로 Save results는 네 탭 CSV 4개, preview.png, settings.json의 6개 파일만 내보낸다. JSON에 원본 경계 꼭짓점/시신경 중심/영상 크기도 함께 기록한다. 큰 session.mat, 중간 마스크/골격 및 QC 하위 폴더는 내보내지 않는다. 이전 저장 폴더는 변경하지 않는다.
- 최신 사용자 지정: Pixel size (um/pixel) 초기값을 2.8986으로 변경했다. 촬영 조건이 다르면 사용자가 수정하며 저장 설정을 불러온 경우 저장값을 적용한다. 이전의 초기값 미지정 방침을 대체한다.
- 최신 사용자 지정: 앱의 Large-vessel radius (um) 초기값은 50 µm이다. 이전 17.1 µm 예시값을 대체한다. 저장한 설정을 불러오면 파일에 기록된 값이 적용된다.
- 사용자 확정 순서/표기: ① Open TIFF → ② Draw boundary → ③ Set optic nerve → ④ Analysis settings → ⑤ Preview → ⑥ Analyze → ⑦ Save results. 설정은 초기 예시값으로만 취급하고 Reset defaults를 제거한다. Save settings/Load settings(JSON)로 수치 및 채널 설정을 재사용한다. 새 영상에서도 값을 유지하되 픽셀 크기/채널 확인을 안내한다.
- 결과 메뉴는 가운데 정렬하며 분석 완료 시 활성화하고 미확인 * 표시를 붙인다. 클릭한 메뉴의 *만 지우고 설정/ROI/채널 변경 시 모든 결과를 비활성화한다.
- 최신 사용자 지시: 검토 단계는 MATLAB에서 직접 실행한다. 중간 수정마다 exe를 생성하지 않고 최종 완성 시에만 빌드한다. 기존 output/build/의 exe 및 동반 생성물을 사용자 승인에 따라 삭제했다. 빌드 소스는 최종 배포용으로 유지한다.
- 사용자 확정: 제작 시 MATLAB을 활용한다. App Designer UI와 MATLAB Compiler 독립 실행 배포를 우선 검토한다. 사용자는 MATLAB 설치 없이 실행하는 것을 원하며, 이 경로에서는 MATLAB Runtime이 필요하다. Compiler 라이선스 및 코드 배포 호환성은 아직 확인하지 않았다.
- 첫 버전은 TIFF 한 장씩 분석한다. 망막 경계와 시신경 중심을 사용자가 지정하고, 기본값이 채워진 몇몇 분석 수치를 미리보기로 조정한 뒤 결과를 확인·CSV 저장하는 단순한 흐름을 지향한다. 다중 영상 일괄 분석 등 추가 기능은 우선 범위에 넣지 않는다.
- 사용자 결정: 분석 입력란은 처음부터 기본값으로 채워 사용자가 시작할 수 있게 한다. 초기 제안은 가이드 예시를 기반으로 radiusThreshUM=17.1, minBranchPix=8, gapPix=3, minLoopUM2=100, nBins=6, minLenUM=20, tileUM=150, minBranches=6, cohThresh=0.60이며, 검증된 보편적 최적값이 아닌 시작용 preset으로 취급한다. 실제 적용 의미는 소스 검토 후 확정한다.
- 픽셀 크기는 실제 촬영 보정값이므로 가이드의 3/1.4491을 무조건 적용하지 않는다. 메타데이터에서 읽거나 사용자가 확인하도록 하는 설계를 제안했다.
- 구현 범위는 수정판 가이드의 전역·방사형·국소 coherence 분석 결과를 얻는 프로그램이다.
- 사용자 결정: 프로그램 UI와 도움말은 영어로 작성한다. 각 설정 옆 `?`에 마우스를 올리면 의미를 설명하는 tooltip을 표시한다. 코드 변수명 대신 읽기 쉬운 영어 라벨과 단위를 표시한다.
- 사용자가 영상을 보면서 분석 설정을 조정할 수 있는 미리보기를 설계한다. 구체적인 UI 및 계산 반영 방식은 구현 전 확정한다.
- 일반적인 안저/OCTA 분석으로 가정하지 않는다. 원본 QuRVA는 OIR 모델의 망막 flat-mount 영상에서 혈관망, 무혈관 영역, 병적 신생혈관 tuft를 분석하는 도구다.

## Open Issues / 미해결 문제
- 사용자가 Mac용 앱 제작도 요청했다. 현재 Windows에서 macOS 바이너리를 교차 빌드할 수 없어 Mac용 앱은 아직 생성하지 않았다. macOS의 MATLAB Compiler 환경 및 대상 아키텍처(Apple Silicon/Intel)를 확인한 뒤 별도 빌드가 필요하다. 소스 실행 및 Mac 배포 호환성 검증도 남아 있다.
- 독립 실행 앱 빌드/Runtime 실행 검증 및 실제 TIFF로 경계 편집부터 내보내기까지 사용자 검토 필요.
- grayscale/RGB/indexed 단일 페이지 정수 TIFF를 지원하며 multipage는 아직 지원하지 않는다. 픽셀 크기는 사용자 직접 확인 입력이다.
- 원본 혈관 분할은 4096 최대 변 길이로 표준화한다. 실시간 계산 대신 Preview/Analyze 버튼으로 실행하며, 큰 영상의 처리 속도는 추가 확인 필요하다.
- 소스 함수별 처리 과정, 모델 구성, 지표 정의와 파라미터는 아직 상세 검토하지 않았다.
- 사용자 영상 조건, 필요한 기능 및 기존 결과와의 일치 기준은 미정이다.

## Next Steps / 다음 작업
- MATLAB에서 실제 연구 TIFF로 기존 수정판과 결과 수치를 대조하고 UI 조작성을 검토한다. 최종 완성 후에만 standalone을 다시 빌드하고 MATLAB Runtime 환경 실행을 확인한다.
- 논문과 MATLAB 소스를 대조해 분석 단계, 입출력, 지표, 설정 및 모델 의존성을 정리한 뒤 간소화할 작업 흐름을 협의한다.

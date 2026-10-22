---
status: active
version_context: "g2pkk Dart 0.1.x, g2pkk(Python) 0.1.2"
tags: [korean, g2p, mecab, phonology]
aliases: [mecab-less 한계, 사이시옷 구분 불가]
created: 2026-10-22
confidence: 5
---

# g2pkk mecab-less 한계

형태소 분석기 없이는 표면 문자열이 같은 두 발음 현상을 구분할 수 없어,
원본 g2pK가 mecab 어노테이션(STEP 3)으로 처리하던 규칙들이 예외 사전·휴리스틱으로
대체된다. Dart 포트는 `MorphAnalyzer` 주입(2026-10-22)으로 이 한계를 선택적으로 해소한다.

## 형태소 경계가 필요한 규칙

원본 annotate()가 만드는 마커와 그 소비 규칙:

| 마커 | 조건(mecab-ko 태그) | 소비 규칙 | 예 |
|------|---------------------|-----------|-----|
| /P | 용언 어간(V*) + 어말 자모 ㄴ/ㄵ/ㅁ/ㄻ/ㄺ/ㄼ/ㄾ | 제23항 계열 경음화(verbNieun) | 앉다→[안따], 신다→[신따] |
| /E | 어미(E*) + ㄹ | ㄹ 탈락·경음화(modifyingRieul) | 할걸 |
| /B | 단위성 의존명사(NNBC) | 순우리말 수사(numerals) | 3개→[세개] |
| /J | 조사(J*)의 '의' | ㅢ→ㅔ 발음(descriptive) | 나의→[나에] |

## 형태소로도 안 풀리는 것 — 예외 사전의 영역

사이시옷 합성어 ㄴ 첨가(나랏+일→[나란닐]) vs 조사 연음(옷+이→[오시])는
**mecab-ko조차 나랏일을 단일 NNG로 분석**해 형태소 경계 정보로도 구분 불가.
원본 파이썬 g2pkk도 `나랏일→나라실`(실측 2026-10-22). 유일한 해법은 idioms
예외 사전 등재(`나랏일===나란닐`) — Dart 포트가 원본보다 정확한 부분.

## 안전장치의 양면

annotate()는 토큰 표면형 합성이 원문(공백 제거)과 불일치하면 원문을 그대로
반환한다. 덕분에 형태소 분석기가 죽어도 파이프라인이 죽지 않지만, 대신
**기능이 조용히 mecab-less로 저하**된다(Case 3: mecab.exe가 etc\mecabrc 부재로
사망해도 g2pkk는 겉보기 정상 동작). mecab 의존 동작을 검증할 땐 /P /B 마커가
실제 발화되는 입력(앉다, 3개)로 출력을 직접 확인해야 한다.

## 관련

- [[dependency-injection-over-ffi-binding]] — 통합 아키텍처 선택
- 원본: harmlessman/g2pkk `utils.py annotate()` (Dart 포트: lib/src/utils.dart)

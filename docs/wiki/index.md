---
tags: [index]

# Wiki Index

이 프로젝트의 구조화된 지식 베이스입니다. `docs/raw/` 로그에서 추출한 핵심 개념과 패턴을 정리했습니다.

---

## Concepts

| 개념 | 설명 | 별칭 |
|------|------|------|
| [[g2pkk-mecab-less-limits]] | 형태소 분석기 없이는 표면 문자열이 같은 두 발음 현상을 구분할 수 없어, | mecab-less 한계, 사이시옷 구분 불가, 밟 넓 ㄼ 모음 어미, 잘못이라는 서술격 |
| [[word-boundary-assimilation-policy]] | 규칙 테이블의 초성 패턴 `( ?)X`는 공백 한 칸을 옵션으로 통과시켜, 자음 동화· | 어절 경계 유음화, 경계 유음화 과잉, 이끈 리더, 제5항 어절 단위, ㄹ받침 ㄷ 경음화, 경계 경음화 비적용, guardCrossSpaceLiquidization, boundaryGuardChar |

---

## Patterns

| 패턴 | 설명 | 별칭 |
|------|------|------|
| [[dependency-injection-over-ffi-binding]] | 순수 Dart 라이브러리가 네이티브(FFI) 라이브러리의 기능을 필요로 할 때, | FFI 하드 의존 회피, MorphAnalyzer 주입 |

---

## Anti-Patterns

| 안티패턴 | 설명 | 별칭 |
|------|------|------|

---

## Answers

| 답변 | 설명 | 별칭 |
|------|------|------|

---

## Statistics

- Total concepts: 2
- Total patterns: 1
- Total anti-patterns: 0
- Total answers: 0
- Last updated: 2026-10-23

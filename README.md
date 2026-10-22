# g2pkk (경량화 버전)

Dart 환경을 위한 한국어 형태소-음소 변환(G2P) 라이브러리.
파이썬 [g2pkk](https://github.com/harmlessman/g2pkk) 라이브러리의 Dart 포팅 버전.

> **주의: 경량화 버전**
>
> 원본 라이브러리를 간소화한 버전으로 다음 제한 사항이 있음:
> * **Mecab 형태소 분석기**: 내장되지 않음. 대신 `MorphAnalyzer` 인터페이스로
>   외부 분석기를 주입할 수 있음 (아래 "Mecab 형태소 분석 연동" 참고).
>   주입하지 않으면 용언 경음화 등 형태소 기반 규칙이 휴리스틱/예외 사전으로 동작함.
> * **영어 발음 변환 (CMUDict)**: 사전 용량 문제로 전체 사전 대신 필수 단어만 포함된 축소 버전을 사용함.

## 주요 기능

- 한국어 텍스트 발음 변환 (예: `굳이 -> 구지`, `넓다 -> 널따`)
- 기본 한국어 발음 규칙 및 관용구 적용
- 숫자 발음 변환
- (선택) mecab 형태소 분석 연동 — 용언 경음화·단위명사 숫자·조사 처리
- 영어 단어 한글 발음 변환 (축소된 CMU dict 사용)

## 사용법

```dart
import 'package:g2pkk/g2pkk.dart';

void main() async {
  final g2p = G2p();

  // 기본 변환
  print(g2p.call('하나')); // 하나
  print(g2p.call('굳이')); // 구지

  // 숫자 변환
  print(g2p.call('123')); // 백이십삼

  // 영어 발음 변환 (사전 파일 필요)
  final g2pWithEng = await G2p.create(cmuDictPath: 'path/to/cmudict.json');
  print(g2pWithEng.call('game을 했다')); // 게이믈 핻따
}
```

## Mecab 형태소 분석 연동 (선택)

형태소 분석기를 주입하면 원본 g2pkk처럼 품사 태깅 기반 마커(`/P`, `/E`,
`/B`, `/J`)가 어노테이션 단계에서 생성되어, 용언 경음화(`앉다 -> 안따`),
단위성 의존명사 숫자(`3개 -> 세개`), 조사 `의` 처리가 실제 형태소 경계
기준으로 적용된다. 주입하지 않으면 기존 mecab-less 동작과 완전히 동일하다.

이 패키지는 mecab에 의존하지 않는다. 분석기는 소비자 쪽에서
[mecab.dart](https://github.com/kybird/mecab.dart) 등으로 구현해 주입한다:

```dart
import 'package:g2pkk/g2pkk.dart';
import 'package:mecab/mecab.dart';

class MecabKoAnalyzer implements MorphAnalyzer {
  MecabKoAnalyzer(this._mecab);
  final Mecab _mecab;

  @override
  List<(String, String)> pos(String text) =>
      _mecab.parse(text).map((t) => (t.surface, t.features[0])).toList();
}

void main() {
  // mecab-ko 사전 디렉터리 (mecab-ko-dic 빌드 산출물)
  final mecab = Mecab.init('C:/mecab/share/mecab-ko-dic');
  final g2p = G2p(mecab: MecabKoAnalyzer(mecab));

  print(g2p.call('앉다')); // 안따 (미주입 시: 안다)
  print(g2p.call('신다')); // 신따 (미주입 시: 신다)

  mecab.dispose();
}
```

품사 태그는 mecab-ko 규약(VV, EF, JKS, NNBC, ...)을 따른다. 분석 결과의
표면형을 이어붙인 것이 입력(공백 제거)과 일치하지 않으면 어노테이션은
자동으로 건너뛴다(원본 g2pkk `annotate()`와 동일한 안전장치).

## 한계점

파이썬 원본 대비 주요 차이점:
- 대형 어휘 사전이 없어 사이시옷 합성어 등은 관용구(idioms) 사전으로 처리함.
  (원본 파이썬 g2pkk도 `나랏일`을 `나라실`로 내놓는 반면, 이 포트는
  `나랏일===나란닐` 등 표준 발음 항목을 추가 보유함)
- 형태소 분석기 미주입 시 동사/형용사의 경음화 규칙 작동이 제한적임.
- 영어 발음 변환은 내장된 축소판 `cmudict.json` 단어들에 한정됨. (전체 사전 사용 시 `cmuDictPath` 옵션으로 직접 로드 필요)

## 라이선스

MIT License

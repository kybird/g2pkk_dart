# g2pkk (경량화 버전)

Dart 환경을 위한 한국어 형태소-음소 변환(G2P) 라이브러리.
파이썬 [g2pkk](https://github.com/harmlessman/g2pkk) 라이브러리의 Dart 포팅 버전.

> **주의: 경량화 버전**
>
> 원본 라이브러리를 간소화한 버전으로 다음 제한 사항이 있음:
> * **Mecab 형태소 분석기**: 기본 구조만 포팅됨. 품사 태깅을 통한 정밀한 용언/명사 구분 및 변환 기능이 정상 동작하지 않음.
> * **영어 발음 변환 (CMUDict)**: 사전 용량 문제로 전체 사전 대신 필수 단어만 포함된 축소 버전을 사용함.

## 주요 기능

- 한국어 텍스트 발음 변환 (예: `굳이 -> 구지`, `넓다 -> 널따`)
- 기본 한국어 발음 규칙 및 관용구 적용
- 숫자 발음 변환
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

## 한계점

파이썬 원본 대비 주요 차이점:
- 형태소 분석 기능 부재로 인해 동사/형용사의 경음화 규칙 작동이 제한적임.
- 영어 발음 변환은 내장된 축소판 `cmudict.json` 단어들에 한정됨. (전체 사전 사용 시 `cmuDictPath` 옵션으로 직접 로드 필요)

## 라이선스

MIT License

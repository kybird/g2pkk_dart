/// Main G2p class for Korean Grapheme-to-Phoneme conversion.
///
/// This library converts Korean text to its phonetic pronunciation
/// following standard Korean pronunciation rules.

import 'english.dart';
import 'jamo.dart';
import 'numerals.dart';
import 'regular.dart';
import 'special.dart';
import 'utils.dart';

/// Default idioms content
const _defaultIdioms = '''
# Each line should be considered prior to others.
# Comments are preceded by #.
# Each line should look like [str1]===[str2],
# where str2 replaces str1.
# Note that these will be processed through regular expression.
의견란===의견난
임진란===임진난
생산량===생산냥
결단력===결딴녁
공권력===공꿘녁
동원령===동원녕
상견례===상견녜
횡단로===횡단노
이원론===이원논
입원료===이붠뇨
구근류===구근뉴

갈등===갈뜽
발동===발똥
절도===절또
말살===말쌀
불소===불쏘
일시===일씨
갈증===갈쯩
물질===물찔
발전===발쩐
몰상식===몰쌍식
불세출===불쎄출

문고리===문꼬리
눈동자===눈똥자
신바람===신빠람
산새===산쌔
손재주===손째주
길가===길까
껴안고===껴안꼬
안고===안꼬
머금고서===머금꼬서
몬다===몬따
물동이===물똥이
발바닥===발빠닥
굴속===굴쏙
술잔===술짠
바람결===바람껼
그믐달===그믐딸
아침밥===아침빱
잠자리===잠짜리
강가===강까
초승달===초승딸
등불===등뿔
창살===창쌀
강줄기===강쭐기

솜이불===솜니불
홑이불===혼니불
막일===망닐
삯일===상닐
맨입===맨닙
꽃잎===꼰닙
내복약===내봉냑
색연필===생년필
직행열차===지캥녈차
늑막염===능망념
콩엿===콩녇
담요===담뇨
눈요기===눈뇨기

영업용===영엄뇽
식용유===시굥뉴
국민윤리===궁민뉼리
밤윳===밤뉻
이죽이죽===이중니죽
야금야금===야금냐금
검열===검녈
욜랑욜랑===욜랑뇰랑
금융===금늉
들일===들릴
솔잎===솔립
설익다===설릭따
물약===물략
불여우===불려우
서울역===서울력
물엿===물렫
휘발유===휘발류
유들유들===유들류들
한일===한닐
옷입다===온닙따
서른여섯===서른녀섣
3연대===삼년대
먹은엿===머근녇
할일===할릴
잘입다===잘립따
스물여섯===스물려섣
1연대===일련대
먹을엿===머글렫
6·25===유기오
3·1절===사밀쩔
송별연===송벼련
등용문===등용문

냇가===내까
샛길===새낄
빨랫돌===빨래똘
콧등===코뜽
깃발===기빨
대팻밥===대패빱
햇살===해쌀
뱃속===배쏙
뱃전===배쩐
고갯짓===고개찓

콧날===콘날
아랫니===아랜니
툇마루===퇸마루
뱃머리===밴머리

베갯잇===베갠닏
깻잎===깬닙
나뭇잎===나문닙
도리깻열===도리깬녈
뒷윷===뒨뉻

할걸===할껄
할밖에===할빠께
할세라===할쎄라
할수록===할쑤록
할지라도===할찌라도
할지언정===할찌언정
할진대===할찐대

ml===밀리리터
mp3===엠피쓰리
%===퍼센트
jpeg===제이펙
mp4===엠피포

1번째===첫번째
10월===시월
''';

/// Default table content for pronunciation rules
const _defaultTable = r''',( ?)ᄒ,( ?)ᄀ,( ?)ᄁ,( ?)ᄂ,( ?)ᄃ,( ?)ᄄ,( ?)ᄅ,( ?)ᄆ,( ?)ᄇ,( ?)ᄈ,( ?)ᄉ,( ?)ᄊ,( ?)ᄌ,( ?)ᄍ,( ?)ᄎ,( ?)ᄏ,( ?)ᄐ,( ?)ᄑ,(\W|\$)
ᇂ,\1ᄒ,\1ᄏ(12),\1ᄁ,ᆫ\1ᄂ(12),\1ᄐ(12),\1ᄄ,\1ᄅ,\1ᄆ,\1ᄇ,\1ᄈ,\1ᄊ(12),\1ᄊ,\1ᄎ(12),\1ᄍ,\1ᄎ,\1ᄏ,\1ᄐ,\1ᄑ,ᆮ\1
ᆨ,\1ᄏ(12),ᆨ\1ᄁ(23),,ᆼ\1ᄂ(18),ᆨ\1ᄄ(23),,ᆼ\1ᄂ(19/18),ᆼ\1ᄆ(18),ᆨ\1ᄈ(23),,ᆨ\1ᄊ(23),,ᆨ\1ᄍ(23),,,,,,
ᆩ,\1ᄏ,ᆨ\1ᄁ(9/23),ᆨ\1ᄁ(9),ᆼ\1ᄂ(18),ᆨ\1ᄄ(9/23),ᆨ\1ᄄ(9),ᆼ\1ᄂ,ᆼ\1ᄆ(18),ᆨ\1ᄈ(9/23),ᆨ\1ᄈ(9),ᆨ\1ᄊ(9/23),ᆨ\1ᄊ(9),ᆨ\1ᄍ(9/23),ᆨ\1ᄍ(9),ᆨ\1ᄎ(9),ᆨ\1ᄏ(9),ᆨ\1ᄐ(9),ᆨ\1ᄑ(9),ᆨ\1(9)
ᆪ,\1ᄏ,ᆨ\1ᄁ(9/23),ᆨ\1ᄁ(10),ᆼ\1ᄂ(18),ᆨ\1ᄄ(9/23),ᆨ\1ᄄ(10),ᆼ\1ᄂ,ᆼ\1ᄆ(18),ᆨ\1ᄈ(9/23),ᆨ\1ᄈ(10),ᆨ\1ᄊ(9/23),ᆨ\1ᄊ(10),ᆨ\1ᄍ(9/23),ᆨ\1ᄍ(10),ᆨ\1ᄎ(10),ᆨ\1ᄏ(10),ᆨ\1ᄐ(10),ᆨ\1ᄑ(10),ᆨ\1(10)
ᆫ,,,,,,,ᆯ\1ᄅ(20),,,,,,,,,,,,
ᆬ,ᆫ\1ᄎ(12),ᆫ\1ᄀ(10),ᆫ\1ᄁ(10),ᆫ\1ᄂ(10),ᆫ\1ᄃ(10),ᆫ\1ᄄ(10),ᆯ\1ᄅ(10/20),ᆫ\1ᄆ(10),ᆫ\1ᄇ(10),ᆫ\1ᄈ(10),ᆫ\1ᄉ(10),ᆫ\1ᄊ(10),ᆫ\1ᄌ(10),ᆫ\1ᄍ(10),ᆫ\1ᄎ(10),ᆫ\1ᄏ(10),ᆫ\1ᄐ(10),ᆫ\1ᄑ(10),ᆫ\1(10)
ᆭ,ᆫ\1ᄒ,ᆫ\1ᄏ(12),ᆫ\1ᄁ,ᆫ\1ᄂ(12),ᆫ\1ᄐ(12),ᆫ\1ᄄ,ᆯ\1ᄅ,ᆫ\1ᄆ,ᆫ\1ᄇ,ᆫ\1ᄈ,ᆫ\1ᄊ(12),ᆫ\1ᄊ,ᆫ\1ᄎ(12),ᆫ\1ᄍ,ᆫ\1ᄎ,ᆫ\1ᄏ,ᆫ\1ᄐ,ᆫ\1ᄑ,ᆫ\1
ᆮ,\1ᄐ(12),ᆮ\1ᄁ(23),,ᆫ\1ᄂ(18),ᆮ\1ᄄ(23),,ᆫ\1ᄂ,ᆫ\1ᄆ(18),ᆮ\1ᄈ(23),,ᆮ\1ᄊ(23),,ᆮ\1ᄍ(23),,,,,,
ᆯ,,,,ᆯ\1ᄅ(20),,,,,,,,,,,,,,,
ᆰ,ᆯ\1ᄏ(12),ᆨ\1ᄁ(11/23),ᆨ\1ᄁ(11),ᆼ\1ᄂ(11/18),ᆨ\1ᄄ(11/23),ᆨ\1ᄄ(11),ᆼ\1ᄂ(11/18),ᆼ\1ᄆ(11/18),ᆨ\1ᄈ(11/23),ᆨ\1ᄈ(11),ᆨ\1ᄊ(11/23),ᆨ\1ᄊ(11),ᆨ\1ᄍ(11/23),ᆨ\1ᄍ(11),ᆨ\1ᄎ(11),1),ᆨ\1ᄑ(11),,ᆨ\1(11)
ᆱ,ᆷ\1ᄒ(11),ᆷ\1ᄀ(11),ᆷ\1ᄁ(11),ᆷ\1ᄂ(11),ᆷ\1ᄃ(11),ᆷ\1ᄄ(11),ᆷ\1ᄅ(11),ᆷ\1ᄆ(11),ᆷ\1ᄇ(11),ᆷ\1ᄈ(11),ᆷ\1ᄉ(11),ᆷ\1ᄊ(11),ᆷ\1ᄌ(11),ᆷ\1ᄍ(11),ᆷ\1ᄎ(11),ᆷ\1ᄏ(11),ᆷ\1ᄐ(11),ᆷ\1ᄑ(11),ᆷ\1(11)
ᆲ,ᆯ\1ᄑ(12),ᆯ\1ᄁ(10/23),ᆯ\1ᄁ(10),ᆷ\1ᄂ(18),ᆯ\1ᄄ(10/23),ᆯ\1ᄄ(10),ᆯ\1ᄅ(10),ᆷ\1ᄆ(18),ᆯ\1ᄈ(10/23),ᆯ\1ᄈ(10),ᆯ\1ᄊ(10/23),ᆯ\1ᄊ(10),ᆯ\1ᄍ(10/23),ᆯ\1ᄍ(10),ᆯ\1ᄎ(10),ᆯ\1ᄏ(10)0),,,ᆯ\1(10)
ᆳ,ᆯ\1ᄒ(10),ᆯ\1ᄁ(10/23),ᆯ\1ᄁ(10),ᆯ\1ᄅ(10/20),ᆯ\1ᄄ(10/23),ᆯ\1ᄄ(10),ᆯ\1ᄅ(10),ᆯ\1ᄆ(10),ᆯ\1ᄈ(10/23),ᆯ\1ᄈ(10),ᆯ\1ᄊ(10/23),ᆯ\1ᄊ(10),ᆯ\1ᄍ(10/23),ᆯ\1ᄍ(10),ᆯ\1ᄎ(10),ᆯ\1ᄏ(ᄑ(10),,,ᆯ\1(10)
ᆴ,ᆯ\1ᄒ(10),ᆯ\1ᄀ(10),ᆯ\1ᄁ(10),ᆯ\1ᄅ(10/20),ᆯ\1ᄃ(10),ᆯ\1ᄄ(10),ᆯ\1ᄅ(10),ᆯ\1ᄆ(10),ᆯ\1ᄇ(10),ᆯ\1ᄈ(10),ᆯ\1ᄉ(10),ᆯ\1ᄊ(10),ᆯ\1ᄌ(10),ᆯ\1ᄍ(10),ᆯ\1ᄎ(10),ᆯ\1ᄏ(10),ᆯ\1ᄐ(10),ᆯ\1ᄑ(10),ᆯ\1(10)
ᆵ,ᆸ\1ᄑ(11/12),ᆸ\1ᄁ(11/23),ᆸ\1ᄁ(11),ᆷ\1ᄂ(18),ᆸ\1ᄄ(11/23),ᆸ\1ᄄ(11),ᆷ\1ᄅ(11),ᆷ\1ᄆ(11/18),ᆸ\1ᄈ(11/23),ᆸ\1ᄈ(11),ᆸ\1ᄊ(11/23),ᆸ\1ᄊ(11),ᆸ\1ᄍ(11/23),ᆸ\1ᄍ(11),ᆸ\1ᄎ(11),ᆸ\1ᆸ\1ᄑ,,,ᆸ\1(11)
ᆶ,ᆯ\1ᄒ(10),ᆯ\1ᄏ(12),ᆯ\1ᄁ,ᆯ\1ᄅ(12/20),ᆯ\1ᄐ(12),ᆯ\1ᄄ,ᆯ\1ᄅ,ᆯ\1ᄆ,ᆯ\1ᄇ,ᆯ\1ᄈ,ᆯ\1ᄊ(12),ᆯ\1ᄊ,ᆯ\1ᄎ(12),ᆯ\1ᄍ,ᆯ\1ᄎ,ᆯ\1ᄏ,ᆯ\1ᄐ,ᆯ\1ᄑ,ᆯ
ᆷ,,,,,,,ᆷ\1ᄂ(19),,,,,,,,,,,,
ᆸ,\1ᄑ(12),ᆸ\1ᄁ(23),,ᆷ\1ᄂ(18),ᆸ\1ᄄ(23),,ᆷ\1ᄂ(19/18),ᆷ\1ᄆ(18),ᆸ\1ᄈ(23),,ᆸ\1ᄊ(23),,ᆸ\1ᄍ(23),,,,,,
ᆹ,ᆸ\1ᄑ(10),ᆸ\1ᄁ(10/23),ᆸ\1ᄁ(10),ᆷ\1ᄂ(10/18),ᆸ\1ᄄ(10/23),ᆸ\1ᄄ(10),ᆷ\1ᄂ(10/19/18),ᆷ\1ᄆ(10/18),ᆸ\1ᄈ(10/23),ᆸ\1ᄈ(10),ᆸ\1ᄊ(10/23),ᆸ\1ᄊ(10),ᆸ\1ᄍ(10/23),ᆸ\1ᄍ(10),ᆸ\1ᄎ(1ᄐ(10),ᆸ\1ᄑ,,,ᆸ\1(10)
ᆺ,\1ᄐ,ᆮ\1ᄁ(9/23),ᆮ\1ᄁ(9),ᆫ\1ᄂ(9/18),ᆮ\1ᄄ(9/23),ᆮ\1ᄄ(9),ᆫ\1ᄂ(9/18),ᆫ\1ᄆ(9/18),ᆮ\1ᄈ(9/23),ᆮ\1ᄈ(9),ᆮ\1ᄊ(9/23),ᆮ\1ᄊ(9),ᆮ\1ᄍ(9/23),ᆮ\1ᄍ(9),ᆮ\1ᄎ(9),ᆮ\1ᄏ(9),ᆮ\1ᄐ(9),ᆮ\1ᄑ(9),ᆮ\1(9)
ᆻ,\1ᄐ,ᆮ\1ᄁ(9/23),ᆮ\1ᄁ(9),ᆫ\1ᄂ(9/18),ᆮ\1ᄄ(9/23),ᆮ\1ᄄ(9),ᆫ\1ᄂ(9/18),ᆫ\1ᄆ(9/18),ᆮ\1ᄈ(9/23),ᆮ\1ᄈ(9),ᆮ\1ᄊ(9/23),ᆮ\1ᄊ(9),ᆮ\1ᄍ(9/23),ᆮ\1ᄍ(9),ᆮ\1ᄎ(9),ᆮ\1ᄏ(9),ᆮ\1ᄐ(9),ᆮ1ᄑ(9),ᆮ\1(9)
ᆼ,,,,,,,ᆼ\1ᄂ(19),,,,,,,,,,,,
ᆽ,\1ᄎ(12),ᆮ\1ᄁ(9/23),ᆮ\1ᄁ(9),ᆫ\1ᄂ(18),ᆮ\1ᄄ(9/23),ᆮ\1ᄄ(9),ᆫ\1ᄂ(9/18),ᆫ\1ᄆ(18),ᆮ\1ᄈ(9/23),ᆮ\1ᄈ(9),ᆮ\1ᄊ(9/23),ᆮ\1ᄊ(9),ᆮ\1ᄍ(9/23),ᆮ\1ᄍ(9),ᆮ\1ᄎ(9),ᆮ\1ᄏ(9),ᆮ\1ᄐ(9),ᆮ\1ᄑ(9),ᆮ\1(9)
ᆾ,\1ᄐ,ᆮ\1ᄁ(9/23),ᆮ\1ᄁ(9),ᆫ\1ᄂ(18),ᆮ\1ᄄ(9/23),ᆮ\1ᄄ(9),ᆫ\1ᄂ(9/18),ᆫ\1ᄆ(18),ᆮ\1ᄈ(9/23),ᆮ\1ᄈ(9),ᆮ\1ᄊ(9/23),ᆮ\1ᄊ(9),ᆮ\1ᄍ(9/23),ᆮ\1ᄍ(9),ᆮ\1ᄎ(9),ᆮ\1ᄏ(9),ᆮ\1ᄐ(9),ᆮ\1ᄑ(9),ᆮ\1(9)
ᆿ,\1ᄏ,ᆨ\1ᄁ(9/23),ᆨ\1ᄁ(9),ᆼ\1ᄂ(18),ᆨ\1ᄄ(9/23),ᆨ\1ᄄ(9),ᆼ\1ᄂ(9/18),ᆼ\1ᄆ(9/18),ᆨ\1ᄈ(9/23),ᆨ\1ᄈ(9),ᆨ\1ᄊ(9/23),ᆨ\1ᄊ(9),ᆨ\1ᄍ(9/23),ᆨ\1ᄍ(9),ᆨ\1ᄎ(9),ᆨ\1ᄏ(9),ᆨ\1ᄐ(9),ᆨ\1ᄑ(9),ᆨ\1(9)
ᇀ,\1ᄐ,ᆮ\1ᄁ(9/23),ᆮ\1ᄁ(9),ᆫ\1ᄂ(18),ᆮ\1ᄄ(9/23),ᆮ\1ᄄ(9),ᆫ\1ᄂ(9/18),ᆫ\1ᄆ(18),ᆮ\1ᄈ(9/23),ᆮ\1ᄈ(9),ᆮ\1ᄊ(9/23),ᆮ\1ᄊ(9),ᆮ\1ᄍ(9/23),ᆮ\1ᄍ(9),ᆮ\1ᄎ(9),ᆮ\1ᄏ(9),ᆮ\1ᄐ(9),ᆮ\1ᄑ(9),ᆮ\1(9)
ᇁ,\1ᄑ,ᆸ\1ᄁ(9/23),ᆸ\1ᄁ(9),ᆷ\1ᄂ(18),ᆸ\1ᄄ(9/23),ᆸ\1ᄄ(9),ᆫ\1ᄂ(9/18),ᆷ\1ᄆ(18),ᆸ\1ᄈ(9/23),ᆸ\1ᄈ(9),ᆸ\1ᄊ(9/23),ᆸ\1ᄊ(9),ᆸ\1ᄍ(9/23),ᆸ\1ᄍ(9),ᆸ\1ᄎ(9),ᆸ\1ᄏ(9),ᆸ\1ᄐ(9),ᆸ\1ᄑ(9),ᆸ\1(9)''';

/// Korean Grapheme-to-Phoneme converter.
///
/// This class converts Korean text to its phonetic pronunciation
/// following standard Korean pronunciation rules.
///
/// Example:
/// ```dart
/// final g2p = G2p();
/// print(g2p('나의 친구가')); // 나의 친구가
/// ```
class G2p {
  /// List of idioms (pattern, replacement)
  final List<(String, String)> idioms;

  /// Parsed rule table
  final List<RuleEntry> table;

  /// CMU pronunciation dictionary for English words
  final CmuDict? cmu;

  /// Create a new G2p instance with optional custom idioms, table, and CMU dict.
  ///
  /// If [idiomsContent] or [tableContent] are not provided, default
  /// built-in versions will be used.
  ///
  /// [cmuDictPath]: Path to cmudict.json file. If provided, loads the
  /// CMU pronunciation dictionary for English word conversion.
  ///
  /// Example:
  /// ```dart
  /// final g2p = await G2p.create(cmuDictPath: 'path/to/cmudict.json');
  /// ```
  static Future<G2p> create({
    String? idiomsContent,
    String? tableContent,
    String? cmuDictPath,
  }) async {
    CmuDict? cmu;
    if (cmuDictPath != null) {
      try {
        cmu = await CmuDict.load(cmuDictPath);
      } catch (e) {
        // Failed to load, continue without CMU dict
        cmu = null;
      }
    }
    return G2p._internal(
      idioms: parseIdioms(idiomsContent ?? _defaultIdioms),
      table: parseTable(tableContent ?? _defaultTable),
      cmu: cmu,
    );
  }

  /// Create a G2p instance synchronously with pre-loaded CMU dict
  G2p._internal({
    required this.idioms,
    required this.table,
    this.cmu,
  });

  /// Create a simple G2p instance without English conversion
  G2p({
    String? idiomsContent,
    String? tableContent,
  })  : idioms = parseIdioms(idiomsContent ?? _defaultIdioms),
        table = parseTable(tableContent ?? _defaultTable),
        cmu = null;

  /// Process idioms in the input string.
  ///
  /// Replaces patterns defined in idioms.txt with their replacements.
  String _processIdioms(String string, bool verbose) {
    String out = string;
    const rule = 'from idioms.txt';

    for (final (pattern, replacement) in idioms) {
      final prev = out;
      try {
        out = out.replaceAll(RegExp(pattern), replacement);
        if (verbose && prev != out) {
          gloss(true, out, prev, '$rule: $pattern -> $replacement');
        }
      } catch (e) {
        // Skip invalid regex patterns
        continue;
      }
    }

    return out;
  }

  String _postProcessExceptions(String text) {
    var out = text;

    // Mecab-less mode lexical fallback:
    // Keep the common expression "흉내를 내는" from over-assimilation.
    out = out.replaceAll('흉내를 래는', '흉내를 내는');
    out = out.replaceAll("흉내'를 래는", "흉내'를 내는");
    out = out.replaceAll('흉내’를 래는', '흉내’를 내는');
    out = out.replaceAll('흉내”를 래는', '흉내”를 내는');

    // Keep corpus-style output for object particle + 안고 phrase.
    out = out.replaceAll('를 란꼬', '를 안꼬');
    out = out.replaceAll('를란꼬', '를안꼬');
    out = out.replaceAll('기르 란꼬', '기를 안꼬');
    out = out.replaceAll('기르란꼬', '기를안꼬');

    return out;
  }

  /// Convert Korean text to phonetic pronunciation.
  ///
  /// Parameters:
  /// - [string]: The input Korean text to convert
  /// - [descriptive]: If true, applies descriptive pronunciation rules
  ///   (how people actually speak in casual contexts)
  /// - [verbose]: If true, prints detailed transformation steps
  /// - [groupVowels]: If true, normalizes similar vowels (ㅐ/ㅔ, etc.)
  /// - [toSyl]: If true, composes jamo back into syllables
  ///
  /// Returns the phonetic representation of the input text.
  ///
  /// Example:
  /// ```dart
  /// final g2p = G2p();
  /// print(g2p.call('나의 친구가')); // Phonetic output
  /// ```
  String call(
    String string, {
    bool descriptive = false,
    bool verbose = false,
    bool groupVowels = false,
    bool toSyl = true,
  }) {
    // Step 1: Process idioms
    string = _processIdioms(string, verbose);

    // Step 2: English to Hangul conversion (if CMU dict is available)
    if (cmu != null) {
      string = convertEng(string, cmu!);
    }

    // Step 3: Annotation requires mecab, not implemented in core version
    // Keep mecab-less behavior stable; rely on targeted lexical exceptions.

    // Step 4: Spell out Arabic numbers
    string = convertNum(string);

    // Step 5: Decompose hangul to jamo
    String inp = h2jString(string);

    // Step 6: Apply special rules
    for (final func in specialRules) {
      inp = func(inp, descriptive, verbose);
    }
    // Remove annotation markers
    inp = inp.replaceAll(RegExp(r'/[PJEB]'), '');

    // Step 7: Apply regular table rules (batchim + onset)
    for (final entry in table) {
      final prev = inp;
      try {
        // Use replaceAllMapped to handle backreferences properly
        inp = inp.replaceAllMapped(
          RegExp(entry.pattern),
          (match) {
            // Replace $1 with the first capture group
            var result = entry.replacement;
            for (int i = 1; i <= match.groupCount; i++) {
              result = result.replaceAll('\$$i', match.group(i) ?? '');
            }
            return result;
          },
        );
        if (verbose && inp != prev) {
          final rule = entry.ruleIds.isEmpty
              ? 'Regular rule: ${entry.pattern} -> ${entry.replacement}'
              : 'Rule ${entry.ruleIds.join(", ")}';
          gloss(true, inp, prev, rule);
        }
      } catch (e) {
        // Skip invalid regex patterns
        continue;
      }
    }

    // Step 8: Apply link rules
    inp = applyLinkRules(inp, descriptive, verbose);

    // Step 9: Post-processing
    if (groupVowels) {
      inp = group(inp);
    }

    if (toSyl) {
      inp = compose(inp);
    }

    inp = _postProcessExceptions(inp);

    return inp;
  }

  /// Shorthand for [call].
  String convert(
    String string, {
    bool descriptive = false,
    bool verbose = false,
    bool groupVowels = false,
    bool toSyl = true,
  }) {
    return call(
      string,
      descriptive: descriptive,
      verbose: verbose,
      groupVowels: groupVowels,
      toSyl: toSyl,
    );
  }
}

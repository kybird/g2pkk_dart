import 'package:g2pkk/g2pkk.dart';

void main() {
  // Check the rule table entry for ᆹᄋ
  print('Rule table entry for ᆹᄋ:');
  print('Looking at row for ᆹ and column for ᄋ');
  print('');
  
  print('From the table (line 171 in g2pkk.dart):');
  print('ᆹ,ᆸ\1ᄑ(10),ᆸ\1ᄁ(10/23),...,ᆸ\1ᄑ,,,ᆸ\1(10)');
  print('');
  print('Column 2 (after ᆹ,) is ᄋ onset');
  print('Cell value: ᆸ\1ᄑ(10)');
  print('This means: ᆹᄋ -> ᆸ\$1ᄑ');
  print('Pattern: ᆹᄋ');
  print('Replacement: ᆸ\1ᄑ');
  print('Rule IDs: [10]');
  print('');
  print('So when the regex matches ᆹᄋ, it replaces with ᆸ\1ᄑ');
  print('But what is \1? It is the first capture group in the pattern.');
  print('Looking at the pattern for ᄋ onset:');
  print('( ?)ᄋ  (from line 152, column header for ᄋ)');
  print('');
  print('So the full pattern is: ( ?)ᆹ( ?)ᄋ');
  print('Wait, that doesn\'t look right. Let me check the actual pattern format.');
  print('');
  print('Actually, the column headers define the onset pattern.');
  print('Column 2 header: ( ?)ᄋ');
  print('Row header: ᆹ');
  print('So the full pattern is: ᆹ( ?)ᄋ');
  print('Replacement: ᆸ\$1ᄑ');
  print('');
  print('This means: ᆹ followed by optional space followed by ᄋ');
  print('is replaced with: ᆸ followed by the optional space followed by ᄑ');
}

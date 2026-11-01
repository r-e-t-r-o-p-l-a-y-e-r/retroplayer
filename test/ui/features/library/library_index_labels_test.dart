/// Content-driven library index labels and scroll offset estimates.
///
/// Evidence:
/// - `libraryIndexCharFor maps letters digits and other`
/// - `libraryIndexLabelsFor orders hash letters bullet`
/// - `firstLibraryIndexMatching finds first title`
/// - `estimateLibraryRowScrollOffset accounts for sections`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/library/library_index_labels.dart';

void main() {
  test('libraryIndexCharFor maps letters digits and other', () {
    expect(libraryIndexCharFor('Abba'), 'A');
    expect(libraryIndexCharFor('zebra'), 'Z');
    expect(libraryIndexCharFor('123 Mix'), libraryIndexDigitChar);
    expect(libraryIndexCharFor('!Weird'), libraryIndexOtherChar);
    expect(libraryIndexCharFor(''), libraryIndexDigitChar);
  });

  test('libraryIndexLabelsFor orders bullet hash letters', () {
    expect(
      libraryIndexLabelsFor(const ['Zoo', '1 Hit', '.dot', 'Alpha', 'Beta']),
      [libraryIndexOtherChar, libraryIndexDigitChar, 'A', 'B', 'Z'],
    );
  });

  test('firstLibraryIndexMatching finds first title', () {
    const titles = ['Alpha', 'Beta', 'Zebra', '1 Hit'];
    expect(firstLibraryIndexMatching(titles, 'Z'), 2);
    expect(firstLibraryIndexMatching(titles, libraryIndexDigitChar), 3);
    expect(firstLibraryIndexMatching(titles, 'Q'), isNull);
  });

  test('estimateLibraryRowScrollOffset accounts for sections', () {
    // Folders only: header + 2nd folder
    expect(
      estimateLibraryRowScrollOffset(
        rowIndex: 1,
        folderCount: 3,
        playlistCount: 0,
        audioCount: 0,
        sectionHeaderExtent: 10,
        rowExtent: 20,
      ),
      10 + 20,
    );

    // First playlist after folders + divider + header
    expect(
      estimateLibraryRowScrollOffset(
        rowIndex: 2,
        folderCount: 2,
        playlistCount: 2,
        audioCount: 0,
        sectionHeaderExtent: 10,
        dividerExtent: 5,
        rowExtent: 20,
      ),
      10 + 40 + 5 + 10,
    );
  });
}

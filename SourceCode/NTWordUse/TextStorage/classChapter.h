/*================================================================================*
 *                                                                                *
 *                           NTWordUse: classChapter.h                            *
 *                           =========================                            *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classVerse.h"

NS_ASSUME_NONNULL_BEGIN

@interface classChapter : NSObject

@property (nonatomic) NSInteger noOfVerses;
@property (retain) NSMutableDictionary *verseList;
@property (retain) NSMutableDictionary *verseLookup;
@property (retain) NSString *chapterRef;

- (id) init;
- (classVerse *) addVerse: (NSString *) verseNo;
- (NSString *) getVerseText: (NSInteger) verseSeq;
- (NSString *) getVerseRefBySequence: (NSInteger) seq;

@end

NS_ASSUME_NONNULL_END

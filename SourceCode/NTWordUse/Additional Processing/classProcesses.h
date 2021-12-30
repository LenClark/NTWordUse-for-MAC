/*================================================================================*
 *                                                                                *
 *                          NTWordUse: classProcesses.h                           *
 *                          ===========================                           *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface classProcesses : NSObject

- (id) init;
- (NSInteger) getParseInfo: (NSString *) inParseInfo;
- (NSInteger) getLxxParseInfo: (NSString *) inParseInfo withCode: (NSInteger) categoryCode;
- (NSString *) cleanTextWord: (NSString *) givenWord withInitialChatacter: (NSString *) rootInitial;
- (NSString *) nakedWord: (NSString *) sourceWord;
- (NSInteger) getReferenceCode: (NSInteger) bookNo andChapter: (NSInteger) chapNo andVerse: (NSInteger) verseNo;
- (NSString *) getLowerCaseEquivalent: (NSString *) sourceCharacter;
- (NSArray *) simpleGkSort: (NSArray *) sourceArray;
- (NSString *) transliterateText: (NSString *) sourceString;

@end

NS_ASSUME_NONNULL_END

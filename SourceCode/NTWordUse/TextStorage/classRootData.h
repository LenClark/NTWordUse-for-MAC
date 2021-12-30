/*================================================================================*
 *                                                                                *
 *                           NTWordUse: classRootData.h                           *
 *                           ==========================                           *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classProcesses.h"
#import "classParsedItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface classRootData : NSObject

@property (nonatomic) bool isFoundInNT;
@property (nonatomic) NSInteger catCode;
@property (retain) NSString *rootWord;
@property (retain) NSString *rootTransliteration;
@property (retain) NSMutableDictionary *parsedDetail;
@property (retain) classProcesses *processRawData;

- (id) init;
- (void) addParsedText: (NSInteger) parseCode formOfWord: (NSString *) associatedWord bookNo: (NSInteger) bookNo chapNo: (NSInteger) chapNo verseNo: (NSInteger) verseNo
      chapterReference: (NSString *) givenChapRef verseRef: (NSString *) givenVerseRef isThisNT: (bool) isNT;
- (NSDictionary *) getParseList;

@end

NS_ASSUME_NONNULL_END

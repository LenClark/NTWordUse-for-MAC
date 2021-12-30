/*================================================================================*
 *                                                                                *
 *                           NTWordUse: classParsedItem.h                         *
 *                           ============================                         *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classReference.h"
#import "classProcesses.h"

NS_ASSUME_NONNULL_BEGIN

@interface classParsedItem : NSObject

@property (nonatomic) bool isInNt;
@property (nonatomic) bool isInLXX;
@property (nonatomic) NSInteger parseCode;
@property (retain) NSMutableDictionary *parsedWords;
@property (retain)NSMutableDictionary *referenceList;
@property (retain) classProcesses *processClass;

- (id) init;
- (void) setWord: (NSString *) candidateWord;
- (void) addReference: (NSInteger) refCode bookNo: (NSInteger) bookNo chapNo: (NSInteger) chapNo verseNo: (NSInteger) verseNo
         givenChapref: (NSString *) givenChapRef givenVerseRef: (NSString *) givenVerseRef isThisNT: (bool) isNT;
- (NSString *) getWords: (NSString *) rootWord;

@end

NS_ASSUME_NONNULL_END

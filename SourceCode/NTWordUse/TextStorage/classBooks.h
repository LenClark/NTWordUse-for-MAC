/*================================================================================*
 *                                                                                *
 *                            NTWordUse: classBooks.h                             *
 *                            =======================                             *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classChapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface classBooks : NSObject

@property (nonatomic) bool isNT;
@property (nonatomic) NSInteger noOfChapters;
@property (nonatomic) NSInteger actualBookNumber;
@property (retain) NSString *shortName;
@property (retain) NSString *commonName;
@property (retain) NSString *lxxName;
@property (retain) NSString *fileName;
@property (retain) NSMutableDictionary *chapterList;
@property (retain) NSMutableDictionary *chapterLookup;

- (id) init;
- (classChapter *) addChapter: (NSString *) chapterNo;
- (classChapter *) getChapterBySequence: (NSInteger) seq;

@end

NS_ASSUME_NONNULL_END

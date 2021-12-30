/*================================================================================*
 *                                                                                *
 *                           NTWordUse: classRefBook.h                            *
 *                           =========================                            *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classRefChapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface classRefBook : NSObject

@property (nonatomic) NSInteger bookRef;
@property (nonatomic) NSInteger chapterCount;
@property (retain) NSString *bookName;
@property (retain) NSMutableDictionary *listOfChapters;

- (classRefChapter *) addChapter: (NSInteger) chapterNo withStringVersion: (NSString *) chapterRef;

@end

NS_ASSUME_NONNULL_END

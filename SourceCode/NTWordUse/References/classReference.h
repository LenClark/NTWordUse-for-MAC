/*================================================================================*
 *                                                                                *
 *                           NTWordUse: classReference.h                          *
 *                           ===========================                          *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface classReference : NSObject

@property (nonatomic) bool isNT;
@property (nonatomic) NSInteger bookCode;
@property (nonatomic) NSInteger chapterNo;
@property (nonatomic) NSInteger verseNo;
@property (retain) NSString *givenChapterRef;
@property (retain) NSString *givenVerseRef;

@end

NS_ASSUME_NONNULL_END

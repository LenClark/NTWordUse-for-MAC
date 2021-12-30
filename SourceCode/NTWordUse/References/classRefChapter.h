/*================================================================================*
 *                                                                                *
 *                           NTWordUse: classRefChapter.h                         *
 *                           ============================                         *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface classRefChapter : NSObject

@property (retain) NSString *chapterRef;
@property (retain) NSMutableString *fullReference;

- (void) addReference: (NSString *) verseRef;

@end

NS_ASSUME_NONNULL_END

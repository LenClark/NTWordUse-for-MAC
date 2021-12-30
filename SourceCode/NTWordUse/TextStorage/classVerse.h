/*================================================================================*
 *                                                                                *
 *                            NTWordUse: classVerse.h                             *
 *                            =======================                             *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface classVerse : NSObject

@property (retain) NSMutableString *textOfVerse;

- (id) init;
- (void) addWord: (NSString *) word withPreChars: (NSString *) preChars followingChars: (NSString *) followingChars andPunctuation: (NSString *) punctuation;
@end

NS_ASSUME_NONNULL_END

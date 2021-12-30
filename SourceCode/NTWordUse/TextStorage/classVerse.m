/*=====================================================================================================*
 *                                                                                                     *
 *                                       NTWordUse: classVerse.m                                       *
 *                                       =======================                                       *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classVerse.h"

@implementation classVerse

@synthesize textOfVerse;

- (id) init
{
    self = [super init];
    textOfVerse = [[NSMutableString alloc] initWithString:@""];
    return self;
}

- (void) addWord: (NSString *) word withPreChars: (NSString *) preChars followingChars: (NSString *) followingChars andPunctuation: (NSString *) punctuation
{
    if ( [textOfVerse length] == 0) textOfVerse = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@", preChars, word, followingChars, punctuation];
    else [textOfVerse appendFormat: @" %@%@%@%@", preChars, word, followingChars, punctuation];
}

@end

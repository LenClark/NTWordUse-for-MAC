/*=====================================================================================================*
 *                                                                                                     *
 *                                     NTWordUse: classRefChapter.m                                    *
 *                                     ============================                                    *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classRefChapter.h"

@implementation classRefChapter

@synthesize chapterRef;
@synthesize fullReference;

- (id) init
{
    if( self = [super init])
    {
        fullReference = [[NSMutableString alloc] initWithString:@""];
    }
    return self;
}

- (void) addReference: (NSString *) verseRef
{
    if( [fullReference length] == 0) [fullReference appendFormat:@"%@:%@", chapterRef, verseRef];
    else [fullReference appendFormat:@", %@", verseRef];
}

@end

/*=====================================================================================================*
 *                                                                                                     *
 *                                     NTWordUse: classReference.m                                     *
 *                                     ===========================                                     *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classReference.h"

@implementation classReference

@synthesize isNT;
@synthesize bookCode;
@synthesize chapterNo;
@synthesize verseNo;
@synthesize givenChapterRef;
@synthesize givenVerseRef;

- (id) init
{
    self = [super init];
    isNT = true;
    givenChapterRef = @"";
    givenVerseRef = @"";
    return self;
}

@end

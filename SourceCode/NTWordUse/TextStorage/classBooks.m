/*=====================================================================================================*
 *                                                                                                     *
 *                                       NTWordUse: classBooks.m                                       *
 *                                       =======================                                       *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classBooks.h"

@implementation classBooks

@synthesize isNT;
@synthesize noOfChapters;
@synthesize actualBookNumber;
@synthesize shortName;
@synthesize commonName;
@synthesize lxxName;
@synthesize fileName;
@synthesize chapterList;
@synthesize chapterLookup;

- (id) init
{
    self = [super init];
    chapterList = [[NSMutableDictionary alloc] init];
    chapterLookup = [[NSMutableDictionary alloc] init];
    noOfChapters = 0;
    return self;
}

- (classChapter *) addChapter: (NSString *) chapterNo
{
    classChapter *currentChapter;

    if( [chapterList doesContain: chapterNo] )
    {
        currentChapter = [chapterList objectForKey:chapterNo];
    }
    else
    {
        currentChapter = [[classChapter alloc] init];
        [chapterList setValue:currentChapter forKey:chapterNo];
        [chapterLookup setValue:chapterNo forKey:[[NSString alloc] initWithFormat:@"%ld", ++noOfChapters]];
    }
    return currentChapter;
}

- (classChapter *) getChapterBySequence: (NSInteger) seq
{
    NSString *chapNo;
    classChapter *currentChapter;

    if( [chapterLookup doesContain:[[NSString alloc] initWithFormat:@"%ld", seq]] )
    {
        chapNo = [[NSString alloc] initWithString:[chapterLookup objectForKey:[[NSString alloc] initWithFormat:@"%ld", seq]]];
        if( [chapterList doesContain: chapNo])
        {
            currentChapter = [chapterList objectForKey:chapNo];
        }
    }
    return currentChapter;
}

@end

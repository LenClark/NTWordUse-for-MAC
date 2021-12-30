/*=====================================================================================================*
 *                                                                                                     *
 *                                      NTWordUse: classChapter.m                                      *
 *                                      =========================                                      *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classChapter.h"

@implementation classChapter

@synthesize noOfVerses;
@synthesize verseList;
@synthesize verseLookup;
@synthesize chapterRef;

- (id) init
{
    self = [super init];
    verseList = [[NSMutableDictionary alloc] init];
    verseLookup = [[NSMutableDictionary alloc] init];
    noOfVerses = 0;
    return self;
}

- (classVerse *) addVerse: (NSString *) verseNo
{
    classVerse *currentVerse;

    if( [verseList doesContain:verseNo])
    {
        currentVerse = [verseList objectForKey:verseNo];
    }
    else
    {
        currentVerse = [[classVerse alloc] init];
        [verseList setValue:currentVerse forKey:verseNo];
        [verseLookup setValue:verseNo forKey:[[NSString alloc] initWithFormat:@"%ld",++noOfVerses]];
    }
    return currentVerse;
}

- (NSString *) getVerseText: (NSInteger) verseSeq
{
    NSString *verseRef;
    classVerse *currentVerse;

    currentVerse = nil;
    if( [verseLookup doesContain:[[NSString alloc] initWithFormat:@"%ld", verseSeq]])
    {
        verseRef = [verseLookup objectForKey:[[NSString alloc] initWithFormat:@"%ld",verseSeq]];
        if( [verseList doesContain: verseRef])
        {
            currentVerse = [verseList objectForKey:verseRef];
        }
    }
    if (currentVerse == nil) return @"";
    else return [currentVerse textOfVerse];
}

- (NSString *) getVerseRefBySequence: (NSInteger) seq
{
    NSString *verseRef;

    verseRef = @"";
    if( [verseLookup doesContain:[[NSString alloc] initWithFormat:@"%ld", seq]])
    {
        verseRef = [verseLookup objectForKey:[[NSString alloc] initWithFormat:@"%ld", seq]];
    }
    return verseRef;
}

@end

/*=====================================================================================================*
 *                                                                                                     *
 *                                      NTWordUse: classRefBook.m                                      *
 *                                      =========================                                      *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classRefBook.h"

@implementation classRefBook

@synthesize bookRef;
@synthesize chapterCount;
@synthesize bookName;
@synthesize listOfChapters;

- (id) init
{
    if( self = [super init])
    {
        listOfChapters = [[NSMutableDictionary alloc] init];
        chapterCount = 0;
    }
    return self;
}

- (classRefChapter *) addChapter: (NSInteger) chapterNo withStringVersion: (NSString *) chapterRef
{
    classRefChapter *chapterInstance;
    
    chapterInstance = [listOfChapters objectForKey:[[NSString alloc] initWithFormat:@"%ld", chapterNo]];
    if( chapterInstance == nil)
    {
        chapterInstance = [[classRefChapter alloc] init];
        [listOfChapters setObject:chapterInstance forKey:[[NSString alloc] initWithFormat:@"%ld", chapterNo]];
        [chapterInstance setChapterRef:chapterRef];
        chapterCount++;
    }
    return chapterInstance;
}

@end

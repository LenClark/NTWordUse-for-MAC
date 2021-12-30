/*=====================================================================================================*
 *                                                                                                     *
 *                                       NTWordUse: frmDisplay.m                                       *
 *                                       =======================                                       *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "frmDisplay.h"

@interface frmDisplay ()

@end

@implementation frmDisplay

@synthesize displayWindow;
@synthesize callingWindow;
@synthesize priorWindow;
@synthesize bookList;
@synthesize theChapter;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) displayChapter: (NSString *) chapterRef ofBook: (NSString *) bookName withHighlightedVerses: (NSArray *) arrayOfVerses
{
    bool isFound = false, isFirst = true;
    NSInteger idx, noOfVerses;
    NSString *candidateBookName, *keyVal, *expandedKey;
    NSMutableString *windowText;
    NSMutableAttributedString *chapterText, *currentLine;
    NSArray *keys;
    NSMutableArray *adjustedKeys;
    NSMutableDictionary *keyLookup;
    NSFontManager *fontMan;
    NSFont *normalFont, *boldFont;
    classBooks *currentBook;
    classChapter *currentChapter;
    classVerse *currentVerse;
    
    noOfVerses = [arrayOfVerses count];
    windowText = [[NSMutableString alloc] initWithFormat:@"%@ %@:",bookName, chapterRef];
    for( idx = 0; idx < noOfVerses; idx++)
    {
        if( idx == 0 ) [windowText appendString:[arrayOfVerses objectAtIndex:idx]];
        else [windowText appendFormat:@", %@", [arrayOfVerses objectAtIndex:idx]];
    }
    [displayWindow setTitle:[[NSString alloc] initWithString:windowText]];
    fontMan = [NSFontManager sharedFontManager];
    normalFont = [fontMan fontWithFamily:@"Times New Roman" traits:NSUnboldFontMask weight:5 size:16.0];
    boldFont = [fontMan fontWithFamily:@"Times New Roman" traits:NSFontBoldTrait weight:5 size:16.0];
    // Find the classBook instance for the book
    for( keyVal in bookList)
    {
        currentBook = [bookList valueForKey:keyVal];
        candidateBookName = [[NSString alloc] initWithString:[currentBook commonName]];
        if( [candidateBookName isEqualToString:bookName] )
        {
            isFound = true;
            break;
        }
    }
    if( isFound)
    {
        currentChapter = [[currentBook chapterList] valueForKey:chapterRef];
        chapterText = [[NSMutableAttributedString alloc] init];
        keys = [[NSArray alloc] initWithArray:[[currentChapter verseList] allKeys]];
        adjustedKeys = [[NSMutableArray alloc] init];
        keyLookup = [[NSMutableDictionary alloc] init];
        for( keyVal in keys)
        {
            [adjustedKeys addObject:[self extendKeys:keyVal]];
            [keyLookup setObject:keyVal forKey:[self extendKeys:keyVal]];
        }
        [adjustedKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
        keys = [[NSArray alloc] initWithArray:adjustedKeys];
        for( expandedKey in keys)
        {
            keyVal = [keyLookup objectForKey:expandedKey];
            currentVerse = [[currentChapter verseList] valueForKey:keyVal];
            currentLine = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@: ", keyVal]];
            [currentLine appendAttributedString:[[NSAttributedString alloc] initWithString:[currentVerse textOfVerse]]];
            if( isFirst) isFirst = false;
            else [chapterText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            if( [arrayOfVerses containsObject:keyVal] )
                [currentLine addAttribute:NSFontAttributeName value:boldFont range:(NSMakeRange(0, [currentLine length]))];
            else [currentLine addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [currentLine length]))];
            [chapterText appendAttributedString:currentLine];
        }
        [[theChapter textStorage] appendAttributedString:chapterText];
    }
}

- (NSString *) extendKeys: (NSString *) originalKeys
{
    NSInteger idx, stringLength;
    NSMutableString *prefix;
    
    stringLength = [originalKeys length];
    prefix = [[NSMutableString alloc] initWithString:@""];
    for( idx = 0; idx < 7 - stringLength; idx++) [prefix appendString:@"0"];
    return [[NSString alloc] initWithFormat:@"%@%@", prefix, originalKeys];
}

-(IBAction)doBackToBase:(id)sender
{
    [priorWindow close];
    [callingWindow close];
    [self close];
}

- (IBAction)doClose:(id)sender
{
    [self close];
}

@end

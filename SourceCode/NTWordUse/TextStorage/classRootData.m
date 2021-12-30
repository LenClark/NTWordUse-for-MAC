/*=====================================================================================================*
 *                                                                                                     *
 *                                      NTWordUse: classRootData.m                                     *
 *                                      ==========================                                     *
 *                                                                                                     *
 *  There is a possibility (albeit small) that the same word form can be used for two words of         *
 *    different grammatical category.  In order to manage this possibility, the Key for this Class is  *
 *    root + category code.  This is a bit cumbersome but all other options seemed to lead into        *
 *    extreme complexities.                                                                            *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classRootData.h"

@implementation classRootData

@synthesize isFoundInNT;
@synthesize catCode;
@synthesize rootWord;
@synthesize rootTransliteration;

/*=====================================================================================================*
 *                                                                                                     *
 *                                          parsedDetail                                               *
 *                                          ============                                               *
 *                                                                                                     *
 *  This is a bad name but I wasn't really sure what to call it.                                       *
 *  Most grammatical categories can have a variety of forms.  For example, a noun varies according to  *
 *  number and class.  Verbs are more complex.  The parsedDetail is a list of all such variants found  *
 *  in the source texts.                                                                               *
 *                                                                                                     *
 *  Key:   An integer value calculated from all elements of the grammatical variations                 *
 *  Value: An instance of classParsedItem                                                              *
 *                                                                                                     *
 *=====================================================================================================*/

@synthesize parsedDetail;
@synthesize processRawData;

- (id) init
{
    self = [super init];
    isFoundInNT = false;
    parsedDetail = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) addParsedText: (NSInteger) parseCode formOfWord: (NSString *) associatedWord bookNo: (NSInteger) bookNo chapNo: (NSInteger) chapNo verseNo: (NSInteger) verseNo
            chapterReference: (NSString *) givenChapRef verseRef: (NSString *) givenVerseRef isThisNT: (bool) isNT
{
    /*=====================================================================================*
     *                                                                                     *
     *                                   addParsedText                                     *
     *                                   =============                                     *
     *                                                                                     *
     *  This method effectively performs two functions:                                    *
     *                                                                                     *
     *   a) It identifies one of one or more parse structures for a root;                  *
     *   b) It provides  a reference (for reporting back).                                 *
     *                                                                                     *
     *  Parameters:                                                                        *
     *  ==========                                                                         *
     *                                                                                     *
     *  parseCode:                   Calculated in processRawData                          *
     *  associatedWord:              Effectively, the root noun, verb, etc.                *
     *  bookNo, chapNo, verseNo:     Calculated values, used to index data                 *
     *  givenChapRef, givenVerseRef: Values provided by the source data (only LXX)         *
     *  isNT:                        An obvious distinguishing flag                        *
     *                                                                                     *
     *=====================================================================================*/

    NSInteger newRefCode;
    classParsedItem *currentParse;

    currentParse = nil;
    if (isNT) isFoundInNT = true;
    currentParse = [parsedDetail objectForKey:[[NSString alloc] initWithFormat:@"%ld", parseCode]];
    if ( currentParse == nil )
    {
        currentParse = [[classParsedItem alloc] init];
        currentParse.parseCode = parseCode;
        [parsedDetail setValue:currentParse forKey:[[NSString alloc] initWithFormat:@"%ld", parseCode]];
    }
/*    else
    {
        currentParse = [parsedDetail objectForKey:[[NSString alloc] initWithFormat:@"%ld", parseCode]];
    } */
    if (isNT) currentParse.isInNt = true;
    else currentParse.isInLXX = true;
    newRefCode = [processRawData getReferenceCode:bookNo andChapter:chapNo andVerse:verseNo];
    [currentParse addReference:newRefCode bookNo:bookNo chapNo:chapNo verseNo:verseNo givenChapref:givenChapRef givenVerseRef:givenVerseRef isThisNT:isNT];
    [currentParse setWord:associatedWord];
}

- (NSDictionary *) getParseList
{
    return [parsedDetail copy];
}

@end

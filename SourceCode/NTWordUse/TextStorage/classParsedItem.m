/*=====================================================================================================*
 *                                                                                                     *
 *                                     NTWordUse: classParsedItem.m                                    *
 *                                     ============================                                    *
 *                                                                                                     *
 *  This categorisation is driven by the Parse Code provided in the source data.  A parseCode was      *
 *    generated in the processing of the "raw word" which gives a unique grammatical value to a word   *
 *    based on its parsing.  So, for example, the verb ζητέω used in the form ζητησάτωσαν is provided  *
 *    (in LXX) with the parse code AAD3P.  The variant Ζητησάτωσαν has the same parse code and,        *
 *    therefore, the same numeric value.  Each classParseCode instance represents a specific           *
 *    grammatical occurrence but can have multiple "parsedWords" because of variations in spelling,    *
 *    accents and the like.                                                                            *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classParsedItem.h"

@implementation classParsedItem

@synthesize isInNt;
@synthesize isInLXX;
@synthesize parseCode;
@synthesize parsedWords;
@synthesize processClass;

/*========================================================================================*
 *                                                                                        *
 *                                    referenceList                                       *
 *                                    =============                                       *
 *                                                                                        *
 *  We pick up specific form usage as we scan through the text.  That means that there is *
 *  a book-chapter-verse reference for each occurrence of each form of a word.  Since     *
 *  this instance represents a specific grammatical form of a word (say, the genitive     *
 *  plural of a noun or the 3rd person future indicative active of a verb), then there    *
 *  will be one or more references for that specific grammatical form.  The details will  *
 *  be held in the classReference instance.  The list, referenceList, contains a list of  *
 *  all those instances for the grammatical form.                                         *
 *                                                                                        *
 *  key:   An integer formed from the specific reference so that each different book-     *
 *         chapter-verse will give a different value.  This is purely to ensure a single  *
 *         reference displayed when the form occurs multiple times in a verse.            *
 *  value: The classReference instance address                                            *
 *                                                                                        *
 *========================================================================================*/
@synthesize referenceList;

NSInteger candidateWordCount;

- (id) init
{
    self = [super init];
    isInNt = false;
    isInLXX = false;
    parsedWords = [[NSMutableDictionary alloc] init];
    referenceList = [[NSMutableDictionary alloc] init];
    candidateWordCount = 0;
    return self;
}

- (void) setWord: (NSString *) candidateWord
{
    if (! [parsedWords doesContain:candidateWord])
    {
        [parsedWords setValue:[[NSString alloc] initWithFormat:@"%ld", candidateWordCount++] forKey:candidateWord];
    }
}

- (void) addReference: (NSInteger) refCode bookNo: (NSInteger) bookNo chapNo: (NSInteger) chapNo verseNo: (NSInteger) verseNo
            givenChapref: (NSString *) givenChapRef givenVerseRef: (NSString *) givenVerseRef isThisNT: (bool) isNT
{
    /*============================================================================================*
     *                                                                                            *
     *                                        addReference                                        *
     *                                        ============                                        *
     *                                                                                            *
     *  Parameters:                                                                               *
     *  ==========                                                                                *
     *                                                                                            *
     *  refCode         An integer value that uiquely identifies a book + chapter + verse.        *
     *                    Note that, for the LXX, our artificial chapter and verse sequence is    *
     *                    used and _not_ the actual (given) chapter and verse.                    *
     *  bookCode        The actual book code (starting from 1), where the LXX index follows on    *
     *                    from the last book in the NT                                            *
     *  chapNo          For NT, the chapter given in the source data; for LXX a unique sequence   *
     *  verseNo         For NT, the verse given in the source data; for LXX a unique sequence     *
     *  givenChapRef    Only relevant to LXX: the chapter as given in the source data (NT = "")   *
     *  givenVerseRef   Only relevant to LXX: the verse as given in the source data (NT = "")     *
     *  isNT            Boolean value: true, if the data comes from NT source; otherwise false    *
     *                                                                                            *
     *============================================================================================*/

    classReference *newReference;

    if (! [referenceList doesContain:[[NSString alloc] initWithFormat:@"%ld", refCode]])
    {
        newReference = [[classReference alloc] init];
        newReference.bookCode = bookNo;
        newReference.chapterNo = chapNo;
        newReference.verseNo = verseNo;
        if (!isNT)
        {
            newReference.givenChapterRef = givenChapRef;
            newReference.givenVerseRef = givenVerseRef;
            newReference.isNT = isNT;
        }
        [referenceList setValue:newReference forKey:[[NSString alloc] initWithFormat:@"%ld", refCode]];
    }
}

- (NSString *) getWords: (NSString *) rootWord
{
    NSMutableString *wordList;

    wordList = [[NSMutableString alloc] initWithString:@""];
    for (NSString *wordIdx in parsedWords)
    {
        if ([wordList length] == 0)
        {
            wordList = [[NSMutableString alloc] initWithString:[processClass cleanTextWord:wordIdx withInitialChatacter:[rootWord substringToIndex:1]]];
        }
        else
        {
            [wordList appendFormat: @", %@", [processClass cleanTextWord:wordIdx withInitialChatacter:[rootWord substringToIndex:1]]];
        }
    }
    return wordList;
}

@end

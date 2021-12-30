/*=====================================================================================================*
 *                                                                                                     *
 *                                     NTWordUse: frmReferences.m                                      *
 *                                     ==========================                                      *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "frmReferences.h"

@interface frmReferences ()

@end

@implementation frmReferences

@synthesize displayForm;
@synthesize callingForm;
@synthesize tabViewReferences;
@synthesize referenceWindow;
@synthesize refBooks;
@synthesize refChapters;
@synthesize refReferences;
@synthesize currentWord;
@synthesize referenceList;
@synthesize bookList;
@synthesize bookReferenceList;

NSString *const refBooksID = @"book";
NSString *const refChaptersID = @"chapter";
NSString *const refReferencesID = @"reference";

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) awakeFromNib
{
    [tabViewReferences setTarget:self];
    [tabViewReferences setDoubleAction:@selector(doubleClick:)];
}

- (void) populateTable
{
    bool isNT;
    NSInteger idx, bookCode = 0, chapterNo, verseNo, prevBookCode, rowCount;
    NSString *bookName, *givenChapterRef, *givenVerseRef, *referenceListKey, *prevChapRef, *keyVal, *keyVal2;
    NSMutableString *fullReference;
    NSDictionary *listOfChapters;
    NSMutableDictionary *colName, *colChap, *colAll, *revisedKeyDecode, *revisedChapDecode;
    NSArray *allSortedKeyValues, *allSortedChapValues;
    NSMutableArray *allKeyValues, *allChapValues;
    NSMutableAttributedString *attrBookName, *prevBookName, *attrChapter, *attrRef;
    NSFontManager *fontMan;
    NSFont *italicFont;
    classReference *referenceDetails;
    classBooks *currentBook;
    classRefBook *currentReferenceBook;
    classRefChapter *currentReferenceChapter;

    prevBookCode = -1;
    prevChapRef = @"?";
    rowCount = 0;
    refBooks = [[NSMutableArray alloc] init];
    refChapters = [[NSMutableArray alloc] init];
    refReferences = [[NSMutableArray alloc] init];
    fullReference = [[NSMutableString alloc] init];
    bookReferenceList = [[NSMutableDictionary alloc] init];
    colName = [[NSMutableDictionary alloc] init];
    colChap = [[NSMutableDictionary alloc] init];
    colAll = [[NSMutableDictionary alloc] init];
    fontMan = [NSFontManager sharedFontManager];
    italicFont = [fontMan fontWithFamily:@"Times New Roman" traits:NSFontItalicTrait weight:5 size:16.0];
    /*---------------------------------------------------------------------------------------*
     *                                                                                       *
     *  Step 1:                                                                              *
     *  ------                                                                               *
     *                                                                                       *
     *  Decode book name, chapter and verse and store results in three dictionaries, keyed   *
     *    on the row number.  As part of this process, the third dictionary will contain the *
     *    correctly formed reference.                                                        *
     *                                                                                       *
     *---------------------------------------------------------------------------------------*/
    for( referenceListKey in referenceList)
    {
        referenceDetails = [referenceList objectForKey:referenceListKey];
        isNT = [referenceDetails isNT];
        bookCode = [referenceDetails bookCode];
        chapterNo = [referenceDetails chapterNo];
        verseNo = [referenceDetails verseNo];
        givenChapterRef = [referenceDetails givenChapterRef];
        givenVerseRef = [referenceDetails givenVerseRef];
        if( isNT)
        {
            givenChapterRef = [[NSString alloc] initWithFormat:@"%ld", chapterNo];
            givenVerseRef = [[NSString alloc] initWithFormat:@"%ld", verseNo];
        }
        currentBook = [bookList objectForKey:[[NSString alloc] initWithFormat:@"%ld", bookCode]];
        bookName = [[NSString alloc] initWithString:[currentBook commonName]];
        currentReferenceBook = [bookReferenceList objectForKey:[[NSString alloc] initWithFormat:@"%ld", bookCode]];
        if( currentReferenceBook == nil)
        {
            currentReferenceBook = [[classRefBook alloc] init];
            [currentReferenceBook setBookName:bookName];
            [currentReferenceBook setBookRef:bookCode];
            [bookReferenceList setObject:currentReferenceBook forKey:[[NSString alloc] initWithFormat:@"%ld", bookCode]];
        }
        currentReferenceChapter = [currentReferenceBook addChapter:chapterNo withStringVersion:givenChapterRef];
        [currentReferenceChapter addReference:givenVerseRef];
    }
    rowCount = 0;
    allKeyValues = [[NSMutableArray alloc] init];
    revisedKeyDecode = [[NSMutableDictionary alloc] init];
    for( NSString *numberVal in [bookReferenceList allKeys])
    {
        keyVal = [[NSString alloc] initWithString:[self adjustNumbers:numberVal]];
        [allKeyValues addObject:keyVal];
        [revisedKeyDecode setValue:numberVal forKey:keyVal];
    }
    allSortedKeyValues = [[NSArray alloc] initWithArray:[allKeyValues sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    refBooks = [[NSMutableArray alloc] init];
    refChapters = [[NSMutableArray alloc] init];
    refReferences = [[NSMutableArray alloc] init];
    prevBookName = [[NSMutableAttributedString alloc] initWithString: @"?"];
    for( keyVal in allSortedKeyValues)
    {
        currentReferenceBook = [bookReferenceList objectForKey:[revisedKeyDecode objectForKey:keyVal]];
        bookCode = [currentReferenceBook bookRef];
        listOfChapters = [currentReferenceBook listOfChapters];
        allChapValues = [[NSMutableArray alloc] init];
        revisedChapDecode = [[NSMutableDictionary alloc] init];
        for( NSString *numberVal in [listOfChapters allKeys])
        {
            keyVal2 = [[NSString alloc] initWithString:[self adjustNumbers:numberVal]];
            [allChapValues addObject:keyVal2];
            [revisedChapDecode setValue:numberVal forKey:keyVal2];
        }
        allSortedChapValues = [[NSArray alloc] initWithArray:[allChapValues sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
        idx = 0;
        for( keyVal2 in allSortedChapValues)
        {
            currentReferenceChapter = [listOfChapters objectForKey:[revisedChapDecode objectForKey:keyVal2]];
            attrBookName = [[NSMutableAttributedString alloc] initWithString:[currentReferenceBook bookName]];
            if( ! [[attrBookName string] isEqualToString:[prevBookName string]]) idx = 0;
            if( bookCode > 27 )
                [attrBookName addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, [attrBookName length])];
            if( idx == 0) [refBooks addObject:[[NSMutableAttributedString alloc] initWithAttributedString:attrBookName]];
            else [refBooks addObject:[[NSMutableAttributedString alloc] initWithString:@""]];
            prevBookName = [[NSMutableAttributedString alloc] initWithAttributedString:attrBookName];
            idx++;
            attrChapter = [[NSMutableAttributedString alloc] initWithString:[currentReferenceChapter chapterRef]];
            if( bookCode > 27 ) [attrChapter addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, [attrChapter length])];
            [refChapters addObject:attrChapter];
            attrRef = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc]initWithFormat:@"%@ %@", [currentReferenceBook bookName], [self sortReference:[currentReferenceChapter fullReference]]]];
            if( bookCode > 27 ) [attrRef addAttribute:NSFontAttributeName value:italicFont range:NSMakeRange(0, [attrRef length])];
            [refReferences addObject:attrRef];
            rowCount++;
        }
    }
    [tabViewReferences reloadData];
}

- (NSString *) sortReference: (NSString *) unsortedRef
{
    bool isFirst = true;
    NSMutableString *workSpace, *item;
    NSArray *chapterAndVerses, *verses, *sortedVerses;
    
    chapterAndVerses = [unsortedRef componentsSeparatedByString:@":"];
    if( [chapterAndVerses count] < 2 ) return unsortedRef;
    verses = [[chapterAndVerses objectAtIndex:1] componentsSeparatedByString:@","];
    sortedVerses = [self sortVerses:verses];
    for( item in sortedVerses)
    {
        if( isFirst)
        {
            workSpace = [[NSMutableString alloc] initWithFormat:@"%@:%@", [chapterAndVerses objectAtIndex:0], item];
            isFirst = false;
        }
        else [workSpace appendFormat:@", %@", item];
    }
    return [[NSString alloc] initWithString:workSpace];
}

- (NSArray *) sortVerses: (NSArray *) unsortedVerses
{
    NSInteger verseLength, arrayCount;
    NSString *arrayValue, *cleanedValue, *adjustedValue;
    NSArray *sortedIntermediate;
    NSMutableArray *intermediateResults, *sortedResults;
    NSMutableDictionary *cleanedIntermediate;
    
    intermediateResults = [[NSMutableArray alloc] init];
    sortedResults = [[NSMutableArray alloc] init];
    cleanedIntermediate = [[NSMutableDictionary alloc] init];
    for( arrayValue in unsortedVerses)
    {
        cleanedValue = [[NSString alloc] initWithString:[arrayValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        verseLength = [cleanedValue length];
        switch (verseLength)
        {
            case 0: continue;
            case 1: adjustedValue = [[NSString alloc] initWithFormat:@"00%@", cleanedValue]; break;
            case 2: adjustedValue = [[NSString alloc] initWithFormat:@"0%@", cleanedValue]; break;
            case 3: adjustedValue = [[NSString alloc] initWithString:cleanedValue]; break;
            default: continue;
        }
        [intermediateResults addObject:adjustedValue];
        [cleanedIntermediate setValue:cleanedValue forKey:adjustedValue];
    }
    arrayCount = [intermediateResults count];
    if( arrayCount == 0 ) return unsortedVerses;
    sortedIntermediate = [[NSArray alloc] initWithArray:[intermediateResults sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    for( arrayValue in sortedIntermediate)
    {
        [sortedResults addObject:[cleanedIntermediate objectForKey:arrayValue]];
    }
    return [sortedResults copy];
}

- (NSString *) adjustNumbers: (NSString *) inNumbers
{
    NSInteger idx, stringLength;
    NSMutableString *resNum;
    
    resNum = [[NSMutableString alloc] initWithString:@""];
    stringLength = [inNumbers length];
    for( idx = 0; idx < 7 - stringLength; idx++)
    {
        [resNum appendString:@"0"];
    }
    return [[NSString alloc] initWithFormat:@"%@%@", resNum, inNumbers];
}

- (IBAction)doDisplay:(id)sender
{
    NSInteger rowNo;

    rowNo = [tabViewReferences selectedRow];
    [self performDisplay:tabViewReferences withSelectedRoww:rowNo];
}

- (void)doubleClick:(id)object
{
    NSInteger rowNo;
    NSTableView *sendingTable;
    
    sendingTable = (NSTableView *) object;
    rowNo = [sendingTable clickedRow];
    [self performDisplay:sendingTable withSelectedRoww:rowNo];
}

- (void) performDisplay: (NSTableView *) sendingTable withSelectedRoww: (NSInteger) rowNo
{
    NSInteger idx;
    NSString *displayedReference, *bookName, *chapterNo, *verseNos;
    NSArray *referenceSplit, *verses;
    
    displayedReference = [[NSString alloc] initWithString:[[refReferences objectAtIndex:rowNo] string]];
    // Get the book name from the full reference.
    bookName = [[NSString alloc] initWithString:[[refBooks objectAtIndex:rowNo] string]];
    idx = rowNo;
    while ([bookName isEqualToString:@""])
    {
        bookName = [[NSString alloc] initWithString:[[refBooks objectAtIndex:--idx] string]];
    }
    // In the same way, get the chapter number
    chapterNo = [[NSString alloc] initWithString:[[refChapters objectAtIndex:rowNo] string]];
    idx = rowNo;
    while ([chapterNo isEqualToString:@""])
    {
        chapterNo = [[NSString alloc] initWithString:[[refChapters objectAtIndex:--idx] string]];
    }
    // Now get a list of verses in the reference
    referenceSplit = [displayedReference componentsSeparatedByString:@":"];
    if( [referenceSplit count] < 2 ) return;
    verseNos = [[NSString alloc] initWithString:[[referenceSplit objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    verses = [verseNos componentsSeparatedByString:@","];
    // Now pass this information to the display form
    displayForm = [[frmDisplay alloc] initWithWindowNibName:@"frmDisplay"];
    [displayForm setBookList:bookList];
    [displayForm setCallingWindow:referenceWindow];
    [displayForm setPriorWindow:callingForm];
    [displayForm showWindow:self];
    [displayForm displayChapter:chapterNo ofBook:bookName withHighlightedVerses:verses];
}

- (IBAction)doSaveCSV:(id)sender
{
    NSUInteger idx, totalRows;
    NSSavePanel *savePanel;
    NSString *startingDirectory, *fileName;
    NSMutableString *outputData;
    NSArray *allowedFileTypes;
    NSURL *resultingLoc, *startingLoc;

    allowedFileTypes = [[NSArray alloc] initWithObjects:@"csv", @"txt", @"doc", nil];
    startingDirectory = [[NSString alloc] initWithString:[@"~" stringByExpandingTildeInPath]];
    startingLoc = [[NSURL alloc] initFileURLWithPath:startingDirectory];
    savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldStringValue:[[NSString alloc] initWithFormat:@"%@References.csv", currentWord]];
    [savePanel setAllowsOtherFileTypes:true];
    [savePanel setMessage:@"Select your location and file name, then click on \"Save\""];
    [savePanel setCanCreateDirectories:true];
    [savePanel setTitle:[[NSString alloc] initWithFormat:@"Save references for %@ in CSV format", currentWord]];
    [savePanel setDirectoryURL:startingLoc];
    NSInteger saveRes = [savePanel runModal];
    if( saveRes == NSModalResponseOK )
    {
        resultingLoc = [savePanel URL];
        fileName = [[NSString alloc] initWithString:[resultingLoc path]];
        totalRows = [refReferences count];
        outputData = [[NSMutableString alloc] init];
        for( idx = 0; idx < totalRows; idx++ )
        {
            if( idx > 0 ) [outputData appendString:@"\n"];
            [outputData appendFormat:@"%@\t%@\t%@", [[refBooks objectAtIndex:idx] string], [[refChapters objectAtIndex:idx] string], [[refReferences objectAtIndex:idx] string]];
        }
       [outputData writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (IBAction)doBackToBase:(id)sender
{
    [callingForm close];
    [self close];
}

- (IBAction)doClose:(id)sender
{
    [self close];
}

- (NSString *) returnedValue: (NSString *) keyName forRow: (NSUInteger) row
{
    if( [keyName isEqualToString: refBooksID] )
    {
        return [refBooks objectAtIndex: row];
    }
    else if ( [keyName isEqualToString: refChaptersID] )
    {
        return [refChapters objectAtIndex: row];
    }
    else if ( [keyName isEqualToString: refReferencesID] )
    {
        return [refReferences objectAtIndex: row];
    }
    else
    {
        return nil;
    }
}

#pragma mark - Table View Data Source

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.refChapters.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self returnedValue: tableColumn.identifier forRow: row];
}

@end

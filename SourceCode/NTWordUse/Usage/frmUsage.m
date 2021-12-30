/*=====================================================================================================*
 *                                                                                                     *
 *                                       NTWordUse: frmUsage.m                                         *
 *                                       =====================                                         *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "frmUsage.h"

@interface frmUsage ()

@end

@implementation frmUsage

@synthesize usageWindow;
@synthesize referenceForm;
@synthesize mainTabView;
@synthesize activeTab;
@synthesize middleTab;
@synthesize passiveTab;
@synthesize activeTabView;
@synthesize middleTabView;
@synthesize passiveTabView;
@synthesize btnSingular;
@synthesize btnPlural;

/*======================================================================*
 *  bookList **must** be set before calling displayTable                *
 *======================================================================*/
@synthesize bookList;
@synthesize activeTable;
@synthesize middleTable;
@synthesize passiveTable;
@synthesize actualColDesc1;
@synthesize actualColSing1;
@synthesize actualColPlur1;
@synthesize actualColDesc2;
@synthesize actualColSing2;
@synthesize actualColPlur2;
@synthesize actualColDesc3;
@synthesize actualColSing3;
@synthesize actualColPlur3;
@synthesize column1;
@synthesize pnlKey;
@synthesize isVerb;
@synthesize onlyDisplayNT;
@synthesize ntOnlyCode;
@synthesize lxxOnlyCode;
@synthesize ntAndLxxCode;
@synthesize tableContents;
@synthesize cellStatus;
@synthesize entryReferences;
@synthesize grammarName;

NSString *const Col1Id = @"description";
NSString *const Col2Id = @"singular";
NSString *const Col3Id = @"plural";

NSInteger totalRows, currentVoice;
NSString *categoryName, *wordItself;
NSMutableArray *reportParseSing;
NSMutableArray *reportParsePlur;
/*------------------------------------------------------------------------------------------------*
 *                                                                                                *
 *  Text is preprepared for display in a textview in the arrays.  These are all stored in         *
 *    arrayOfTableColumns.                                                                        *
 *                                                                                                *
 *  arrayOfTableColumns is an array of arrays; each array forming the array is an array of the    *
 *    text found in the rows of a specific column, as described below                             *
 *                                                                                                *
 *   table 0, column 0   arrayOfColumns[0]                                                        *
 *   table 0, column 1   arrayOfColumns[1]                                                        *
 *   table 0, column 2   arrayOfColumns[2]                                                        *
 *   table 1, column 0   arrayOfColumns[3]                                                        *
 *   table 1, column 1   arrayOfColumns[4]                                                        *
 *   table 1, column 2   arrayOfColumns[5]                                                        *
 *   table 2, column 0   arrayOfColumns[6]                                                        *
 *   table 2, column 1   arrayOfColumns[7]                                                        *
 *   table 2, column 2   arrayOfColumns[8]                                                        *
 *                                                                                                *
 *------------------------------------------------------------------------------------------------*/
NSMutableArray *arrayOfTableColumns;

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    onlyDisplayNT = true;
    currentVoice = 1;
    if( isVerb )
    {
        [activeTab setLabel:@"Active"];
        [middleTab setLabel:@"Middle"];
        [middleTabView setHidden:false];
        [passiveTab setLabel:@"Passive"];
        [passiveTabView setHidden:false];
    }
    else
    {
        [activeTab setLabel:grammarName];
        [middleTab setLabel:@"Not Used"];
        [middleTabView setHidden:true];
        [passiveTab setLabel:@"Not Used"];
        [passiveTabView setHidden:true];
    }
}

- (void) awakeFromNib
{
    [activeTable setTarget:self];
    [activeTable setDoubleAction:@selector(doubleClick:)];
    [middleTable setTarget:self];
    [middleTable setDoubleAction:@selector(doubleClick:)];
    [passiveTable setTarget:self];
    [passiveTable setDoubleAction:@selector(doubleClick:)];
}

- (void)doubleClick:(id)object
{
    NSInteger pageNo = 0, colNo, rowNo;
    NSTableView *sendingTable;
    
    sendingTable = (NSTableView *) object;
    if( sendingTable == activeTable) pageNo = 0;
    if( sendingTable == middleTable) pageNo = 1;
    if( sendingTable == passiveTable) pageNo = 2;
    colNo = [sendingTable clickedColumn];
    if( colNo == 0) return;
    rowNo = [sendingTable clickedRow];
    [self displayReferences:sendingTable forColumn:colNo andRow:rowNo andPageNo:pageNo];
}

- (IBAction)doSingularButtonClick:(id)sender
{
    NSInteger rowNo, pageNo = 0;
    NSTabViewItem *currentTabViewItem;
    NSTableView *sendingTable;

    currentTabViewItem = [mainTabView selectedTabViewItem];
    if( currentTabViewItem == activeTab )
    {
        sendingTable = activeTable;
        pageNo = 0;
    }
    if( currentTabViewItem == middleTab )
    {
        sendingTable = middleTable;
        pageNo = 1;
    }
    if( currentTabViewItem == passiveTab )
    {
        sendingTable = passiveTable;
        pageNo = 2;
    }
    rowNo = [sendingTable selectedRow];
    [self displayReferences:sendingTable forColumn:1 andRow:rowNo andPageNo:pageNo];
}

- (IBAction)doPluralButtonClick:(id)sender
{
    NSInteger rowNo, pageNo = 0;
    NSTabViewItem *currentTabViewItem;
    NSTableView *sendingTable;

    currentTabViewItem = [mainTabView selectedTabViewItem];
    if( currentTabViewItem == activeTab )
    {
        sendingTable = activeTable;
        pageNo = 0;
    }
    if( currentTabViewItem == middleTab )
    {
        sendingTable = middleTable;
        pageNo = 1;
    }
    if( currentTabViewItem == passiveTab )
    {
        sendingTable = passiveTable;
        pageNo = 2;
    }
    rowNo = [sendingTable selectedRow];
    [self displayReferences:sendingTable forColumn:2 andRow:rowNo andPageNo:pageNo];
}

- (void) displayReferences: (NSTableView *) sendingTable forColumn: (NSInteger) colNo andRow: (NSInteger) rowNo andPageNo: (NSInteger) pageNo
{
    NSInteger tabKey;
    NSString *dictionaryContent;
    NSDictionary *listOfReferences;
    
    tabKey = pageNo * 10000 + rowNo * 10 + colNo;
    dictionaryContent = [tableContents objectForKey:[[NSString alloc] initWithFormat:@"%ld", tabKey]];
    if( [dictionaryContent length] == 0) return;
    listOfReferences = [[NSDictionary alloc] initWithDictionary:[entryReferences objectForKey:[[NSString alloc] initWithFormat:@"%ld", tabKey]]];
    referenceForm = [[frmReferences alloc] initWithWindowNibName:@"frmReferences"];
    [referenceForm setCurrentWord:dictionaryContent];
    [referenceForm setReferenceList:listOfReferences];
    [referenceForm setBookList:bookList];
    [referenceForm populateTable];
    [referenceForm setCallingForm:usageWindow];
    [referenceForm showWindow:self];
}

- (void) initialiseForm: (NSDictionary *) books
{
    /*================================================================================*
     *                                                                                *
     *                           initialisation                                       *
     *                           ==============                                       *
     *                                                                                *
     *  Before the form is used, the following _must_ be initialised directly:        *
     *    isVerb;                                                                     *
     *    onlyDisplayNT;                                                              *
     *    ntOnlyCode;                                                                 *
     *    lxxOnlyCode;                                                                *
     *    ntAndLxxCode.                                                               *
     *                                                                                *
     *================================================================================*/
    
    if (onlyDisplayNT) [pnlKey setHidden:true];
    arrayOfTableColumns = [[NSMutableArray alloc] initWithCapacity:9];
    actualColDesc1 = [[NSMutableArray alloc] init];
    actualColSing1 = [[NSMutableArray alloc] init];
    actualColPlur1 = [[NSMutableArray alloc] init];
    actualColDesc2 = [[NSMutableArray alloc] init];
    actualColSing2 = [[NSMutableArray alloc] init];
    actualColPlur2 = [[NSMutableArray alloc] init];
    actualColDesc3 = [[NSMutableArray alloc] init];
    actualColSing3 = [[NSMutableArray alloc] init];
    actualColPlur3 = [[NSMutableArray alloc] init];
    bookList = [[NSDictionary alloc] initWithDictionary:books];
}

- (void) displayTable: (NSInteger) noOfRows
{

    /*==================================================================================================*
     *                                                                                                  *
     *                                       displayTable                                               *
     *                                       ============                                               *
     *                                                                                                  *
     *  Purpose:                                                                                        *
     *  =======                                                                                         *
     *                                                                                                  *
     *  A "generic" display of data provided by the main processing (by clicking on a specific word     *
     *    form.  (This is basically a reminder of information provided in AppDelegate.m.)               *
     *                                                                                                  *
     *  The table displayed has three dimensions (page 0 = voice, page 1 = rows and page 2 = person).   *
     *    As a consequence, the source data has three "dimensions" but, since Objective-C doesn't       *
     *    handle multiple dimensions well, we have devised a scheme where each element of information   *
     *    is stored as a Dictionary, keyed on a code.  This code is:                                    *
     *                                                                                                  *
     *      key mod 10 = column (0, 1 or 2)                                                             *
     *      (key / 10 ) mod 1000 = row number                                                           *
     *      key / 10000 = dimension 1 (page number)                                                     *
     *                                                                                                  *
     *  The three variables to which this structure applies are:                                        *
     *                                                                                                  *
     *      tableContents   The actual text to be displayed                                             *
     *      cellStatus      Whether the text is NT only, LXX only or both (see below)                   *
     *      entryReferences The address of a classReference instance specific to each cell              *
     *                                                                                                  *
     *  cellStatus:                                                                                     *
     *                                                                                                  *
     *    Each cell of the table is given a code.  The significance of this code is:                    *
     *                                                                                                  *
     *       0    There is no text                                                                      *
     *       1    The text only occurs in the New Testament                                             *
     *       2    The text only occurs in the Septugint (LXX)                                           *
     *       3    The text is found in both NT and LXX                                                  *
     *                                                                                                  *
     *  !!! Critical information !!!                                                                    *
     *  ============================                                                                    *
     *                                                                                                  *
     *  Before calling this method, the following variables _must_ be updated directly:                 *
     *       tableContents                                                                              *
     *       cellStatus                                                                                 *
     *       entryReferences                                                                            *
     *                                                                                                  *
     *==================================================================================================*/
    const NSInteger noOfCols = 3;
    NSInteger idx, jdx, kdx, limit, tabKey, statusCode;
    NSString *dictionaryContent;
    NSMutableArray *currentColumn;
    NSMutableAttributedString *stringForDisplay;
    NSFontManager *fontMan;
    NSFont *normalFont, *boldFont, *italicFont;

    fontMan = [NSFontManager sharedFontManager];
    normalFont = [fontMan fontWithFamily:@"Times New Roman" traits:NSUnboldFontMask weight:5 size:16.0];
    boldFont = [fontMan fontWithFamily:@"Times New Roman" traits:NSFontBoldTrait weight:5 size:16.0];
    italicFont = [fontMan fontWithFamily:@"Times New Roman" traits:NSFontItalicTrait weight:5 size:16.0];
    [arrayOfTableColumns removeAllObjects];
    for( idx = 0; idx < 9; idx++)
    {
        currentColumn = [[NSMutableArray alloc] init];
        [arrayOfTableColumns insertObject:currentColumn atIndex:idx];
    }
    totalRows = noOfRows;
    if( isVerb) limit = 3;
    else limit = 1;
    /*-----------------------------------------------------------------------------------------*
     *                                                                                         *
     *  We are going to tackle the display of information row-by-row.  This means that, for    *
     *  each row, we will then tackle each page in turn.  For each row and page, we will       *
     *  finally tackle the display for a specific column.                                      *
     *                                                                                         *
     *  Since data is stored column by column, we will need to keep refreshing an array for    *
     *  column we are currently displaying and then store it again.                            *
     *                                                                                         *
     *-----------------------------------------------------------------------------------------*/
        for( jdx = 0; jdx < noOfRows; jdx++)  // row
        {
            for( kdx = 0; kdx < limit; kdx++)  // page
            {
                for (idx = 0; idx < noOfCols; idx++)  // column
                {
                    currentColumn = [[NSMutableArray alloc] initWithArray:[arrayOfTableColumns objectAtIndex:kdx * 3 + idx]];
                    tabKey = kdx * 10000 + jdx * 10 + idx;
                    dictionaryContent = [tableContents objectForKey:[[NSString alloc] initWithFormat:@"%ld", tabKey]];
                    if( dictionaryContent == nil)
                    {
                        stringForDisplay = [[NSMutableAttributedString alloc] initWithString:@""];
                        [currentColumn addObject:stringForDisplay];
                        [arrayOfTableColumns removeObjectAtIndex:kdx * 3 + idx];
                        [arrayOfTableColumns insertObject:currentColumn atIndex:kdx * 3 + idx];
                        continue;
                    }
                    // There is some text for this cell
                    stringForDisplay = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%@", dictionaryContent]];
                    if( idx == 0) // column zero is description - so text and bold at all times
                    {
                        [stringForDisplay addAttribute:NSFontAttributeName value:boldFont range:(NSMakeRange(0, [stringForDisplay length]))];
                    }
                    else  // columns 1 and 2 are data and presentation depends on optional settings
                    {
                        statusCode = [[cellStatus objectForKey:[[NSString alloc] initWithFormat:@"%ld", tabKey]] integerValue];
                        if( ! onlyDisplayNT)
                        {
                            switch (statusCode)
                            {
                                case 1:
                                    switch (ntOnlyCode)
                                    {
                                        case 1: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1 green:0 blue:0 alpha:1]
                                                             range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                        case 2: [stringForDisplay addAttribute:NSFontAttributeName value:boldFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                        case 3: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1 green:0 blue:0 alpha:1]
                                                             range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:boldFont range:(NSMakeRange(0, [stringForDisplay length]))];
                                            break;
                                        default: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1 green:0 blue:0 alpha:1]
                                                              range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                    } break;
                                case 2:
                                    switch(lxxOnlyCode)
                                    {
                                        case 1: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1]
                                                             range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                        case 2: [stringForDisplay addAttribute:NSFontAttributeName value:italicFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                        case 3: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1]
                                                             range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:italicFont range:(NSMakeRange(0, [stringForDisplay length]))];
                                            break;
                                        default: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1]
                                                              range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                    } break;
                                case 3:
                                    switch (ntAndLxxCode)
                                    {
                                        case 1: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1 green:0.5 blue:0 alpha:1]
                                                             range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                        case 2: [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                        default: [stringForDisplay addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1 green:0.5 blue:0 alpha:1]
                                                              range:(NSMakeRange(0, [stringForDisplay length]))];
                                            [stringForDisplay addAttribute:NSFontAttributeName value:normalFont range:(NSMakeRange(0, [stringForDisplay length]))]; break;
                                    } break;
                            } // end of switch
                        }  // end of if - no else because the alternative is normal text, already stored
                    }  // end of if(idx == 0) else - i.e. we have finished with that column for the time being
                    [currentColumn addObject:stringForDisplay];
                    [arrayOfTableColumns removeObjectAtIndex:kdx * 3 + idx];
                    [arrayOfTableColumns insertObject:currentColumn atIndex:kdx * 3 + idx];
                } // end of for( idx
            } // end of kdx
        } // end of jdx
    actualColDesc1 = [arrayOfTableColumns objectAtIndex:0];
    actualColSing1 = [arrayOfTableColumns objectAtIndex:1];
    actualColPlur1 = [arrayOfTableColumns objectAtIndex:2];
    [activeTable reloadData];
    if( isVerb)
    {
        actualColDesc2 = [arrayOfTableColumns objectAtIndex:3];
        actualColSing2 = [arrayOfTableColumns objectAtIndex:4];
        actualColPlur2 = [arrayOfTableColumns objectAtIndex:5];
        [middleTable reloadData];
        actualColDesc3 = [arrayOfTableColumns objectAtIndex:6];
        actualColSing3 = [arrayOfTableColumns objectAtIndex:7];
        actualColPlur3 = [arrayOfTableColumns objectAtIndex:8];
        [passiveTable reloadData];
    }
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSTabView *currentTabView;
    
    currentTabView = tabView;
}

- (void) setWordItself: (NSString *) wordChosen
{
    wordItself = wordChosen;
    [usageWindow setTitle:[[NSString alloc] initWithFormat: @"New Testament Usage: %@", wordChosen]];
}

- (IBAction)doSaveCSV:(id)sender
{
    NSUInteger idx;
    NSSavePanel *savePanel;
    NSString *startingDirectory, *fileName;
    NSMutableString *outputData;
    NSArray *allowedFileTypes;
    NSURL *resultingLoc, *startingLoc;

    allowedFileTypes = [[NSArray alloc] initWithObjects:@"csv", @"txt", @"doc", nil];
    startingDirectory = [[NSString alloc] initWithString:[@"~" stringByExpandingTildeInPath]];
    startingLoc = [[NSURL alloc] initFileURLWithPath:startingDirectory];
    savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldStringValue:@"UsageData.csv"];
    [savePanel setAllowsOtherFileTypes:true];
    [savePanel setMessage:@"Select your location and file name, then click on \"Save\""];
    [savePanel setCanCreateDirectories:true];
    [savePanel setTitle:[[NSString alloc] initWithFormat:@"Save usage data for %@ in CSV format", wordItself]];
    [savePanel setDirectoryURL:startingLoc];
    NSInteger saveRes = [savePanel runModal];
    if( saveRes == NSModalResponseOK )
    {
        resultingLoc = [savePanel URL];
        fileName = [[NSString alloc] initWithString:[resultingLoc path]];
        if( isVerb )
        {
            outputData = [[NSMutableString alloc] initWithString:@"Active paradigm\t\t"];
            for( idx = 0; idx < totalRows; idx++ )
            {
                [outputData appendFormat:@"\n%@\t%@\t%@", [[actualColDesc1 objectAtIndex:idx] string], [[actualColSing1 objectAtIndex:idx] string], [[actualColPlur1 objectAtIndex:idx] string]];
            }
            [outputData appendString:@"\n\nMiddle paradigm\t\t"];
            for( idx = 0; idx < totalRows; idx++ )
            {
                [outputData appendFormat:@"\n%@\t%@\t%@", [[actualColDesc2 objectAtIndex:idx] string], [[actualColSing2 objectAtIndex:idx] string], [[actualColPlur2 objectAtIndex:idx] string]];
            }
            [outputData appendString:@"\n\nPassive paradigm\t\t"];
            for( idx = 0; idx < totalRows; idx++ )
            {
                [outputData appendFormat:@"\n%@\t%@\t%@", [[actualColDesc3 objectAtIndex:idx] string], [[actualColSing3 objectAtIndex:idx] string], [[actualColPlur3 objectAtIndex:idx] string]];
            }
        }
        else
        {
            outputData = [[NSMutableString alloc] initWithFormat:@"%@\t\t", grammarName];
            for( idx = 0; idx < totalRows; idx++ )
            {
                [outputData appendFormat:@"\n%@\t%@\t%@", [[actualColDesc1 objectAtIndex:idx] string], [[actualColSing1 objectAtIndex:idx] string], [[actualColPlur1 objectAtIndex:idx] string]];
            }
        }
       [outputData writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (IBAction)doClose:(id)sender
{
    [usageWindow close];
}

- (NSString *) returnedValue: (NSString *) keyName forRow: (NSUInteger) row andTableId: (NSInteger) tableId
{
    switch (tableId)
    {
        case 0:
            if( [keyName isEqualToString: Col1Id] )
            {
                return [actualColDesc1 objectAtIndex: row];
            }
            else if( [keyName isEqualToString: Col2Id] )
            {
                return [actualColSing1 objectAtIndex: row];
            }
            else if( [keyName isEqualToString: Col3Id] )
            {
                return [actualColPlur1 objectAtIndex: row];
            }
            break;
        case 1:
            if( [keyName isEqualToString: Col1Id] )
            {
                return [actualColDesc2 objectAtIndex: row];
            }
            else if( [keyName isEqualToString: Col2Id] )
            {
                return [actualColSing2 objectAtIndex: row];
            }
            else if( [keyName isEqualToString: Col3Id] )
            {
                return [actualColPlur2 objectAtIndex: row];
            }
            break;
       case 2:
            if( [keyName isEqualToString: Col1Id] )
            {
                return [actualColDesc3 objectAtIndex: row];
            }
            else if( [keyName isEqualToString: Col2Id] )
            {
                return [actualColSing3 objectAtIndex: row];
            }
            else if( [keyName isEqualToString: Col3Id] )
            {
                return [actualColPlur3 objectAtIndex: row];
            }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - Table View Data Source

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.actualColDesc1.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger tagVal;
    
    tagVal = [tableView tag];
    return [self returnedValue: tableColumn.identifier forRow: row andTableId:tagVal];
}
/*
- (IBAction)doClose:(id)sender
{
    [usageWindow close];
}
*/
@end

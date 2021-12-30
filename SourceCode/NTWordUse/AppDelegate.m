/*=====================================================================================================*
 *                                                                                                     *
 *                                       NTWordUse: AppDelegate.m                                      *
 *                                       ========================                                      *
 *                                                                                                     *
 *  The purpose of the program is to display all words used in the New Testament, broken down by       *
 *    grammatical structure (e.g. Nouns by case, verbs by standard paradigms).                         *
 *                                                                                                     *
 *  Note: I have used the term "grammatical category" (sometimes just "Category") to cover the various *
 *        different aspects of grammar, such as noun, verb, adjective and so on.                       *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

/*=====================================================================================================*
 *                                                                                                     *
 *                                     integer variables                                               *
 *                                     =================                                               *
 *                                                                                                     *
 *  categoryCode    The program is to display all words used in the New Testament, broken down by      *
 *  noOfNTBooks     The number of books identified by the NT Titles file.  This will also be used to   *
 *                  separate the NT books from the LXX books (which have an index following on from    *
 *                  the NT books                                                                       *
 *  noOfLxxBooks    The actual number of LXX books identified in the LXX title file. (1 to 59)         *
 *  noOfStoredBooks In fact, noOfNTBooks + noOfLxxBooks, used as the extent of the stored books        *
 *  nRootCount      The number of root entries                                                         *
 *  nNoOfNtRoots    The highest count for NT entries.  Values greater are from LXX uniquely.           *
 *                                                                                                     *
 *=====================================================================================================*/

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize mainWindow;
@synthesize generalUsage;
@synthesize optionsForm;
@synthesize aboutForm;
@synthesize helpForm;

/*==================================================================================*
 *                                                                                  *
 *  The different (group) boxes containing radio buttons, check boxes or buttons    *
 *    that are generated programmatically.  They are IBOutlets so that the nib can  *
 *    be referenced.                                                                *
 *                                                                                  *
 *==================================================================================*/
@synthesize gbCategory;
@synthesize gbTenses;
@synthesize gbMoods;
@synthesize gbKeyboard;
@synthesize pleaseBePatient;
@synthesize mainView;
@synthesize tenseChecks;
@synthesize moodChecks;
@synthesize selectTenses;
@synthesize selectMoods;
@synthesize selectParticiples;
@synthesize selectNonParticiples;
@synthesize optionsButton;

/*==================================================================================*
 *                                                                                  *
 *  The label near the bottom of the main form that records what has currenty been  *
 *    entered using the virtual keyboard.  Once again, it is an IBOutlet so that    *
 *    the nib can be referenced.                                                    *
 *                                                                                  *
 *==================================================================================*/
@synthesize selectionCriteriaLabel;

/*==================================================================================*
 *                                                                                  *
 *  tabViewWordList: the "listbox" that will form the base for user selection:      *
 *  wordListContents: the mutable array that will hold table view data              *
 *                                                                                  *
 *==================================================================================*/
@synthesize tabViewWordList;
@synthesize wordListContents;
@synthesize originalWordList;

@synthesize progressBar;
@synthesize mainLoop;
@synthesize progressInfo;

bool onlyDisplayNT;
NSInteger ntOnlyCode, lxxOnlyCode, ntAndLxxCode;
NSInteger categoryCode = 0, noOfNTBooks = 0, noOfLxxBooks = 0, noOfStoredBooks = 0, nRootCount = 0, noOfNtRoots = 0, ntRawCount = 0, lxxRawCount = 0, noOfCategories, buttonIndex;
NSString *fileBase = @"..\\Source\\", *titlesFile = @"Titles.txt", *lxxTitlesFile = @"LXX_Titles.txt", *ntTextFile = @"NTText.txt", *lxxTextFolder = @"LXX_Text";
NSString *keyEntryWorkspace = @"";
NSMutableString *keyEntryworkspace;
NSArray *categoryCodes, *fullCategoryNames, *tenseNames, *moodNames, *genderNames, *caseNames, *adjectiveNames;

/*=====================================================================================================*
 *                                                                                                     *
 *                                        initialisation variables                                     *
 *                                        ========================                                     *
 *                                                                                                     *
 *  Variables controlling the storage and retrieval of values from one session to another              *
 *                                                                                                     *
 *=====================================================================================================*/

NSString *basePath, *lfcFolder, *appFolder, *initFileName, *initPath;

/*=====================================================================================================*
 *                                                                                                     *
 *                                            bookNames                                                *
 *                                            =========                                                *
 *                                                                                                     *
 *  This list stores information that allows us to access the data for NT books.  Each book is         *
 *  referenced by a code supplied in the titles file.  The list allows us to covert this into a        *
 *  meaningful book name.                                                                              *
 *                                                                                                     *
 *  Key:   A simple sequence number (1 upwards)                                                        *
 *  Value: An instance of classBook                                                                    *
 *                                                                                                     *
 *=====================================================================================================*/
NSMutableDictionary *bookNames;

/*=====================================================================================================*
 *                                                                                                     *
 *                                          rootDataStore                                              *
 *                                          =============                                              *
 *                                                                                                     *
 *  This list enables us to access the base root data, as required.  It holds data for both NT and     *
 *  LXX texts, so where root words are found in the NT, isInNT = true.  If isInNT = false, then the    *
 *  root is found only in the LXX.  (Note, where isInNT = true, the word may be found in the LXX, as   *
 *  well as in the NT).                                                                                *
 *                                                                                                     *
 *  Key:   A simple sequence number (1 upwards)                                                        *
 *  Value: An instance of classRootData                                                                *
 *                                                                                                     *
 *=====================================================================================================*/
NSMutableDictionary *rootDataStore;

/*=====================================================================================================*
 *                                                                                                     *
 *                                          rootLookup                                                 *
 *                                          ==========                                                 *
 *                                                                                                     *
 *  This is effectively the inverse of rootDataStore.                                                  *
 *                                                                                                     *
 *  Given the root form (e.g. λογος), how do we find the key to rootDataStore.  This lookup list       *
 *  us to do so.                                                                                       *
 *                                                                                                     *
 *  Note: the combined root form plus category code is used to create a unique key                     *
 *                                                                                                     *
 *  Key:   The lookup key (category code + root form)                                                  *
 *  Value: The integer key to classRootData                                                            *
 *                                                                                                     *
 *=====================================================================================================*/
NSMutableDictionary *rootLookup;

/*=====================================================================================================*
 *                                                                                                     *
 *                                          gkFlattener                                                *
 *                                          ===========                                                *
 *                                                                                                     *
 *  This allows us to adjust words to remove extraneous characters (e.g. accents).                     *
 *                                                                                                     *
 *  Key:   Unicode character                                                                           *
 *  Value: Replacement Unicode character                                                               *
 *                                                                                                     *
 *=====================================================================================================*/
NSMutableDictionary *gkFlattener;

/*=====================================================================================================*
 *                                                                                                     *
 *                                        Global Classes                                               *
 *                                        ==============                                               *
 *                                                                                                     *
 *=====================================================================================================*/

classProcesses *processesForData;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    BOOL isDir;
    NSString *initContents, *initKey;
    NSArray *fileLines, *lineContent;
    NSFileManager *fmInit;

    /*----------------------------------*
     *   Initialisation                 *
     *----------------------------------*/
    tenseNames = [[NSArray alloc] initWithObjects: @"Present", @"Imperfect", @"Aorist", @"Perfect", @"Pluperfect", @"Future", nil];
    moodNames = [[NSArray alloc] initWithObjects: @"Indicative", @"Imperative", @"Subjunctive", @"Optative", @"Infinitive", nil];
    categoryCodes = [[NSArray alloc] initWithObjects: @"N-", @"V-", @"A-", @"D-", @"P-", @"RA", @"RD", @"RI", @"RP", @"RR", @"X-", @"C-", @"I-", nil ];
    fullCategoryNames = [[NSArray alloc] initWithObjects: @"Noun", @"Verb", @"Adjective", @"Adverb", @"Preposition", @"Article", @"Demonstrative Pronoun", @"Indefinite Pronoun",
                         @"Personal Pronoun", @"Relative Pronoun", @"Particle", @"Conjunction", @"Interjection" , nil];
    caseNames = [[NSArray alloc] initWithObjects: @"Nominative", @"Vocative", @"Accusative", @"Genitive", @"Dative", nil];
    genderNames = [[NSArray alloc] initWithObjects: @"Masculine", @"Neuter", @"Feminine", nil];
    adjectiveNames = [[NSArray alloc] initWithObjects:@"Adjective", @"Comparative", @"Superlative", nil];
    noOfCategories = [categoryCodes count];
    bookNames = [[NSMutableDictionary alloc] init];
    rootDataStore = [[NSMutableDictionary alloc] init];
    rootLookup = [[NSMutableDictionary alloc] init];
    gkFlattener = [[NSMutableDictionary alloc] init];
    processesForData = [[classProcesses alloc] init];
    wordListContents = [[NSMutableArray alloc] init];
    mainLoop = [NSRunLoop mainRunLoop];
    keyEntryworkspace = [[NSMutableString alloc] initWithString:@""];
    tenseChecks = [[NSMutableArray alloc] init];
    moodChecks = [[NSMutableArray alloc] init];
    basePath = @"/Library/";
    lfcFolder = @"LFCConsulting";
    appFolder = @"WordUse";
    /*-----------------------------------------------------------------------------*
     *                                                                             *
     *           Variables that control the Word Use display Display               *
     *           ---------------------------------------------------               *
     *                                                                             *
     *  onlyDisplayNT    true: there will be no reference to LXX data              *
     *                   false (default): LXX data is not in the selection list    *
     *                         but examples of use in the LXX will be given        *
     *  ntOnlyCode       Controls how Word Use forms that are only found in the NT *
     *                     will be displayed:                                      *
     *                      1     Display the word in Red                          *
     *                      2     Display the word in Bold (black)                 *
     *                      3     Display the word in Bold Red                     *
     *  lxxOnlyCode      Controls how Word Use forms that are only found in the    *
     *                     LXX will be displayed:                                  *
     *                      1     Display the word in Grey                         *
     *                      2     Display the word in Italics (black)              *
     *                      3     Display the word in Grey Italics                 *
     *  ntOnlyCode       Controls how Word Use forms that are found in both        *
     *                     the NT and LXX will be displayed:                       *
     *                      1     Display the word in Orange                       *
     *                      2     Display the word in Normal font (black)          *
     *                                                                             *
     *-----------------------------------------------------------------------------*/
    onlyDisplayNT = false;
    ntOnlyCode = 1;
    lxxOnlyCode = 1;
    ntAndLxxCode = 1;

    /*-----------------------------------------------------------------------------------------------------*
     *                                                                                                     *
     *  Main source/storage locations                                                                      *
     *  -----------------------------                                                                      *
     *                                                                                                     *
     *  Initialisation data (retained from session to session) will be stored in: "~/LFCConsulting/GBS.    *
     *                                                                                                     *
     *-----------------------------------------------------------------------------------------------------*/

    isDir = true;
    fmInit = [NSFileManager defaultManager];
    initPath = [[NSString alloc] initWithFormat:@"%@%@%@/%@", [fmInit homeDirectoryForCurrentUser], basePath, lfcFolder, appFolder];
    if( [initPath containsString:@"file:///"] ) initPath = [[NSString alloc] initWithString:[initPath substringFromIndex:7]];
    initFileName = [[NSString alloc] initWithFormat:@"%@/init.dat", initPath];
    if( [fmInit fileExistsAtPath:initPath isDirectory:&isDir])
    {
        initContents = [[NSString alloc] initWithContentsOfFile:initFileName encoding:NSUTF8StringEncoding error:nil];
        fileLines = [initContents componentsSeparatedByString:@"\n"];
        for (NSString *actualLine in fileLines)
        {
            if(( actualLine == nil ) || ( [actualLine length] == 0 ) ) continue;
            lineContent = [actualLine componentsSeparatedByString:@"="];
            initKey = [[NSString alloc] initWithString:[lineContent objectAtIndex:0]];
            if( [initKey compare:@"Include LXX"] == NSOrderedSame )
            {
                if( [[lineContent objectAtIndex:1] compare:@"0"] == NSOrderedSame ) onlyDisplayNT = true;
                else onlyDisplayNT = false;
            }
            if( [initKey compare:@"Code for only NT"] == NSOrderedSame ) ntOnlyCode = [[lineContent objectAtIndex:1] integerValue];
            if( [initKey compare:@"Code for only LXX"] == NSOrderedSame ) lxxOnlyCode = [[lineContent objectAtIndex:1] integerValue];
            if( [initKey compare:@"Code for both"] == NSOrderedSame ) ntAndLxxCode = [[lineContent objectAtIndex:1] integerValue];
        }
    }
    else
    {
        [fmInit createDirectoryAtPath:initPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self createPrincipleRadioButtons];
    [self createTenseCheckboxes];
    [self createMoodCheckboxes];
    [self createVirtualKeyboard];
    [self populateGkFlattener];
    [self loadNTTitles];
    [self loadNTText];
    [self loadLXXTitles];
    [self loadLXXText];
    [self populateListbox];
    [progressInfo setStringValue:@"Initialisation complete"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    [pleaseBePatient setHidden:true];
    [mainView setHidden:false];
    [tabViewWordList setTarget:self];
    [tabViewWordList setDoubleAction:@selector(doDoubleClick:)];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void) saveStoredData
{
    BOOL isDir;
    NSMutableString *initContents;
    NSFileManager *fmInit;

    onlyDisplayNT = [optionsForm onlyDisplayNT];
    ntOnlyCode = [optionsForm ntOnlyCode];
    lxxOnlyCode = [optionsForm lxxOnlyCode];
    ntAndLxxCode = [optionsForm ntAndLxxCode];
    fmInit = [NSFileManager defaultManager];
    isDir = false;
    if( [fmInit fileExistsAtPath:initFileName isDirectory:&isDir]) [fmInit removeItemAtPath:initFileName error:nil];
    initContents = [[NSMutableString alloc] initWithString:@""];
    if( onlyDisplayNT) [initContents appendFormat:@"Include LXX=%d\n", 0];
    else [initContents appendFormat:@"Include LXX=%d\n", 1];
    [initContents appendFormat:@"Code for only NT=%ld\n", ntOnlyCode];
    [initContents appendFormat:@"Code for only LXX=%ld\n", lxxOnlyCode];
    [initContents appendFormat:@"Code for both=%ld\n", ntAndLxxCode];
    [initContents writeToFile:initFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void) createPrincipleRadioButtons
{
    /*=====================================================================================================*
     *                                                                                                     *
     *                                     createPrincipleRadioButtons                                     *
     *                                     ===========================                                     *
     *                                                                                                     *
     *  Dynamic creation of the radio buttons enabling selection of the grammatical type to be selected    *
     *  (e.g. nouns, verbs, etc.)                                                                          *
     *                                                                                                     *
     *=====================================================================================================*/

    NSUInteger idx, top = -14, left = 4, rbtnWidth = 150, rbtnHeight = 18, gap = 4, gbHeight, actualHeight;
    NSButton *currentRadioButton;
    
    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Populating the category radio buttons"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    gbHeight = 346;
    for( idx = 0; idx < noOfCategories; idx++)
    {
        actualHeight = gbHeight - (top + ( rbtnHeight + gap ) * idx);
        currentRadioButton = [[NSButton alloc] initWithFrame:NSMakeRect(left, actualHeight - rbtnHeight * 2, rbtnWidth, rbtnHeight)];
        [currentRadioButton setTitle:[fullCategoryNames objectAtIndex:idx]];
        [currentRadioButton setFont:[NSFont fontWithName:@"Times New Roman" size:16]];
        [currentRadioButton setTarget:self];
        [currentRadioButton setTag:idx];
        [currentRadioButton setButtonType:NSButtonTypeRadio];
        if( idx == 0 ) [currentRadioButton setState: NSControlStateValueOn];
        [currentRadioButton setAction:@selector(handleRadioButton:)];
        [[gbCategory contentView] addSubview:currentRadioButton];
    }
}

- (void) createTenseCheckboxes
{
    /*=====================================================================================================*
     *                                                                                                     *
     *                                     createTenseCheckboxes                                           *
     *                                     =====================                                           *
     *                                                                                                     *
     *  Dynamic creation of the check boxes for Tenses. (There are specific to Verbs.)                     *
     *                                                                                                     *
     *=====================================================================================================*/
    
    NSUInteger idx, chkTTop = 50, chkGap = 4, chkTLeft = 20, chkWidth = 120, chkHeight = 18, gbHeight, actualHeight, itemCount;
    NSMutableArray *tempChkTenses = [[NSMutableArray alloc] init];
    NSButton *currentChkButton;
    
    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Adding the tense check boxes"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    gbHeight = [gbTenses frame].size.height;
    itemCount = [tenseNames count];
    for( idx = 0; idx < itemCount; idx++ )
    {
        actualHeight = gbHeight - ( chkTTop + ( chkHeight + chkGap ) * idx );
        currentChkButton = [[NSButton alloc] initWithFrame:NSMakeRect(chkTLeft, actualHeight, chkWidth, chkHeight)];
        [currentChkButton setButtonType:NSButtonTypeSwitch];
        [currentChkButton setTitle:[tenseNames objectAtIndex:idx]];
        [currentChkButton setTag:idx];
        [currentChkButton setFont:[NSFont fontWithName:@"Times New Roman" size:16]];
        [currentChkButton setTarget:self];
        [currentChkButton setAction:@selector(handleTenseCheckButton:)];
        [[gbTenses contentView] addSubview:currentChkButton];
        [tempChkTenses addObject:currentChkButton];
    }
    [tenseChecks addObjectsFromArray:tempChkTenses];
}

- (void) createMoodCheckboxes
{
    /*=====================================================================================================*
     *                                                                                                     *
     *                                     createTenseCheckboxes                                           *
     *                                     =====================                                           *
     *                                                                                                     *
     *  Dynamic creation of the check boxes for Moods. (There are specific to Verbs.)                      *
     *                                                                                                     *
     *=====================================================================================================*/
    
    NSUInteger idx, chkMTop = 50, chkMLeft = 20, chkGap = 4, chkWidth = 120, chkHeight = 18, gbHeight, actualHeight, itemCount;
    NSMutableArray *tempChkMoods = [[NSMutableArray alloc] init];
    NSButton *currentChkButton;

    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Adding the mood check boxes"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    gbHeight = [gbMoods frame].size.height;
    itemCount = [moodNames count];
    for( idx = 0; idx < itemCount; idx++ )
    {
        actualHeight = gbHeight - ( chkMTop + ( chkHeight + chkGap ) * idx );
        currentChkButton = [[NSButton alloc] initWithFrame:NSMakeRect(chkMLeft, actualHeight - chkHeight * 2, chkWidth, chkHeight)];
        [currentChkButton setButtonType:NSButtonTypeSwitch];
        [currentChkButton setTitle:[moodNames objectAtIndex:idx]];
        [currentChkButton setTag:idx];
        [currentChkButton setFont:[NSFont fontWithName:@"Times New Roman" size:16]];
        [currentChkButton setTarget:self];
        [currentChkButton setAction:@selector(handleMoodCheckButton:)];
        [[gbMoods contentView] addSubview:currentChkButton];
        [tempChkMoods addObject:currentChkButton];
    }
    [moodChecks addObjectsFromArray:tempChkMoods];
}
    
- (void) createVirtualKeyboard
{
    /*--------------------------------------------------------------------*
     *   Pseudo-Keyboard setup                                            *
     *--------------------------------------------------------------------*/
    NSUInteger idx, noOfKeys, keyHeight = 26, keyWidth = 26, keyBigWidth = 30, keyTop = 18, keyLeft = 4, keyGap = 4, keyRows, keyCols, actualHeight, gbHeight;
    NSButton *currentButton;
    NSArray *keyFaces = @[ @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι", @"BkSp",
                           @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"π", @"ρ", @"σ", @"Clear", @"ς", @"τ", @"υ", @"φ", @"χ", @"ψ", @"ω"];
    NSArray *gkKeyHints = @[ @"alpha", @"beta", @"gamma", @"delta", @"epsilon", @"zeta", @"eta", @"theta", @"iota", @"Backspace",
                             @"kappa", @"lambda", @"mu", @"nu", @"xi", @"omicron", @"pi", @"rho", @"sigma", @"Clear",
                             @"final sigma", @"tau", @"upsilon", @"phi", @"chi", @"psi", @"omega"];
    //    Font buttonFont = new Font("Times New Roman", 12, FontStyle.Regular);
    //    ToolTip[,] keyToolTips = new ToolTip[keyRows, keyCols];
    
    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Creating the virtual keyboard"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    noOfKeys = [keyFaces count];
    keyRows = 0;
    keyCols = 0;
    gbHeight = 176;
    for( idx = 0; idx < noOfKeys; idx++ )
    {
        switch (idx)
        {
            case 10:
            case 20:
                keyRows++;
                keyCols = 0;
                keyBigWidth = keyWidth;
                break;
            case 9:
            case 19:
                keyBigWidth = 56;
                break;
            default:
                keyBigWidth = keyWidth;
                break;
        }
        actualHeight = gbHeight - ( keyTop + (keyHeight + keyGap ) * ( keyRows + 1 ) );
        currentButton = [[NSButton alloc] initWithFrame:NSMakeRect(keyLeft + keyCols * (keyWidth + keyGap ), actualHeight - keyRows * (keyGap), keyBigWidth, keyHeight)];
        [currentButton setTag:idx];
        [currentButton setTitle:keyFaces[idx]];
        [currentButton setFont:[NSFont fontWithName:@"Times New Roman" size:16]];
        [currentButton setToolTip:gkKeyHints[idx]];
        [currentButton setAction:@selector(keyButton_Click:)];
        [[gbKeyboard contentView] addSubview:currentButton];
        keyCols++;
    }
}

- (void) handleRadioButton: (id) sender
{
    /*================================================================================*
     *                                                                                *
     *                              handleRadioButton                                 *
     *                              =================                                 *
     *                                                                                *
     *  Purpose:                                                                      *
     *  =======                                                                       *
     *                                                                                *
     *  To handle the selection of specific grammatical categories (e.g. noun, verb). *
     *  There are basically three sub-groups of category:                             *
     *                                                                                *
     *  nouns, adjectives, pronouns: These will have a single table with 5 cases and  *
     *                               singular and plural columns;                     *
     *  verbs: three tables (one for each mood) and multiple rows for different       *
     *         tenses as well as 1st, 2nd and 3rd person                              *
     *  other categories: which have a single entry (n.b. we don't distinguish        *
     *                    between prepositions used in different cases)               *
     *                                                                                *
     *  Note that the selection of verbs will require a change of size of the main    *
     *    window (and restoration of the original size for all other categories).     *
     *                                                                                *
     *================================================================================*/
    
    NSString *wordkey;
    buttonIndex = [sender tag];
    classRootData *rootData;

    keyEntryworkspace = [@"" mutableCopy];
    [selectionCriteriaLabel setStringValue:@"None"];
    if( buttonIndex == 1 )
    {
        [mainWindow setFrame:(NSMakeRect(0, 0, 760, 717)) display:YES];
        [mainWindow center];
    }
    else
    {
        [mainWindow setFrame:(NSMakeRect(0, 0, 374, 717)) display:YES];
        [mainWindow center];
    }
    [wordListContents removeAllObjects];
    for( wordkey in rootDataStore)
    {
        rootData = [rootDataStore valueForKey:wordkey];
        if ((rootData.catCode == buttonIndex) && ( rootData.isFoundInNT))
        {
            if( ! [wordListContents doesContain:rootData.rootWord] ) [wordListContents addObject:rootData.rootWord];
        }
    }
    originalWordList = [[NSArray alloc] initWithArray:[[processesForData simpleGkSort:[wordListContents sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]] mutableCopy]];
    [wordListContents removeAllObjects];
    [wordListContents addObjectsFromArray:originalWordList];
    [tabViewWordList reloadData];
}

-(IBAction) handleTenseCheckButton: (id) sender
{
    bool isChecked = false;
    NSInteger idx, noOfButtons;
    NSButton *currentButton;
    
    noOfButtons = [tenseChecks count];
    for( idx = 0; idx < noOfButtons; idx++)
    {
        currentButton = [tenseChecks objectAtIndex:idx];
        if( [currentButton state] == NSControlStateValueOn)
        {
            isChecked = true;
            break;
        }
    }
    if( isChecked ) [selectTenses setTitle:@"Unselect All Tenses"];
    else [selectTenses setTitle:@"Select All Tenses"];
}

-(IBAction)handleTenseButtonClick:(id)sender
{
    NSInteger idx, noOfButtons;
    NSButton *currentButton;

    noOfButtons = [tenseChecks count];
    if( [[selectTenses title] compare:@"Select All Tenses"] == NSOrderedSame)
    {
        for( idx = 0; idx < noOfButtons; idx++)
        {
            currentButton = [tenseChecks objectAtIndex:idx];
            [currentButton setState: NSControlStateValueOn];
        }
        [selectTenses setTitle:@"Unselect All Tenses"];
    }
    else
    {
        for( idx = 0; idx < noOfButtons; idx++)
        {
            currentButton = [tenseChecks objectAtIndex:idx];
            [currentButton setState: NSControlStateValueOff];
        }
        [selectTenses setTitle:@"Select All Tenses"];
    }
}

-(void) handleMoodCheckButton: (id) sender
{
    bool isChecked = false;
    NSInteger idx, noOfButtons;
    NSButton *currentButton;
    
    noOfButtons = [moodChecks count];
    for( idx = 0; idx < noOfButtons; idx++)
    {
        currentButton = [moodChecks objectAtIndex:idx];
        if( [currentButton state] == NSControlStateValueOn)
        {
            isChecked = true;
            break;
        }
    }
    if( isChecked ) [selectMoods setTitle:@"Unselect All Main Moods"];
    else [selectMoods setTitle:@"Select All Main Moods"];
}

-(IBAction)handleMoodButtonClick:(id)sender
{
    NSInteger idx, noOfButtons;
    NSButton *currentButton;

    noOfButtons = [moodChecks count];
    if( [[selectMoods title] compare:@"Select All Main Moods"] == NSOrderedSame)
    {
        for( idx = 0; idx < noOfButtons; idx++)
        {
            currentButton = [moodChecks objectAtIndex:idx];
            [currentButton setState: NSControlStateValueOn];
        }
        [selectMoods setTitle:@"Unselect All Main Moods"];
    }
    else
    {
        for( idx = 0; idx < noOfButtons; idx++)
        {
            currentButton = [moodChecks objectAtIndex:idx];
            [currentButton setState: NSControlStateValueOff];
        }
        [selectMoods setTitle:@"Select All Main Moods"];
    }
}

-(void) keyButton_Click: (id) sender
{
    NSInteger tagValue;
    
    tagValue = [sender tag];
    switch (tagValue)
    {
        case 9:
            [self removeLastChar];
            break;
        case 19:
            [self clearConstraints];
            break;
        default:
            [self processAddedChar:[sender title]];
            break;
    }
}

-(void) processAddedChar: (NSString *) newChar
{
    /*================================================================================*
     *                                                                                *
     *                                processAddedChar                                *
     *                                ================                                *
     *                                                                                *
     *  Purpose:                                                                      *
     *  =======                                                                       *
     *                                                                                *
     *  a) Add a character to the reported text entry string (selectionCriteriaLabel) *
     *  b) Remove entries from the "listbox" that do not match the selection criteria *
     *                                                                                *
     *  Step b) in more detail:                                                       *
     *     i)   Find the length of the new entered text;                              *
     *     ii)  Step through the wordListContents that form the current list;         *
     *     iii) If the currently inspected word in the list is less than the length   *
     *          found in i), ignore it.                                               *
     *     iv)  Otherwise, truncate the inspected word to the same length             *
     *     v)   If the truncated word matches the text entered by the virtual         *
     *          keyboard, add the original word from the list *in the same order* to  *
     *          the temporary array of words                                          *
     *     vi)  when finished, transfer the reduced list to wordListContents and      *
     *          redo the list in the "listbox".                                       *
     *                                                                                *
     *================================================================================*/
    
    NSInteger idx, noOfWords, wordLength, removalPstn;
    NSString *constrainingPref, *sampledWord;
    NSMutableArray *wordListTemp;
    
    wordListTemp = [[NSMutableArray alloc] init];
    removalPstn = [keyEntryworkspace length];
    constrainingPref = [[NSString alloc] initWithFormat:@"%@%@", keyEntryworkspace, newChar];
    noOfWords = [wordListContents count];
    for( idx = 0; idx < noOfWords; idx++)
    {
        sampledWord = [[NSString alloc] initWithString:[wordListContents objectAtIndex:idx]];
        wordLength = [constrainingPref length];
        if( [constrainingPref compare:[processesForData nakedWord:[sampledWord substringToIndex:wordLength]]] == NSOrderedSame) [wordListTemp addObject:sampledWord];
    }
    [wordListContents removeAllObjects];
    [wordListContents addObjectsFromArray:wordListTemp];
    [tabViewWordList reloadData];
    keyEntryworkspace = [constrainingPref mutableCopy];
    if( [[selectionCriteriaLabel stringValue] compare:@"None"] == NSOrderedSame)
    {
        [selectionCriteriaLabel setStringValue:@""];
    }
    [selectionCriteriaLabel setStringValue:keyEntryworkspace];
}

-(void) removeLastChar
{
    /*================================================================================*
     *                                                                                *
     *                                removeLastChar                                  *
     *                                ==============                                  *
     *                                                                                *
     *  Purpose:                                                                      *
     *  =======                                                                       *
     *                                                                                *
     *  a) Remove the last character added to the reported text entry string          *
     *       (selectionCriteriaLabel)                                                 *
     *  b) Reload entries into the "listbox" that match the selection criteria        *
     *                                                                                *
     *================================================================================*/
    
    NSInteger removalPstn, idx, noOfWords, wordLength;
    NSString *sampledWord;
    NSMutableArray *wordListTemp;
    
    removalPstn = [keyEntryworkspace length];
    if( removalPstn == 0 ) return;
    if( removalPstn == 1 )
    {
        [self clearConstraints];
    }
    else
    {
        wordListTemp = [[NSMutableArray alloc] init];
        removalPstn--;
        keyEntryworkspace = [[NSMutableString alloc] initWithString:[keyEntryworkspace substringWithRange:NSMakeRange(0, removalPstn )]];
        noOfWords = [originalWordList count];
        for( idx = 0; idx < noOfWords; idx++)
        {
            sampledWord = [[NSString alloc] initWithString:[originalWordList objectAtIndex:idx]];
            wordLength = [keyEntryworkspace length];
            if( [sampledWord length] < wordLength) continue;
            if( [keyEntryworkspace compare:[processesForData nakedWord:[sampledWord substringToIndex:wordLength]]] == NSOrderedSame) [wordListTemp addObject:sampledWord];
        }
        [wordListContents removeAllObjects];
        [wordListContents addObjectsFromArray:[processesForData simpleGkSort:wordListTemp]];
        [tabViewWordList reloadData];
        [selectionCriteriaLabel setStringValue:keyEntryworkspace];
    }
}

-(void) clearConstraints
{
    keyEntryworkspace = [[NSMutableString alloc] initWithString:@""];
    [wordListContents removeAllObjects];
    [wordListContents addObjectsFromArray:originalWordList];
    [tabViewWordList reloadData];
    [selectionCriteriaLabel setStringValue:@"None"];
}

-(void) populateGkFlattener
{
    /*---------------------------------------------------------------------------------------------------*
     *                                                                                                   *
     *   Step 1d: Greek conversion data.                                                                 *
     *   =======                                                                                         *
     *                                                                                                   *
     *   Provide a "look-up table" to associate non-virgin Greek characters with their virgin            *
     *     counterparts.  In other words for each combination of character with accent, breathing, iota  *
     *     subscript or diaeresis, associate the base character.  Note also that capitals will also be   *
     *     associated with lower case basic characters.                                                  *
     *                                                                                                   *
     *---------------------------------------------------------------------------------------------------*/

    NSInteger indexMax, idx, jdx, runningCount = 0;
    NSString *element1, *element2;
    NSArray *gkLetters = [[NSArray alloc] initWithObjects:
                      @"ἀ", @"ἁ", @"ἂ", @"ἃ", @"ἄ", @"ἅ", @"ἆ", @"ἇ", @"Ἀ", @"Ἁ", @"Ἂ", @"Ἃ", @"Ἄ", @"Ἅ", @"Ἆ", @"Ἇ", @"ᾀ", @"ᾁ", @"ᾂ", @"ᾃ", @"ᾄ", @"ᾅ", @"ᾆ", @"ᾇ",
                      @"ᾈ", @"ᾉ", @"ᾊ", @"ᾋ", @"ᾌ", @"ᾍ", @"ᾎ", @"ᾏ", @"ᾰ", @"ᾱ", @"ᾲ", @"ᾳ", @"ᾴ", @"᾵", @"ᾶ", @"ᾷ", @"Ᾰ", @"Ᾱ", @"Ὰ", @"Ά", @"ᾼ", @"ὰ", @"ά",
                      @"ἐ", @"ἑ", @"ἒ", @"ἓ", @"ἔ", @"ἕ", @"἖", @"἗", @"Ἐ", @"Ἑ", @"Ἒ", @"Ἓ", @"Ἔ", @"Ἕ", @"ὲ", @"έ", @"Ὲ", @"Έ",
                      @"ἠ", @"ἡ", @"ἢ", @"ἣ", @"ἤ", @"ἥ", @"ἦ", @"ἧ", @"Ἠ", @"Ἡ", @"Ἢ", @"Ἣ", @"Ἤ", @"Ἥ", @"Ἦ", @"Ἧ", @"ᾐ", @"ᾑ", @"ᾒ", @"ᾓ", @"ᾔ", @"ᾕ", @"ᾖ",
                      @"ᾗ", @"ᾘ", @"ᾙ", @"ᾚ", @"ᾛ", @"ᾜ", @"ᾝ", @"ᾞ", @"ᾟ", @"ῂ", @"ῃ", @"ῄ", @"ῆ", @"ῇ", @"Ὴ", @"Ή", @"ῌ", @"ὴ", @"ή",
                      @"ἰ", @"ἱ", @"ἲ", @"ἳ", @"ἴ", @"ἵ", @"ἶ", @"ἷ", @"Ἰ", @"Ἱ", @"Ἲ", @"Ἳ", @"Ἴ", @"Ἵ", @"Ἶ", @"Ἷ", @"ῐ", @"ῑ", @"ῒ", @"ΐ", @"ῖ", @"ῗ", @"Ῐ", @"Ῑ", @"Ὶ", @"Ί", @"ὶ", @"ί",
                      @"ὀ", @"ὁ", @"ὂ", @"ὃ", @"ὄ", @"ὅ", @"Ὀ", @"Ὁ", @"Ὂ", @"Ὃ", @"Ὄ", @"Ὅ", @"ὸ", @"ό",
                      @"ὐ", @"ὑ", @"ὒ", @"ὓ", @"ὔ", @"ὕ", @"ὖ", @"ὗ", @"Ὑ", @"Ὓ", @"Ὕ", @"Ὗ", @"ῠ", @"ῡ", @"ῢ", @"ΰ", @"ῦ", @"ῧ", @"Ῠ", @"Ῡ", @"Ὺ", @"Ύ", @"ὺ", @"ύ",
                      @"ὠ", @"ὡ", @"ὢ", @"ὣ", @"ὤ", @"ὥ", @"ὦ", @"ὧ", @"Ὠ", @"Ὡ", @"Ὢ", @"Ὣ", @"Ὤ", @"Ὥ", @"Ὦ", @"Ὧ", @"ᾠ", @"ᾡ", @"ᾢ", @"ᾣ", @"ᾤ", @"ᾥ", @"ᾦ",
                      @"ᾧ", @"ᾨ", @"ᾩ", @"ᾪ", @"ᾫ", @"ᾬ", @"ᾭ", @"ᾮ", @"ᾯ", @"ῲ", @"ῳ", @"ῴ", @"ῶ", @"ῷ", @"Ὸ", @"Ό", @"Ὼ", @"Ώ", @"ῼ", @"ὼ", @"ώ",
                      @"ῤ", @"ῥ", @"Ῥ", nil ];
    NSArray *gkBaseLetters = [[NSArray alloc] initWithObjects: @"α", @"ε", @"η", @"ι", @"ο", @"υ", @"ω", @"ρ", nil ];
    NSArray *gkLetterCounts = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:47], [NSNumber numberWithInt:18], [NSNumber numberWithInt:42], [NSNumber numberWithInt:28],
                           [NSNumber numberWithInt:14], [NSNumber numberWithInt:24], [NSNumber numberWithInt:44], [NSNumber numberWithInt:3], nil ];
    NSArray *majiscules = [[NSArray alloc] initWithObjects: @"Α", @"Β", @"Γ", @"Δ", @"Ε", @"Ζ", @"Η", @"Θ", @"Ι", @"Κ", @"Λ", @"Μ", @"Ν", @"Ξ", @"Ο", @"Π",
                           @"Ρ", @"Σ", @"Τ", @"Υ", @"Φ", @"Χ", @"Ψ", @"Ω", nil ];
    NSArray *miniscules = [[NSArray alloc] initWithObjects: @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι", @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"π",
                           @"ρ", @"σ", @"τ", @"υ", @"φ", @"χ", @"ψ", @"ω", nil ];
    NSArray *restToBeChanged = [[NSArray alloc] initWithObjects: @"Ά", @"Έ", @"Ή", @"Ί", @"Ό", @"Ύ", @"Ώ", @"Ϊ", @"Ϋ", @"ά", @"έ", @"ή", @"ί", @"ΰ", @"ϊ", @"ϋ", @"ό", @"ύ", @"ώ", nil ];
    NSArray *restComparable = [[NSArray alloc] initWithObjects: @"α", @"ε", @"η", @"ι", @"ο", @"υ", @"ω", @"ι", @"υ", @"α", @"ε", @"η", @"ι", @"ο", @"ι", @"υ", @"ο", @"υ", @"ω", nil ];
    NSArray *simpleAlphabet = [[NSArray alloc] initWithObjects: @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι", @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο",
                               @"π", @"ρ", @"ς", @"σ", @"τ", @"υ", @"φ", @"χ", @"ψ", @"ω", nil ];


    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Creating stored resources for manipulating Greek text"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    indexMax = (int)[gkLetterCounts count];
    for (jdx = 0; jdx < indexMax; jdx++)
    {
        for (idx = 0; idx < [[gkLetterCounts objectAtIndex:jdx] integerValue]; idx++)
        {
            element1 = [[NSString alloc] initWithString:[gkLetters objectAtIndex:runningCount++]];
            element2 = [[NSString alloc] initWithString:[gkBaseLetters objectAtIndex:jdx]];
            [gkFlattener setValue:element1 forKey:element2];
        }
    }
    indexMax = (int)[majiscules count];
    for (idx = 0; idx < indexMax; idx++)
    {
        [gkFlattener setValue:[miniscules objectAtIndex:idx] forKey:[majiscules objectAtIndex:idx]];
    }
    indexMax = (int)[restToBeChanged count];
    for (idx = 0; idx < indexMax; idx++)
    {
        [gkFlattener setValue:[restComparable objectAtIndex:idx] forKey:[restToBeChanged objectAtIndex:idx]];
    }
    indexMax = (int)[simpleAlphabet count];
    for (idx = 0; idx < indexMax; idx++)
    {
        [gkFlattener setValue:[simpleAlphabet objectAtIndex:idx] forKey:[simpleAlphabet objectAtIndex:idx]];
    }
}

- (void) loadNTTitles
{
    /*---------------------------------------------------------------------------------------------------*
     *                                                                                                   *
     *   Step 2a: Load New Testament information and data                                                *
     *   =======                                                                                         *
     *                                                                                                   *
     *   Step a is simply loading book names (and id). All we need from this process is a list of book   *
     *   names, listed by book code.                                                                     *
     *                                                                                                   *
     *---------------------------------------------------------------------------------------------------*/
    int idx;
    NSString *fullFileName, *fileContent, *lineContent;
    NSArray *fileContents, *fileByLine; // = new String[3];
    classBooks *currentBook;

    // Firstly, get a simple list of book names - primarily for references
    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Loading control information for New Testament books"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    fullFileName = [[NSBundle mainBundle] pathForResource:@"Titles" ofType:@"txt"];
    fileContent = [NSString stringWithContentsOfFile:fullFileName encoding:NSUTF8StringEncoding error:nil];
    fileByLine = [[NSArray alloc] initWithArray:[fileContent componentsSeparatedByString:@"\n"]];
    idx = 0;
    for( lineContent in fileByLine)
    {
        // We now have a line from the source file - now get an array of fields on the line
        fileContents = [[NSArray alloc] initWithArray:[lineContent componentsSeparatedByString:@"\t"]];
        if( [fileContents count] < 3 ) continue;
        noOfNTBooks++;
        noOfStoredBooks++;
        currentBook = [[classBooks alloc] init];
        currentBook.commonName = fileContents[1];
        currentBook.shortName = fileContents[2];
        currentBook.fileName = fileContents[3];
        currentBook.actualBookNumber = noOfNTBooks;
        [bookNames setValue:currentBook forKey:[[NSString alloc] initWithFormat:@"%ld", noOfStoredBooks]];
    }
}

-(void) loadNTText
{
    /*---------------------------------------------------------------------------------------------------*
     *                                                                                                   *
     *   Step 2b:                                                                                        *
     *   =======                                                                                         *
     *                                                                                                   *
     *   We now need to load the actual text details.  Note that we load this data in two stages:        *
     *   - stage 1 populates what we have called "raw data" (see below)                                  *
     *   - stage 2 (later) will refine the available data and match different usages by root             *
     *                                                                                                   *
     *   However, we will also need to protect usage by reference and the ability to display the text    *
     *   for any given chapter.                                                                          *
     *                                                                                                   *
     *---------------------------------------------------------------------------------------------------*/
    NSInteger idx, bdx, catCode = -1, bookNo, chapNo, verseNo, prevChapNo = 0, prevVerseNo = 0, parseCode;
    NSString *fullFileName, *partialFileName, *fileContent, *lineContent, *firstChar, *rootWord, *rootTransliteration;
    NSArray *fileByLine, *lineContents;
    classRootData *rootData;
    classBooks *currentBook;
    classChapter *currentChapter;
    classVerse *currentVerse;

    // Now for the  text data. Let's process and store it
    for( bdx = 1; bdx <= noOfNTBooks; bdx++)
    {
        currentBook = [bookNames objectForKey:[[NSString alloc] initWithFormat:@"%ld", bdx]];
        [progressBar incrementBy:1];
        [progressInfo setStringValue:[[NSString alloc] initWithFormat:@"Loading the text of: %@", [currentBook commonName]]];
        [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
        partialFileName = [[NSString alloc] initWithString:[currentBook fileName]];
        partialFileName = [[NSString alloc] initWithString:[partialFileName substringToIndex:[partialFileName length] - 4]];
        fullFileName = [[NSBundle mainBundle] pathForResource:partialFileName ofType:@"txt"];
        fileContent = [NSString stringWithContentsOfFile:fullFileName encoding:NSUTF8StringEncoding error:nil];
        fileByLine = [[NSArray alloc] initWithArray:[fileContent componentsSeparatedByString:@"\n"]];
        idx = 0;
        prevChapNo = 0;
        for( lineContent in fileByLine)
        {
        /*=====================================================================*
         *                                                                    *
         *  Split the line as follows:                                        *
         *   Field                    Contents                                *
         *     0      A six digit book/Chapter/Verse reference                *
         *     1      Two character category reference                        *
         *     2      Eight character parse sequence                          *
         *     3      The word as displayed at that verse                     *
         *     4      The root of the verb                                    *
         *     5      Any punctuation attached to the word (or blank)         *
         *     6      The transliteration of the root word                    *
         *                                                                    *
         *====================================================================*/
            if( [lineContent length] == 0) continue;
            lineContents = [[NSArray alloc] initWithArray:[lineContent componentsSeparatedByString:@"\t"]];
            for (idx = 0; idx < noOfCategories; idx++)
            {
                if ([categoryCodes[idx] compare: [lineContents objectAtIndex:1]] == NSOrderedSame)
                {
                    catCode = idx;
                    break;
                }
            }
            bookNo = [[lineContents[0] substringToIndex:2] integerValue];
            chapNo = [[lineContents[0] substringWithRange:(NSMakeRange(2, 2))] integerValue];
            verseNo = [[lineContents[0] substringFromIndex:4] integerValue];
            rootWord = [[NSString alloc] initWithString:lineContents[4]];
            rootTransliteration = [[NSString alloc] initWithString:lineContents[6]];
            rootData = [self processTextData:bookNo chapNo:chapNo verseNo:verseNo catCode:catCode rootWord:rootWord transliterated:rootTransliteration];
            parseCode = [processesForData getParseInfo:[lineContents objectAtIndex:2]];
            firstChar = [[NSString alloc] initWithString:[rootWord substringToIndex:1]];
            rootData.processRawData = processesForData;
            [rootData addParsedText:parseCode formOfWord:[processesForData cleanTextWord:lineContents[3] withInitialChatacter:firstChar] bookNo:bookNo chapNo:chapNo verseNo:verseNo chapterReference:@"" verseRef:@"" isThisNT:true];
            // Now create the hierarchy to store the text
            if( prevChapNo != chapNo)
            {
                currentChapter = [currentBook addChapter:[[NSString alloc]initWithFormat:@"%ld", chapNo]];
                prevChapNo = chapNo;
                prevVerseNo = 0;
            }
            if( prevVerseNo != verseNo)
            {
                currentVerse = [currentChapter addVerse:[[NSString alloc] initWithFormat:@"%ld", verseNo]];
                prevVerseNo = verseNo;
            }
            [currentVerse addWord:lineContents[3] withPreChars:@"" followingChars:@"" andPunctuation:lineContents[5]];
        }
    }
}

- (void) loadLXXTitles
{
    /*---------------------------------------------------------------------------------------------------*
     *                                                                                                   *
     *   Step 3a: data load for LXX data                                                                 *
     *   =======                                                                                         *
     *                                                                                                   *
     *   Step a will handle information about Septuagint book names and the files containing text data.  *
     *   It is more complex than the equivalent step for NT data because the LXX text is held in         *
     *   files (one for each book).                                                                      *
     *                                                                                                   *
     *   Note also that LXX chapters and verses are not always logically structured and we need to cope  *
     *   with the possibility of:                                                                        *
     *                                                                                                   *
     *     - chapters out of sequence;                                                                   *
     *     - pre-chapter verses (indexed as verse zero in our data;                                      *
     *     - verses identified as e.g. 12a, 12b and so on.                                               *
     *                                                                                                   *
     *---------------------------------------------------------------------------------------------------*/
    NSInteger idx;
    NSString *fileBuffer, *fullFileName, *lineContent;
    NSArray *fileByLine, *fullDetails;
    classBooks *currentTitleEntry;

    // Firstly, get a simple list of book names - primarily for references
    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Loading control data for the Septagint books"];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    fullFileName = [[NSBundle mainBundle] pathForResource:@"LXX_Titles" ofType:@"txt"];
    fileBuffer = [NSString stringWithContentsOfFile:fullFileName encoding:NSUTF8StringEncoding error:nil];
    fileByLine = [[NSArray alloc] initWithArray:[fileBuffer componentsSeparatedByString:@"\n"]];
    idx = 0;
    for( lineContent in fileByLine)
    {
        if( [lineContent length] == 0) continue;;
        if ( [lineContent characterAtIndex:0] != ';')
        {
            noOfLxxBooks++;
            noOfStoredBooks++;
            fullDetails = [[NSArray alloc] initWithArray:[lineContent componentsSeparatedByString:@"\t"]];
            currentTitleEntry = [[classBooks alloc] init];
            currentTitleEntry.shortName = [fullDetails objectAtIndex:0];
            currentTitleEntry.commonName = [fullDetails objectAtIndex:1];
            currentTitleEntry.lxxName = [fullDetails objectAtIndex:2];
            currentTitleEntry.fileName = [fullDetails objectAtIndex:3];
            currentTitleEntry.actualBookNumber = noOfLxxBooks;
            [bookNames setValue:currentTitleEntry forKey:[[NSString alloc] initWithFormat:@"%ld", noOfStoredBooks]];
        }
    }
}

- (void) loadLXXText
{
    /*---------------------------------------------------------------------------------------------------*
     *                                                                                                   *
     *   Step 3b:                                                                                        *
     *   =======                                                                                         *
     *                                                                                                   *
     *   Now load the relevant LXX text data.  This mimics the parallel process for the NT but it is not *
     *   required for all the processes in which the NT data participates.                               *
     *                                                                                                   *
     *---------------------------------------------------------------------------------------------------*/
    NSInteger idx, bdx, catCode = -1, chapterNo, verseNo = 0, newCode;
    NSString *fileBuffer, *fullFileName, *prevChapRef, *prevVerseRef = @"?", *firstCodeChar, *lineContent, *individualItem, *simpleFileName;
    NSString *wordUsed, *rootWord, *rootTransliteration, *preWord, *postWord, *punctuation;
    NSArray *fileByLine, *lineContents;
//    Char[] splitParams = { '\t' };
    classBooks *currentBook;
    classChapter *currentChapter;
    classVerse *currentVerse;
    classRootData *rootData;

    // Now for the  text data. Let's process and store it
    for (bdx = noOfNTBooks + 1; bdx <= noOfStoredBooks; bdx++)
    {
        chapterNo = 0;
        prevChapRef = @"?";
        currentBook = [bookNames objectForKey:[[NSString alloc] initWithFormat:@"%ld", bdx]];
        [progressBar incrementBy:1];
        [progressInfo setStringValue:[[NSString alloc] initWithFormat:@"Loading the text for: %@", [currentBook commonName]]];
        [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
        simpleFileName = [[NSString alloc] initWithString:currentBook.fileName];
        simpleFileName = [[NSString alloc] initWithString:[simpleFileName substringToIndex:[simpleFileName length] - 4]];
        fullFileName = [[NSBundle mainBundle] pathForResource:simpleFileName ofType:@"txt"];
        fileBuffer = [NSString stringWithContentsOfFile:fullFileName encoding:NSUTF8StringEncoding error:nil];
        fileByLine = [[NSArray alloc] initWithArray:[fileBuffer componentsSeparatedByString:@"\n"]];
        for( lineContent in fileByLine)
        {
             /*-------------------------------------------------------------------------------------*
             *                                                                                    *
             *  Split the line as follows:                                                        *
             *                                                                                    *
             *   Field                    Contents                                                *
             *   -----  ------------------------------------------------------------------------  *
             *     1    Chapter number                                                            *
             *     2    Verse number (note: may = 0 or 12b)                                       *
             *     3    Initial Parse code                                                        *
             *     4    Detailed Parse code                                                       *
             *     5    A unique grammatical identifier                                           *
             *     6    Word as it is to be displayed in the text                                 *
             *     7    Word a) all lower case, b) stripped of accents and related furniture      *
             *     8    Word, as in field 7 but also with breathings and iota subscripts removed  *
             *     9    Immediate root of word in field 6                                         *
             *     10   Transliteration of root (field 9)                                         *
             *     11   Pre-word characters                                                       *
             *     12   Post-word non-punctuation characters                                      *
             *     13   Punctuation                                                               *
             *     14   Transliterated version of field 6                                         *
             *     15+  Transliteration of root (with prefixed prepositions separated             *
             *                                                                                    *
             *  However, fields 1 and 2 are as supplied by the source file.  In addition, we will *
             *  create a simple, sequential index for chapters and verses.  This will allow for:  *
             *  a) out-of-sequence chapters (in a few books, there are gaps and, even, chapters   *
             *     transposed;                                                                    *
             *  b) verses that include text as well as digits (e.g. 19b);                         *
             *  c) unnumbered verses (in our data, given the index 0)                             *
             *                                                                                    *
             **************************************************************************************/
            if( [lineContent length] == 0) continue;
            lineContents = [[NSArray alloc] initWithArray:[lineContent componentsSeparatedByString:@"\t"]];
            individualItem = [[NSString alloc] initWithString:[lineContents objectAtIndex:0]];
            if ( [individualItem compare:prevChapRef] != NSOrderedSame)
            {
                chapterNo++;
                currentChapter = [currentBook addChapter:[lineContents objectAtIndex:0]];
                [currentChapter setChapterRef:[[NSString alloc] initWithString:individualItem]];
                prevChapRef = [[NSString alloc] initWithString:[lineContents objectAtIndex:0]];
                verseNo = 0;
                prevVerseRef = @"?";
            }
            individualItem = [[NSString alloc] initWithString:[lineContents objectAtIndex:1]];
            if ( [individualItem compare:prevVerseRef] != NSOrderedSame)
            {
                verseNo++;
                currentVerse = [currentChapter addVerse:[lineContents objectAtIndex:1]];
                prevVerseRef = [[NSString alloc] initWithString:[lineContents objectAtIndex:1]];
            }
            wordUsed = [[NSString alloc] initWithString:[lineContents objectAtIndex:5]];
            rootWord = [[NSString alloc] initWithString:[lineContents objectAtIndex:8]];
            rootTransliteration = [[NSString alloc] initWithString:[lineContents objectAtIndex:9]];
            preWord = [[NSString alloc] initWithString:[lineContents objectAtIndex:10]];
            postWord = [[NSString alloc] initWithString:[lineContents objectAtIndex:11]];
            punctuation = [[NSString alloc] initWithString:[lineContents objectAtIndex:12]];
            [currentVerse addWord:wordUsed withPreChars:preWord followingChars:postWord andPunctuation:punctuation];
            firstCodeChar = [[NSString alloc] initWithString:[[lineContents objectAtIndex:2] substringToIndex:1]];
            catCode = -1;
            for (idx = 0; idx < noOfCategories; idx++)
            {
                if ( [firstCodeChar compare: @"R"] == NSOrderedSame)
                {
                    if ([[categoryCodes objectAtIndex:idx] compare:[lineContents objectAtIndex:3]] == NSOrderedSame)
                    {
                        catCode = idx;
                        break;
                    }
                }
                else
                {
                    if ([[[categoryCodes objectAtIndex:idx] substringToIndex:1] compare:firstCodeChar] == NSOrderedSame)
                    {
                        catCode = idx;
                        break;
                    }
                }
            }
            if( catCode == -1 ) continue;
            /*------------------------------------------------------------------------------*
             *                                                                              *
             *  Note that noOfCategories is the number of _NT_ categories.  The if clause   *
             *    will ignore any LXX entries for ὅστις or indeclinable numbers.  As a      *
             *    result, the grammatical structures of NT and LXX data will be the same.   *
             *                                                                              *
             *------------------------------------------------------------------------------*/
            rootData = [self processTextData:bdx chapNo:chapterNo verseNo:verseNo catCode:catCode rootWord:rootWord transliterated:rootTransliteration];
            newCode = [processesForData getLxxParseInfo:[lineContents objectAtIndex:3] withCode:catCode];
            individualItem = [[NSString alloc] initWithString:[processesForData cleanTextWord:wordUsed withInitialChatacter:[rootWord substringToIndex:1]]];
            rootData.processRawData = processesForData;
            [rootData addParsedText:newCode formOfWord:individualItem bookNo:bdx chapNo:chapterNo verseNo:verseNo chapterReference:[lineContents objectAtIndex:0] verseRef:[lineContents objectAtIndex:1] isThisNT:false];
        }
    }
}

- (void) populateListbox
{
    NSString *dictionaryKey;
    classRootData *rootData;

    [progressBar incrementBy:1];
    [progressInfo setStringValue:@"Populating the \"list box\""];
    [mainLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0001]];
    for( dictionaryKey in rootDataStore)
    {
        rootData = [rootDataStore valueForKey:dictionaryKey];
        if ((rootData.catCode == 0) && ( rootData.isFoundInNT))
        {
            if( ! [wordListContents doesContain:rootData.rootWord] ) [wordListContents addObject:rootData.rootWord];
        }
    }
    originalWordList = [[NSArray alloc] initWithArray:[processesForData simpleGkSort:wordListContents]];
    [wordListContents removeAllObjects];
    [wordListContents addObjectsFromArray:originalWordList];
    [tabViewWordList reloadData];
}

- (classRootData *) processTextData: (NSInteger) bookNo chapNo: (NSInteger) chapNo verseNo: (NSInteger) verseNo catCode: (NSInteger) catCode
                           rootWord: (NSString *) root transliterated: (NSString *) transRoot
{
    NSInteger nRootCodeAlt;
    NSString *catString, *rawKey, *rootCodeString;
    classRootData *rootData;

    /*...........................................................*
     *                                                           *
     *  Construct rawKey: a unique key for a root.               *
     *                                                           *
     *  Effectively, the key is root + verb | noun | etc.        *
     *                                                           *
     *...........................................................*/
    if (catCode < 10)
    {
        catString = [[NSString alloc] initWithFormat: @"0%ld", catCode];
    }
    else
    {
        catString = [[NSString alloc] initWithFormat: @"%ld", catCode];
    }
//    alternativeString = [processesForData getUnicodeString:root];
    rawKey = [[NSString alloc] initWithFormat:@"%@%@", transRoot, catString];
    /*...........................................................*
     *                                                           *
     *  The point now is to get to a "record" of a unique root   *
     *    word.  Either the word already has some data (first    *
     *    clause) or we haven't previously encountered it (2nd). *
     *                                                           *
     *...........................................................*/
//    if ([rootLookup objectForKey:rawKey] != nil)
    rootCodeString = [rootLookup objectForKey:rawKey];
    if (rootCodeString == nil)
    {
        nRootCount++;
        noOfNtRoots++;
        [rootLookup setValue:[[NSString alloc] initWithFormat:@"%ld", nRootCount] forKey:rawKey];
        rootData = [[classRootData alloc] init];
        rootData.rootWord = root;
        rootData.catCode = catCode;
        rootData.rootTransliteration = transRoot;
        [rootDataStore setValue:rootData forKey:[[NSString alloc] initWithFormat:@"%ld", nRootCount]];
    }

    else
    {
        // The root word has already been stored for that category
        nRootCodeAlt = [[rootLookup objectForKey:rawKey] integerValue];
        rootData = [rootDataStore objectForKey:[[NSString alloc] initWithFormat:@"%ld", nRootCodeAlt]];
    }
    /*----------------------------------------------------------------------------------------------*
     *                                                                                              *
     *  Add to the "record" of the unique root:                                                     *
     *                                                                                              *
     *  a) the reference of this occurrence (book, chapter and verse code);                         *
     *  b) the "parseCode" for the word (= a unique value for its grammatical character);           *
     *  c) the actual word used                                                                     *
     *                                                                                              *
     *  So, for example, if the root referenced by rootData is the verb λύω, this particulaar       *
     *    occurrence might be, e.g., λύεις.  The next one might be λύσαν.  So, we have access to    *
     *    both occurrences.                                                                         *
     *                                                                                              *
     *----------------------------------------------------------------------------------------------*/
//    rootData.ProcessRawData = processRawData;
    return rootData;
}

- (IBAction)doAnalyse:(id)sender
{
    NSInteger markedRow;
    NSString *selectedItem;
    
    markedRow = [tabViewWordList selectedRow];
    if( markedRow == -1) markedRow = 0;
    selectedItem = [[NSString alloc] initWithString:[wordListContents objectAtIndex:markedRow]];
    [self processAnalysis: selectedItem];
}

//- (void) tableViewSelectionDidChange:(NSNotification *)notification
- (void) doDoubleClick: (id) object
{
    NSInteger markedRow;
    NSString *selectedItem;
    
    markedRow = [tabViewWordList selectedRow];
    if( markedRow == -1) markedRow = 0;
    selectedItem = [[NSString alloc] initWithString:[wordListContents objectAtIndex:markedRow]];
    [self processAnalysis: selectedItem];
}

- (void) processAnalysis: (NSString *) selectedItem
{
    NSString *catCodeString, *classKey, *rootCodeString;
    classRootData *currentRootData;
    
//    [self saveStoredData];
    if( buttonIndex < 10) catCodeString = [[NSString alloc] initWithFormat:@"0%ld", buttonIndex];
    else catCodeString = [[NSString alloc] initWithFormat:@"%ld", buttonIndex];
    classKey = [[NSString alloc] initWithFormat:@"%@%@", [processesForData transliterateText:selectedItem], catCodeString];
    rootCodeString = [rootLookup objectForKey:classKey];
    if( rootCodeString == nil) return;
    currentRootData = [rootDataStore objectForKey:rootCodeString];
    if( currentRootData == nil) return;
    switch (buttonIndex)
    {
        case 0: [self processNouns: currentRootData forWord:selectedItem]; break;
        case 1: [self processVerbs: currentRootData forWord:selectedItem]; break;
        case 2: [self processAdjectives: currentRootData forWord: selectedItem andCanBeComparable:true withTitle: @"Adjective"]; break;
        case 3: [self processSimple: currentRootData forWord: selectedItem withTitle: @"Adverb"]; break;
        case 4: [self processSimple: currentRootData forWord: selectedItem withTitle: @"Preposition"]; break;
        case 5: [self processAdjectives: currentRootData forWord: selectedItem andCanBeComparable:false withTitle: @"Article"]; break;
        case 6: [self processAdjectives: currentRootData forWord: selectedItem andCanBeComparable:false withTitle: @"Demonstrative Pronoun"]; break;
        case 7: [self processAdjectives: currentRootData forWord: selectedItem andCanBeComparable:false withTitle: @"Indefinite Pronoun"]; break;
        case 8: [self processAdjectives: currentRootData forWord: selectedItem andCanBeComparable:false withTitle: @"Personal Pronoun"]; break;
        case 9: [self processAdjectives: currentRootData forWord: selectedItem andCanBeComparable:false withTitle: @"Relative Pronoun"]; break;
        case 10: [self processSimple: currentRootData forWord: selectedItem withTitle: @"Particle"]; break;
        case 11: [self processSimple: currentRootData forWord: selectedItem withTitle: @"Conjunction"]; break;
        case 12: [self processSimple: currentRootData forWord: selectedItem withTitle: @"Interjection"]; break;
            
        default:
            break;
    }
}

-(void) processNouns: (classRootData *) currentEntry forWord: (NSString *) selectedEntry
{
    /*=========================================================================================*
     *                                                                                         *
     *                                  processNouns                                           *
     *                                  ============                                           *
     *                                                                                         *
     *  Parameters:                                                                            *
     *  ==========                                                                             *
     *  currentEntry:  The rootData instance associated with the selectedEntry                 *
     *  selectedEntry: The text of the entry (noun root) currently selected                    *
     *                                                                                         *
     *                                                                                         *
     *  Process:                                                                               *
     *  =======                                                                                *
     *                                                                                         *
     *  The aim of this method is to identify all the forms of the word found in the NT or     *
     *  (optionally) the LXX and present them in a suitable table.  The table is actually      *
     *  managed by frmUsage.  Here, we organise the information to be displayed in the 3-d     *
     *  array, wordDetails.  The dimensions of the array are as follows:                       *
     *                                                                                         *
     *      Dimension                             Purpose                                      *
     *          0           Not used in Nouns                                                  *
     *          1           Case                                                               *
     *          2           Singular or plural (LXX Dual is treated as plural)                 *
     *                                                                                         *
     *  wordRefs is also a 3-d array, keyed in much the same way as wordDetails.  It stores    *
     *  the classReferenceDetail instance for the specific row and column, if it exists.       *
     *                                                                                         *
     *=========================================================================================*/

    NSInteger parseCode, codeCalculation, colCode, noOfRows = 6, calcCellStatus, formPosition = 0, oldCellStatus;
    NSString *wordOut = @"", *parseCodeString, *tempWord, *possRefCode;
    /*------------------------------------------------------------------------------------*
     *                                                                                    *
     *  cellStatus, textDetails and wordRefs:                                             *
     *  ------------------------------------                                              *
     *                                                                                    *
     *  Purpose:                                                                          *
     *  -------                                                                           *
     *                                                                                    *
     *  These three arrays are used to communicate with frmUsage and beyond. In each case *
     *  they are actually three-dimensional arrays.  These dimensions are:                *
     *  individual arrays are:                                                            *
     *                                                                                    *
     *  dim 1: pages - only verbs, = voices (active, middle and passive)                  *
     *  dim 2: rows - for nouns and similar, = cases; for verbs, both tenses and persons  *
     *  dim 3: columns - description, singular and plural                                 *
     *                                                                                    *
     *  However, Objective-C does not handle 3-d well.  Consequently, we are using a naff *
     *  tactic to overcome this weakness.  In each case, the array is implemented by a    *
     *  NSDictionary with an NSInteger key (which functions as the index).  This index    *
     *  is formed as follows:                                                             *
     *                                                                                    *
     *    dim 1: page no (0, 1 or 2) * 10000 (ten thousand)                               *
     *    dim 2: row no * 10 (max. possible rows = about 120)                             *
     *    dim 3: column no (0, 1 or 2)                                                    *
     *                                                                                    *
     *  The three "arrays" serve the following functions:                                 *
     *                                                                                    *
     *    textDetails:  The text that is entered in the relevant cell                     *
     *    wordRefs:     The address of an instance of classReference that provides all    *
     *                  the references of the given word used in the specific grammatical *
     *                  form                                                              *
     *    cellStatus:   A NSInteger code indicating its use (or non-use) in NT and LXX,   *
     *                  follows:                                                          *
     *                     0   No entry was found matching the grammatical details of     *
     *                         that cell                                                  *
     *                     1   A New Testament (only) entry matched the cell details      *
     *                     2   An Old Testament (Septuagint) entry matched the cell       *
     *                         details                                                    *
     *                     3   Entries for both NT and LXX were found                     *
     *                                                                                    *
     *------------------------------------------------------------------------------------*/
    NSMutableDictionary *cellStatus, *textDetails, *wordRefs, *refStoreCorrection;
    NSDictionary *currentEntryDetails;
    /*------------------------------------------------------------------------------------*
     *                                                                                    *
     *  refStore:                                                                         *
     *  --------                                                                          *
     *                                                                                    *
     *  List of references:                                                               *
     *                                                                                    *
     *    key:   integer uniquely identifying the reference                               *
     *    value: address of classReference instance                                       *
     *                                                                                    *
     *------------------------------------------------------------------------------------*/
    NSDictionary *refStore;
    classParsedItem *parsedItem;

    // Initialise the three "arrays"
    textDetails = [[NSMutableDictionary alloc] init];
    cellStatus = [[NSMutableDictionary alloc] init];
    wordRefs = [[NSMutableDictionary alloc] init];
    // Populate the row "headers"
    [textDetails setValue:@"Nominative" forKey:[[NSString alloc] initWithFormat:@"%d",0]];
    [textDetails setValue:@"Vocative" forKey:[[NSString alloc] initWithFormat:@"%d",10]];
    [textDetails setValue:@"Accusative" forKey:[[NSString alloc] initWithFormat:@"%d",20]];
    [textDetails setValue:@"Genitive" forKey:[[NSString alloc] initWithFormat:@"%d",30]];
    [textDetails setValue:@"Dative" forKey:[[NSString alloc] initWithFormat:@"%d",40]];
    /*------------------------------------------------------------------------------------*
     *  Reminder:                                                                         *
     *  currentEntry Details (= parseList) is a list of classParsedItem for the word.     *
     *  key:   a unique value based on the grammatical structure of the specific form;    *
     *  value: the address of a classParsedItem instance.                                 *
     *------------------------------------------------------------------------------------*/
    currentEntryDetails = [currentEntry getParseList];
    for( parseCodeString in currentEntryDetails)
    {
        // Get the actual text for the current grammatical structure
        if( parseCodeString == nil) continue;
        parsedItem = [currentEntryDetails valueForKey:parseCodeString];
        if( parsedItem == nil) continue;
        [parsedItem setProcessClass:processesForData];
        // Now really get the words
        wordOut = [parsedItem getWords:selectedEntry];
        // And the calculated code
        parseCode = [parsedItem parseCode];
        // Deconstruct the code to give the row (= codeCalculation) and column (= colCode)
        codeCalculation = ((parseCode % 100000) / 10000 ) - 1;
        colCode = parseCode % 10;
        // And whether the word form(s) is/are wholly NT, wholly LXXX or both ( store result in refStore)
        calcCellStatus = 0;
        if ( [parsedItem isInNt]) calcCellStatus = 1;
        if ( [parsedItem isInLXX]) calcCellStatus += 2;
        refStore = [[NSDictionary alloc] initWithDictionary:[[parsedItem referenceList] copy]];
        if (colCode == 7)
        {
            formPosition = codeCalculation * 10 + 1;
/*            [textDetails setValue:wordOut forKey:[[NSString alloc] initWithFormat:@"%ld",codeCalculation * 10 + 1]];
            [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat:@"%ld",codeCalculation * 10 + 1]];
            [wordRefs setValue:refStore forKey:[[NSString alloc] initWithFormat:@"%ld",codeCalculation * 10 + 1]]; */
        }
        if (colCode == 8)
        {
            formPosition = codeCalculation * 10 + 2;
/*            [textDetails setValue:wordOut forKey:[[NSString alloc] initWithFormat:@"%ld",codeCalculation * 10 + 2]];
            [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat:@"%ld",codeCalculation * 10 + 2]];
            [wordRefs setValue:refStore forKey:[[NSString alloc] initWithFormat:@"%ld",codeCalculation * 10 + 2]]; */
        }
        /*------------------------------------------------------------------------------------*
         *                                                                                    *
         *  Some of the LXX data does not provide a gender in its parse code.  This means     *
         *  that a specific case and singular/plural may have _two_ parse lists - one with a  *
         *  gender and one without.  This little carbuncle is required to "merge" the two     *
         *                                                                                    *
         *------------------------------------------------------------------------------------*/
        tempWord = [textDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
        if( tempWord == nil)
        {
            [textDetails setValue:wordOut forKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
            [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
            [wordRefs setValue:refStore forKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
        }
        else
        {
            if( ! [wordOut containsString:tempWord])
            {
                if( ! [tempWord containsString:wordOut]) tempWord = [[NSString alloc] initWithFormat:@"%@, %@", wordOut, tempWord];
                [textDetails removeObjectForKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
                [textDetails setValue:tempWord forKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
            }
            oldCellStatus = [[cellStatus objectForKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]] integerValue];
            if( oldCellStatus != calcCellStatus) [cellStatus setValue:@"3" forKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
            refStoreCorrection = [[NSMutableDictionary alloc] initWithDictionary:[wordRefs objectForKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]]];
            for( NSString *keyVal in refStore)
            {
                possRefCode = [refStoreCorrection objectForKey:keyVal];
                if( possRefCode == nil) [refStoreCorrection setValue:[refStore objectForKey:keyVal] forKey:keyVal];
            }
            [wordRefs removeObjectForKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
            [wordRefs setValue:refStoreCorrection forKey:[[NSString alloc] initWithFormat:@"%ld",formPosition]];
        }
        

    }
    // Now we have all the info, lets set up the display
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

    generalUsage = [[frmUsage alloc] initWithWindowNibName:@"frmUsage"];
    generalUsage.isVerb = false;
    generalUsage.grammarName = @"Noun";
    generalUsage.onlyDisplayNT = onlyDisplayNT;
    generalUsage.ntOnlyCode = ntOnlyCode;
    generalUsage.lxxOnlyCode = lxxOnlyCode;
    generalUsage.ntAndLxxCode = ntAndLxxCode;
    [generalUsage initialiseForm:bookNames];
    generalUsage.tableContents = textDetails;
    generalUsage.cellStatus = cellStatus;
    generalUsage.entryReferences = [wordRefs copy];
    [generalUsage displayTable:noOfRows];
    [generalUsage showWindow:nil];
    [generalUsage setWordItself:[currentEntry rootWord]];
}

- (void) processVerbs: (classRootData *) currentEntry forWord: (NSString *) selectedEntry
{
    /*===========================================================================================================*
     *                                                                                                           *
     *                                              processVerbs                                                 *
     *                                              ============                                                 *
     *                                                                                                           *
     *  See the description of processNouns for the general summary of how this method functions.  The only key  *
     *  difference is that the verb analysis results in three pages, not one:                                    *
     *    0  Active voise                                                                                        *
     *    1  Middle voice                                                                                        *
     *    2  Passive voice                                                                                       *
     *                                                                                                           *
     *  Note that where the passive and middle voices have the same form, these are often reported under the     *
     *    middle voice for the LXX.                                                                              *
     *                                                                                                           *
     *===========================================================================================================*/

    NSInteger noOfRows, rowCount, tenseCount, moodCount, moodIdx, entryCode, tenseIdx, idx, cdx, gdx, vdx, noOfTenses, noOfMoods, noOfSelectedTenses, noOfSelectedMoods, calcCellStatus;
    NSString *tenseDesc;
    NSMutableArray *tenseStarts, *moodStarts;
    /*-----------------------------------------------------------------------------------------------------------*
     *                                                                                                           *
     *                                    cellStatus, textDetails and wordRefs                                   *
     *                                    ------------------------------------                                   *
     *                                                                                                           *
     *  Details of how these three "3-d arrays" function can be found in processNouns, above.                    *
     *                                                                                                           *
     *-----------------------------------------------------------------------------------------------------------*/
    NSMutableDictionary *cellStatus, *textDetails, *wordRefs;
    NSDictionary *currentEntryDetails;
    NSButton *checkTButton, *checkMButton;
    classParsedItem *currentDetails;

    // Before we start, let's check for completely unchecked tense and mood boxes - if so, they are treated as all checked
    /*------------------------------------------------------------------------------------------*
     *                                                                                          *
     *   Before we start, let's check for completely unchecked tense and mood boxes - if so,    *
     *   they are treated as all checked - will, in fact, all be set as selected.               *
     *                                                                                          *
     *   We will note the row count at which each tense starts (which will be  stored in        *
     *     tenseStarts, where the index represents each tense).  If the value of any is @"",    *
     *     then that tense is not used.                                                         *
     *                                                                                          *
     *------------------------------------------------------------------------------------------*/
    noOfTenses = [tenseNames count];
    tenseStarts = [[NSMutableArray alloc] init];
    for (tenseIdx = 0; tenseIdx < noOfTenses; tenseIdx++)
    {
        [tenseStarts addObject:@""];
    }
    noOfSelectedTenses = 0;
    for (checkTButton in tenseChecks)
    {
        if( [checkTButton state] == NSControlStateValueOn) noOfSelectedTenses++;
    }
    if( noOfSelectedTenses == 0)
    {
        for (checkTButton in tenseChecks) [checkTButton setState:NSControlStateValueOn];
        noOfSelectedTenses = noOfTenses;
    }
    // Moods are slightly different: we need to check initially whether the user has selected Participles or other moods
    if ( [selectNonParticiples state] == NSControlStateValueOn)
    {
        noOfMoods = [moodNames count];
        noOfRows = 0;
        moodStarts = [[NSMutableArray alloc] init];
        for( moodIdx = 0; moodIdx < noOfMoods; moodIdx++)
        {
            [moodStarts addObject:@""];
        }
        noOfSelectedMoods = 0;
        for( checkMButton in moodChecks)
        {
            if( [checkMButton state] == NSControlStateValueOn)
            {
                noOfSelectedMoods++;
                if( [checkMButton tag] == noOfMoods - 1) noOfRows++;
                else noOfRows += 3;
            }
        }
        if( noOfSelectedMoods == 0)
        {
            for( checkMButton in moodChecks) [checkMButton setState:NSControlStateValueOn];
            noOfSelectedMoods = noOfMoods;
        }
    }
    /*-----------------------------------------------------------------------------------------*
     *                                                                                         *
     *                          The main processing of the method                              *
     *                          ---------------------------------                              *
     *                                                                                         *
     *  For each voice, we step through each selected tense.  For each tense, we step through  *
     *  each selected mood.  For each tense and each selected mood we allocate:                *
     *     1 row for the tense name                                                            *
     *     3 rows for the 1st, 2nd and 3rd person.                                             *
     *  In the case of the infinitive, we allocate a single row.                               *
     *  Also, for all except the first tense, we start by allocating a blank row.              *
     *                                                                                         *
     *-----------------------------------------------------------------------------------------*/
    
    // Initialise the three "arrays"
    textDetails = [[NSMutableDictionary alloc] init];
    cellStatus = [[NSMutableDictionary alloc] init];
    wordRefs = [[NSMutableDictionary alloc] init];
    rowCount = 0;
    tenseCount = 0;
    currentEntryDetails = [currentEntry getParseList];
    for (checkTButton in tenseChecks)
    {
        if( [checkTButton state] == NSControlStateValueOn)
        {
            if( rowCount > 0 )
            {
                // Add a blank row
                for( vdx = 0; vdx < 3; vdx++)
                {
                    [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                    [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                    [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                }
                rowCount++;
            }
            moodCount = 0;
            if ( [selectNonParticiples state] == NSControlStateValueOn)
            {
                for( checkMButton in moodChecks)
                {
                    if( [checkMButton state] == NSControlStateValueOn)
                    {
                        // First the group title
                        tenseDesc = [[NSString alloc] initWithFormat:@"%@ %@", tenseNames[tenseCount], moodNames[moodCount]];
                        for( vdx = 0; vdx < 3; vdx++)
                        {
                            [textDetails setValue:tenseDesc forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                        }
                        rowCount++;
                        // Now the actual data
                        for( idx = 1; idx <= 3; idx++)
                        {
                            for( vdx = 0; vdx < 3; vdx++)
                            {
                                entryCode = (vdx + 1) * 1000 + (moodCount + 1) * 100 + (tenseCount + 1) * 10 + idx;
                                calcCellStatus = 0;
                                switch (idx)
                                {
                                    case 1: tenseDesc = @"     1st person"; break;
                                    case 2: tenseDesc = @"     2nd person"; break;
                                    case 3: tenseDesc = @"     3rd person"; break;
                                    default: break;
                                }
                                [textDetails setValue:[[NSString alloc] initWithString:tenseDesc] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                                currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld", entryCode]];
                                if (currentDetails != nil)
                                {
                                    [currentDetails setProcessClass:processesForData];
                                    [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                                    if ( [currentDetails isInNt]) calcCellStatus = 1;
                                    if ( [currentDetails isInLXX] ) calcCellStatus += 2;
                                    [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                                    [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                                }
                                else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                                calcCellStatus = 0;
                                currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld", entryCode + 3]];
                                if (currentDetails != nil)
                                {
                                    [currentDetails setProcessClass:processesForData];
                                    [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                                    if ( [currentDetails isInNt]) calcCellStatus = 1;
                                    if ( [currentDetails isInLXX] ) calcCellStatus += 2;
                                    [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                                    [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                                }
                                else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                            } // vdx for loop
                            rowCount++;
                        } // idx for loop
                    } // if mood check button
                    moodCount++;
                }  // mood check button loop
            }  // if not participles
            else
            {
                // First the group title
                tenseDesc = [[NSString alloc] initWithFormat:@"%@ tense", tenseNames[tenseCount]];
                for( vdx = 0; vdx < 3; vdx++)
                {
                    [textDetails setValue:tenseDesc forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                    [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                    [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                }
                rowCount++;
                for( gdx = 0; gdx < 3; gdx++)
                {
                    // Enumerate through genders - first provide a row space, if suitable
                    if( gdx > 0 )
                    {
                        for( vdx = 0; vdx < 3; vdx++)
                        {
                            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                        }
                        rowCount++;
                    }
                    // Now the side heading for gender
                    tenseDesc = [[NSString alloc] initWithFormat:@"     %@:", [genderNames objectAtIndex:gdx]];
                    for( vdx = 0; vdx < 3; vdx++)
                    {
                        [textDetails setValue:tenseDesc forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                        [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                        [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                    }
                    rowCount++;
                    for( cdx = 0; cdx < 5; cdx++)
                    {
                        for( vdx = 0; vdx < 3; vdx++)
                        {
                            // gender x 100000 + case x 10000 + voice x 1000 + mood (always ptcpl = 600) + tense x 10 + 7 (singular) or 8 (plural)
                            entryCode = (gdx + 1) * 100000 + ( cdx + 1 ) * 10000 + (vdx + 1) * 1000 + (tenseCount + 1) * 10 + 607;
                            calcCellStatus = 0;
                            tenseDesc = [[NSString alloc] initWithFormat: @"         %@", [caseNames objectAtIndex:cdx]];
                            [textDetails setValue:tenseDesc forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10]];
                            currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld", entryCode]];
                            if (currentDetails != nil)
                            {
                                [currentDetails setProcessClass:processesForData];
                                [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                                if ( [currentDetails isInNt]) calcCellStatus = 1;
                                if ( [currentDetails isInLXX] ) calcCellStatus += 2;
                                [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                                [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                            }
                            else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 1]];
                            calcCellStatus = 0;
                            currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld", entryCode + 1]];
                            if (currentDetails != nil)
                            {
                                [currentDetails setProcessClass:processesForData];
                                [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                                if ( [currentDetails isInNt]) calcCellStatus = 1;
                                if ( [currentDetails isInLXX] ) calcCellStatus += 2;
                                [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                                [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                            }
                            else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",vdx * 10000 + rowCount * 10 + 2]];
                        }  // end vdx loop
                        rowCount++;
                    }  // end cdx loop
                } // end gdx loop
            }  // else for if not participles - i.e. _is_ participles
        }  // if tense check button
        tenseCount++;
    }  // tense check button loop
    // Now we have all the info, lets set up the display
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

     generalUsage = [[frmUsage alloc] initWithWindowNibName:@"frmUsage"];
     generalUsage.isVerb = true;
     generalUsage.grammarName = @"Verb";
     generalUsage.onlyDisplayNT = onlyDisplayNT;
     generalUsage.ntOnlyCode = ntOnlyCode;
     generalUsage.lxxOnlyCode = lxxOnlyCode;
     generalUsage.ntAndLxxCode = ntAndLxxCode;
     [generalUsage initialiseForm:bookNames];
     generalUsage.tableContents = textDetails;
     generalUsage.cellStatus = cellStatus;
     generalUsage.entryReferences = [wordRefs copy];
     [generalUsage displayTable:rowCount];
     [generalUsage showWindow:self];
     [generalUsage setWordItself:[currentEntry rootWord]];
}

-(void) processAdjectives: (classRootData *) currentEntry forWord: (NSString *) selectedEntry andCanBeComparable: (bool) isComparable withTitle: (NSString *) grammTitle
{
    /*=====================================================================================*
     *                                                                                     *
     *                             processAdjectives                                       *
     *                             =================                                       *
     *                                                                                     *
     *  This is used for any grammatical category that declines like nouns but for all     *
     *  genders.  However, adjectives can also be "comparable" (i.e. can have comparative  *
     *  and superlative forms).  The flag, isComparable, is set to true, if this is the    *
     *  case.                                                                              *
     *                                                                                     *
     *  adx  iterates through standard adjectives, comparatives and superlatives           *
     *       (if isComparable is false, it can only take the value 0                       *
     *  cdx  iterates through cases for a given comparable level and gender                *
     *  gdx  iterates through gender                                                       *
     *                                                                                     *
     *=====================================================================================*/
    NSInteger rowCount, adx, cdx, gdx, limit, glimit, gaugment, entryCode, calcCellStatus;
    NSString *tenseDesc;
    NSMutableDictionary *cellStatus, *textDetails, *wordRefs;
    NSDictionary *currentEntryDetails;
    classParsedItem *currentDetails;

    // Initialise the three "arrays"
    textDetails = [[NSMutableDictionary alloc] init];
    cellStatus = [[NSMutableDictionary alloc] init];
    wordRefs = [[NSMutableDictionary alloc] init];
    rowCount = 0;

    currentEntryDetails = [currentEntry getParseList];
    // Loop through the basic adjective, comparatives and superlatives
    if( isComparable) limit = 3;
    else limit = 1;
    glimit = 3;
    gaugment = 1;
    if( [grammTitle compare:@"Personal Pronoun"] == NSOrderedSame)
    {
        if( [[currentEntry rootTransliteration] compare:@"e)gw/"] == NSOrderedSame) glimit = 1;
        if( [[currentEntry rootTransliteration] compare:@"ka)gw/"] == NSOrderedSame) glimit = 1;
        if( [[currentEntry rootTransliteration] compare:@"su/"] == NSOrderedSame) glimit = 1;
    }
    if( glimit == 1) gaugment = 0;
    for( adx = 0; adx < limit; adx++)
    {
        if( rowCount > 0 )
        {
            // Add a blank row
            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%d",0]];
            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%d",1]];
            [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%d",2]];
            rowCount++;
        }
        // First the group title
        tenseDesc = [[NSString alloc] initWithFormat:@"%@", adjectiveNames[adx]];
        [textDetails setValue:tenseDesc forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10]];
        [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
        [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
        rowCount++;
        // Within adjective, comparative, etc. iterate through genders
        for( gdx = 0; gdx < glimit; gdx++)
        {
            if( gdx > 0 )
            {
                // Add a blank row
                [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10]];
                [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
                [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
                rowCount++;
            }
            if( glimit > 1)
            {
                tenseDesc = [[NSString alloc] initWithFormat:@"     %@", genderNames[gdx]];
                [textDetails setValue:tenseDesc forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10]];
                [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
                [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
                rowCount++;
            }
            // Iterate through cases
            for( cdx = 0; cdx < 5; cdx++)
            {
                entryCode = adx * 1000000 + (gdx + gaugment) * 100000 + (cdx + 1) * 10000 + 7;
                calcCellStatus = 0;
                tenseDesc = [[NSString alloc] initWithFormat:@"          %@", caseNames[cdx]];
                [textDetails setValue:[[NSString alloc] initWithString:tenseDesc] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10]];
                currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld", entryCode]];
                if (currentDetails != nil)
                {
                    [currentDetails setProcessClass:processesForData];
                    [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
                    if ( [currentDetails isInNt]) calcCellStatus = 1;
                    if ( [currentDetails isInLXX] ) calcCellStatus += 2;
                    [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
                    [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
                }
                else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 1]];
                calcCellStatus = 0;
                currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%ld", entryCode + 1]];
                if (currentDetails != nil)
                {
                    [currentDetails setProcessClass:processesForData];
                    [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
                    if ( [currentDetails isInNt]) calcCellStatus = 1;
                    if ( [currentDetails isInLXX] ) calcCellStatus += 2;
                    [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
                    [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
                }
                else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%ld",rowCount * 10 + 2]];
                rowCount++;
            }
        }
    }
    // Now we have all the info, lets set up the display
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

    generalUsage = [[frmUsage alloc] initWithWindowNibName:@"frmUsage"];
    generalUsage.isVerb = false;
    generalUsage.grammarName = grammTitle;
    generalUsage.onlyDisplayNT = onlyDisplayNT;
    generalUsage.ntOnlyCode = ntOnlyCode;
    generalUsage.lxxOnlyCode = lxxOnlyCode;
    generalUsage.ntAndLxxCode = ntAndLxxCode;
    [generalUsage initialiseForm:bookNames];
    generalUsage.tableContents = textDetails;
    generalUsage.cellStatus = cellStatus;
    generalUsage.entryReferences = [wordRefs copy];
    [generalUsage displayTable:rowCount];
    [generalUsage showWindow:nil];
    [generalUsage setWordItself:[currentEntry rootWord]];
}

- (void) processSimple: (classRootData *) currentEntry forWord: (NSString *) selectedEntry withTitle: (NSString *) grammTitle
{
    /*=====================================================================================*
     *                                                                                     *
     *                               processSimple                                         *
     *                               =============                                         *
     *                                                                                     *
     *  This is used for any grammatical category that has a single, unvariable form, such *
     *  as adverbs.                                                                        *
     *                                                                                     *
     *=====================================================================================*/

    NSInteger rowCount, calcCellStatus;
    NSDictionary *currentEntryDetails;
    NSMutableDictionary *cellStatus, *textDetails, *wordRefs;
    classParsedItem *currentDetails;

    // Initialise the three "arrays"
    textDetails = [[NSMutableDictionary alloc] init];
    cellStatus = [[NSMutableDictionary alloc] init];
    wordRefs = [[NSMutableDictionary alloc] init];
    rowCount = 0;
    currentEntryDetails = [currentEntry getParseList];
//    entryCode = adx * 1000000 + (gdx + 1) * 100000 + (cdx + 1) * 10000 + 7;
    calcCellStatus = 0;
    [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%d",0]];
    currentDetails = [currentEntryDetails objectForKey:[[NSString alloc] initWithFormat:@"%d", 0]];
    if (currentDetails != nil)
    {
        [currentDetails setProcessClass:processesForData];
        [textDetails setValue:[currentDetails getWords:selectedEntry] forKey:[[NSString alloc] initWithFormat: @"%d",1]];
        if ( [currentDetails isInNt]) calcCellStatus = 1;
        if ( [currentDetails isInLXX] ) calcCellStatus += 2;
        [cellStatus setValue:[[NSString alloc] initWithFormat:@"%ld", calcCellStatus] forKey:[[NSString alloc] initWithFormat: @"%d",1]];
        [wordRefs setValue:[currentDetails referenceList] forKey:[[NSString alloc] initWithFormat: @"%d",1]];
    }
    else [textDetails setValue:@"" forKey:[[NSString alloc] initWithFormat: @"%d",1]];

    generalUsage = [[frmUsage alloc] initWithWindowNibName:@"frmUsage"];
    generalUsage.isVerb = false;
    generalUsage.grammarName = grammTitle;
    generalUsage.onlyDisplayNT = onlyDisplayNT;
    generalUsage.ntOnlyCode = ntOnlyCode;
    generalUsage.lxxOnlyCode = lxxOnlyCode;
    generalUsage.ntAndLxxCode = ntAndLxxCode;
    [generalUsage initialiseForm:bookNames];
    generalUsage.tableContents = textDetails;
    generalUsage.cellStatus = cellStatus;
    generalUsage.entryReferences = [wordRefs copy];
    [generalUsage displayTable:++rowCount];
    [generalUsage showWindow:nil];
    [generalUsage setWordItself:[currentEntry rootWord]];
}

- (IBAction)doOptions:(id)sender
{
    optionsForm = [[frmOptions alloc] initWithWindowNibName:@"frmOptions"];
/*    [optionsForm setOnlyDisplayNT:onlyDisplayNT];
    [optionsForm setNtOnlyCode:ntOnlyCode];
    [optionsForm setLxxOnlyCode:lxxOnlyCode];
    [optionsForm setNtAndLxxCode:ntAndLxxCode];
    [optionsForm adjustForm]; */
//    [optionsForm showWindow:self];
    [optionsForm window];
    [[[optionsForm window] windowController] setOnlyDisplayNT:onlyDisplayNT];
    [[[optionsForm window] windowController] setNtOnlyCode:ntOnlyCode];
    [[[optionsForm window] windowController] setLxxOnlyCode:lxxOnlyCode];
    [[[optionsForm window] windowController] setNtAndLxxCode:ntAndLxxCode];
    [[[optionsForm window] windowController] adjustForm];
    [NSApp runModalForWindow:[optionsForm optionWindow]];
    [self saveStoredData];
}

- (IBAction)doAbout:(id)sender
{
    aboutForm = [[frmAbout alloc] initWithWindowNibName:@"frmAbout"];
    [aboutForm showWindow:self];
} 

- (IBAction)doHelp:(id)sender
{
    helpForm = [[frmHelp alloc] initWithWindowNibName:@"frmHelp"];
    [helpForm showWindow:nil];
}

#pragma mark - Table View Data Source

-    (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView
{
    return self.wordListContents.count;
}

-    (id) tableView:(NSTableView *)tableView objectValueForTableColumn: (NSTableColumn *)tableColumn
                row:(NSInteger)row
{
    if( [tableColumn.identifier isEqualToString: @"word_list"] )
    {
        return [self.wordListContents objectAtIndex: row];
    }
    else
    {
        return nil;
    }
}

- (IBAction)participlesOrOtherMoods:(id)sender
{
    // No action - implemented to enable radio buttons to function properly
}

- (IBAction) doClose:(id)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end

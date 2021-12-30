/*================================================================================*
 *                                                                                *
 *                            NTWordUse: AppDelegate.h                            *
 *                            ========================                            *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classRootData.h"
#import "classBooks.h"
#import "classChapter.h"
#import "classVerse.h"
#import "classProcesses.h"
#import "classReference.h"
#import "frmUsage.h"
#import "frmOptions.h"
#import "frmAbout.h"
#import "frmHelp.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (retain) IBOutlet NSWindow *mainWindow;
@property (retain) frmUsage *generalUsage;
@property (retain) frmOptions *optionsForm;
@property (retain) frmAbout *aboutForm;
@property (retain) frmHelp *helpForm;

// NSBox elements of the main form
@property (retain) IBOutlet NSBox *gbCategory;
@property (retain) IBOutlet NSBox *gbTenses;
@property (retain) IBOutlet NSBox *gbMoods;
@property (retain) IBOutlet NSBox *gbKeyboard;
@property (retain) IBOutlet NSBox *pleaseBePatient;
@property (retain) IBOutlet NSView *mainView;
@property (retain) NSMutableArray *tenseChecks;
@property (retain) NSMutableArray *moodChecks;
@property (retain) IBOutlet NSButton *selectTenses;
@property (retain) IBOutlet NSButton *selectMoods;
@property (retain) IBOutlet NSButton *selectNonParticiples;
@property (retain) IBOutlet NSButton *selectParticiples;
@property (retain) IBOutlet NSButton *optionsButton;

// The word "listbox" - i.e. table view - and associated variables
@property (retain) IBOutlet NSTableView *tabViewWordList;
@property (strong) NSMutableArray *wordListContents;
@property (retain) NSArray *originalWordList;

// The text field that contains the current virtual keyboard entry
@property (retain) IBOutlet NSTextField *selectionCriteriaLabel;

@property (retain) IBOutlet NSProgressIndicator *progressBar;
@property (retain) NSRunLoop *mainLoop;
@property (retain) IBOutlet NSTextField *progressInfo;

- (void) doDoubleClick: (id) nid;
// - (IBAction)doAbout:(id)sender;

@end


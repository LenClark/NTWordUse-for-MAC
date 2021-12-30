/*================================================================================*
 *                                                                                *
 *                            NTWordUse: frmUsage.h                               *
 *                            =====================                               *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "frmReferences.h"

NS_ASSUME_NONNULL_BEGIN

@interface frmUsage : NSWindowController <NSTabViewDelegate>

@property (retain) NSDictionary *bookList;

@property (retain) IBOutlet NSWindow *usageWindow;
@property (retain) frmReferences *referenceForm;
@property (retain) IBOutlet NSTabView *mainTabView;
@property (retain) IBOutlet NSTabViewItem *activeTab;
@property (retain) IBOutlet NSTabViewItem *middleTab;
@property (retain) IBOutlet NSTabViewItem *passiveTab;
@property (retain) IBOutlet NSView *activeTabView;
@property (retain) IBOutlet NSView *middleTabView;
@property (retain) IBOutlet NSView *passiveTabView;
@property (retain) IBOutlet NSButton *btnSingular;
@property (retain) IBOutlet NSButton *btnPlural;
@property (nonatomic,retain) IBOutlet NSTableView *activeTable;
@property (nonatomic,retain) IBOutlet NSTableView *middleTable;
@property (nonatomic,retain) IBOutlet NSTableView *passiveTable;
@property (retain) NSMutableArray *actualColDesc1;
@property (retain) NSMutableArray *actualColSing1;
@property (retain) NSMutableArray *actualColPlur1;
@property (retain) NSMutableArray *actualColDesc2;
@property (retain) NSMutableArray *actualColSing2;
@property (retain) NSMutableArray *actualColPlur2;
@property (retain) NSMutableArray *actualColDesc3;
@property (retain) NSMutableArray *actualColSing3;
@property (retain) NSMutableArray *actualColPlur3;
@property (retain) IBOutlet NSTableColumn *column1;
@property (retain) IBOutlet NSView *pnlKey;
@property (nonatomic) bool isVerb;
@property (nonatomic) bool onlyDisplayNT;
@property (nonatomic) NSInteger ntOnlyCode;
@property (nonatomic) NSInteger lxxOnlyCode;
@property (nonatomic) NSInteger ntAndLxxCode;
@property (retain) NSDictionary *tableContents;
@property (retain) NSDictionary *cellStatus;
@property (retain) NSDictionary *entryReferences;
@property (retain) NSString *grammarName;

- (void) initialiseForm: (NSDictionary *) books;
- (void) displayTable: (NSInteger) noOfRows;
- (void) setWordItself: (NSString *) wordChosen;
- (void)doubleClick:(id)nid;

@end

NS_ASSUME_NONNULL_END

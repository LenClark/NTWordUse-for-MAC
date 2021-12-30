/*================================================================================*
 *                                                                                *
 *                           NTWordUse: frmReferences.h                           *
 *                           ==========================                           *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classReference.h"
#import "classBooks.h"
#import "classRefBook.h"
#import "classRefChapter.h"
#import "frmDisplay.h"

NS_ASSUME_NONNULL_BEGIN

@interface frmReferences : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (retain) frmDisplay *displayForm;
@property (retain) NSWindow *callingForm;
@property (retain) IBOutlet NSWindow *referenceWindow;
@property (retain) IBOutlet NSTableView *tabViewReferences;
@property (strong) NSMutableArray *refBooks;
@property (strong) NSMutableArray *refChapters;
@property (strong) NSMutableArray *refReferences;
@property (retain) NSString *currentWord;
@property (retain) NSDictionary *referenceList;
@property (retain) NSDictionary *bookList;
@property (retain) NSMutableDictionary *bookReferenceList;

- (void) populateTable;

@end

NS_ASSUME_NONNULL_END

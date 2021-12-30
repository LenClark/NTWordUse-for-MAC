/*================================================================================*
 *                                                                                *
 *                            NTWordUse: frmDisplay.h                             *
 *                            =======================                             *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>
#import "classBooks.h"
#import "classChapter.h"
#import "classVerse.h"

NS_ASSUME_NONNULL_BEGIN

@interface frmDisplay : NSWindowController <NSTextViewDelegate>

@property (retain) IBOutlet NSWindow *displayWindow;
@property (retain) NSWindow *callingWindow;
@property (retain) NSWindow *priorWindow;
@property (retain) NSDictionary *bookList;
@property (retain) IBOutlet NSTextView *theChapter;

- (void) displayChapter: (NSString *) chapterRef ofBook: (NSString *) bookName withHighlightedVerses: (NSArray *) arrayOfVerses;

@end

NS_ASSUME_NONNULL_END

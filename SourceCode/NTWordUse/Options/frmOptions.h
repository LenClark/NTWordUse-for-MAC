/*================================================================================*
 *                                                                                *
 *                            NTWordUse: frmOptions.h                             *
 *                            =======================                             *
 *                                                                                *
 *  Created by Leonard Clark on 26/12/2021.                                       *
 *                                                                                *
 *================================================================================*/

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface frmOptions : NSWindowController

@property (retain) IBOutlet NSWindow *optionWindow;
@property (retain) IBOutlet NSButton *cbLXX;
@property (retain) IBOutlet NSButton *rbtnNTRed;
@property (retain) IBOutlet NSButton *rbtnNTBold;
@property (retain) IBOutlet NSButton *rbtnNTBoth;
@property (retain) IBOutlet NSButton *rbtnLXXGrey;
@property (retain) IBOutlet NSButton *rbtnLXXItalic;
@property (retain) IBOutlet NSButton *rbtnLXXBoth;
@property (retain) IBOutlet NSButton *rbtnBothOrange;
@property (retain) IBOutlet NSButton *rbtnBothNormal;

@property (nonatomic) bool onlyDisplayNT;
@property (nonatomic) NSInteger ntOnlyCode;
@property (nonatomic) NSInteger lxxOnlyCode;
@property (nonatomic) NSInteger ntAndLxxCode;

- (void) adjustForm;

@end

NS_ASSUME_NONNULL_END

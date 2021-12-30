/*=====================================================================================================*
 *                                                                                                     *
 *                                       NTWordUse: frmOptions.m                                       *
 *                                       =======================                                       *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "frmOptions.h"

@interface frmOptions ()

@end

@implementation frmOptions

@synthesize optionWindow;
@synthesize onlyDisplayNT;
@synthesize ntOnlyCode;
@synthesize lxxOnlyCode;
@synthesize ntAndLxxCode;
@synthesize cbLXX;
@synthesize rbtnNTRed;
@synthesize rbtnNTBold;
@synthesize rbtnNTBoth;
@synthesize rbtnLXXGrey;
@synthesize rbtnLXXItalic;
@synthesize rbtnLXXBoth;
@synthesize rbtnBothOrange;
@synthesize rbtnBothNormal;

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification
{
}

- (void) adjustForm
{
    if( onlyDisplayNT) [cbLXX setState:NSControlStateValueOff];
    else [cbLXX setState:NSControlStateValueOn];
    switch (ntOnlyCode)
    {
        case 1:
            [rbtnNTRed setState:NSControlStateValueOn];
            [rbtnNTBold setState:NSControlStateValueOff];
            [rbtnNTBoth setState:NSControlStateValueOff]; break;
        case 2:
            [rbtnNTRed setState:NSControlStateValueOff];
            [rbtnNTBold setState:NSControlStateValueOn];
            [rbtnNTBoth setState:NSControlStateValueOff]; break;
        case 3:
            [rbtnNTRed setState:NSControlStateValueOff];
            [rbtnNTBold setState:NSControlStateValueOff];
            [rbtnNTBoth setState:NSControlStateValueOn]; break;
        default: break;
    }
    switch (lxxOnlyCode)
    {
        case 1: [rbtnLXXGrey setState:NSControlStateValueOn]; break;
        case 2: [rbtnLXXItalic setState:NSControlStateValueOn]; break;
        case 3: [rbtnLXXBoth setState:NSControlStateValueOn]; break;
        default: break;
    }
    switch (ntAndLxxCode)
    {
        case 1: [rbtnBothOrange setState:NSControlStateValueOn]; break;
        case 2: [rbtnBothNormal setState:NSControlStateValueOn]; break;
        default: break;
    }
}

- (IBAction)ntSelectionGroup:(id)sender
{
    
}

- (IBAction)lxxSelectionGroup:(id)sender
{
    
}

- (IBAction)bothSelectionGroup:(id)sender
{
    
}

- (IBAction)doCancel:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
    [self close];
}

- (IBAction)doClose:(id)sender
{
    onlyDisplayNT = ([cbLXX state] == NSControlStateValueOff);
    if( [rbtnNTRed state] == NSControlStateValueOn) ntOnlyCode = 1;
    if( [rbtnNTBold state] == NSControlStateValueOn) ntOnlyCode = 2;
    if( [rbtnNTBoth state] == NSControlStateValueOn) ntOnlyCode = 3;
    if( [rbtnLXXGrey state] == NSControlStateValueOn) lxxOnlyCode = 1;
    if( [rbtnLXXItalic state] == NSControlStateValueOn) lxxOnlyCode = 2;
    if( [rbtnLXXBoth state] == NSControlStateValueOn) lxxOnlyCode = 3;
    if( [rbtnBothOrange state] == NSControlStateValueOn) ntAndLxxCode = 1;
    if( [rbtnBothNormal state] == NSControlStateValueOn) ntAndLxxCode = 2;
    [NSApp stopModal];
    [self close];
}

@end

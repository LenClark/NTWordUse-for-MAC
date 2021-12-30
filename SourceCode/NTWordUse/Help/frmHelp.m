//
//  frmHelp.m
//  NTWordUse
//
//  Created by Leonard Clark on 27/12/2021.
//

#import "frmHelp.h"

@interface frmHelp ()

@end

@implementation frmHelp

@synthesize helpWindow;
@synthesize webView;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSString *helpFileName;
    NSURL *helpFile;
    NSURLRequest *newRequest;

    helpFileName = [[NSBundle mainBundle] pathForResource:@"Help" ofType:@"html"];
    helpFile = [NSURL fileURLWithPath: helpFileName];
    newRequest = [[NSURLRequest alloc] initWithURL:helpFile];
    [webView loadRequest:newRequest];
}

- (IBAction)doCloseWindow:(id)sender
{
    [helpWindow close];
}

@end

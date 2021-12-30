//
//  frmHelp.h
//  NTWordUse
//
//  Created by Leonard Clark on 27/12/2021.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface frmHelp : NSWindowController

@property (retain)IBOutlet NSWindow *helpWindow;
@property (retain) IBOutlet WKWebView *webView;

- (IBAction)doCloseWindow:(id)sender;

@end

NS_ASSUME_NONNULL_END

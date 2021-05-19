//
//  AppDelegate.h
//  Ttest
//
//  Created by Nicolas Georget on 9/25/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *displayLog;

- (IBAction)disconnect:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)list:(id)sender;


@end

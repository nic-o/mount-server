//
//  AppDelegate.m
//  Ttest
//
//  Created by Nicolas Georget on 9/25/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import "AppDelegate.h"
#import "HandleServer.h"

@implementation AppDelegate

@synthesize displayLog;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)disconnect:(id)sender {
    HandleServer *thisServer = [[HandleServer alloc] init];
    
//    [thisServer unmountServer:@"/Volumes/Phototheque"];
    NSArray *servers = [[NSArray alloc] initWithObjects:@"/Volumes/Phototheque",
                                                        @"/Volumes/Layout", nil];
    
    [thisServer unmountServers:servers];
}

- (IBAction)connect:(id)sender {
    
    HandleServer *thisServer = [[HandleServer alloc] init];
    
    NSDictionary *mountDictionary;
    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"layout-macdata", @"kServerNameKey",
                       @"Phototheque", @"kVolumeNameKey",
                       @"smb", @"kTransportNameKey",
                       @"", @"kMountDirectoryKey",
                       @"Layout", @"kUserNameKey",
                       @"layout", @"kPasswordKey",
                       [NSNumber numberWithBool:YES],
                       @"kAsyncKey", NULL];
    
//    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                       @"layout-server.local", @"kServerNameKey",
//                       @"Phototheque", @"kVolumeNameKey",
//                       @"afp", @"kTransportNameKey",
//                       @"", @"kMountDirectoryKey",
//                       @"nico", @"kUserNameKey",
//                       @"wny7a7c7", @"kPasswordKey",
//                       [NSNumber numberWithBool:YES],
//                       @"kAsyncKey", NULL];
    
//    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                       @"layout.sophieparis.com", @"kServerNameKey",
//                       @"Phototheque", @"kVolumeNameKey",
//                       @"afp", @"kTransportNameKey",
//                       @"", @"kMountDirectoryKey",
//                       nil, @"kUserNameKey",
//                       nil, @"kPasswordKey",
//                       [NSNumber numberWithBool:YES],
//                       @"kAsyncKey", NULL];
    
    [thisServer mountServer:mountDictionary];
    [displayLog setStringValue:@"Phototheque High-Resolution mounted"];
}

- (IBAction)list:(id)sender {
    
    NSArray *volumeURLs = [HandleServer listMountedVolume];

    
    
    NSLog(@"%@", volumeURLs);
    [displayLog setStringValue:[volumeURLs componentsJoinedByString:@"\n"]];
    
    
//    NSURL *path;
//    for (path in volumeURLs)
//    NSLog(@"%@", [volumeURLs objectAtIndex:4]);
    
//    NSString *toto = [volumeURLs objectAtIndex:4];
//    NSURL *path =[NSURL URLWithString:toto];
//    NSLog(@"%@", [path pathComponents]);
//    NSLog(@"%@", [[[volumeURLs objectAtIndex:4] pathComponents] objectAtIndex:2]);
    
//    for (NSURL *path in volumeURLs)
////        NSLog(@"%@", [[[volumeURLs objectAtIndex:4] pathComponents] objectAtIndex:2]);
//        NSLog(@"%@", [path absoluteURL]);
    
//    NSLog(@"%@", [self volumeMountPathFromPath:@"/Volumes/Phototheque"]);

    
}


@end

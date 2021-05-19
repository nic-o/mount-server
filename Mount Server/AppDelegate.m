//
//  AppDelegate.m
//  Mount Server
//
//  Created by Nicolas Georget on 9/24/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import "AppDelegate.h"
#include <sys/param.h>
#include <sys/mount.h>
#include <NetFS/NetFS.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

NSString *kServerNameKey = @"kServerNameKey";
NSString *kVolumeNameKey = @"kVolumeNameKey";
NSString *kTransportNameKey = @"kTransportNameKey";
NSString *kMountDirectoryKey = @"kMountDirectoryKey";
NSString *kUserNameKey = @"kUserNameKey";
NSString *kPasswordKey = @"kPasswordKey";
NSString *kAsyncKey = @"kAsyncKey";

-(void)mountServer:(NSDictionary *)mountDictionary {
    
    NSString *pathOfVolumeToMount;
    
#define kNoPasswordInURL 1
    
#if kNoPasswordInURL
    // encode transportName://serverName/volumeName URL for server, without userName/password
    pathOfVolumeToMount = [NSString stringWithFormat:@"%@://%@/%@",
                           [mountDictionary objectForKey:kTransportNameKey],
                           [mountDictionary objectForKey:kServerNameKey],
                           [mountDictionary objectForKey:kVolumeNameKey]];
#else
    // It's possible to encode the userName/password into the URL, but this is undesirable when trying to
    // mount a volume quietly, without an authentication dialog appearing. Instead, pass userName/password
    // directly to FSMountServerVolumeSync (see comments below).
    // encode transportName://userName:<password...>/volumeName URL for server, with userName/password
    *pathOfVolumeToMount = [NSString stringWithFormat:@"%@://%@:%@@%@/%@",
                            [mountDictionary objectForKey:kTransportNameKey],
                            [mountDictionary objectForKey:kUserNameKey],
                            [mountDictionary objectForKey:kPasswordKey],
                            [mountDictionary objectForKey:kServerNameKey],
                            [mountDictionary objectForKey:kVolumeNameKey]];
#endif // kNoPasswordInURL
    
    // percent-ascape any space characters in the URL string and create URL
    pathOfVolumeToMount = [pathOfVolumeToMount stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlOfVolumeToMount = [NSURL URLWithString:pathOfVolumeToMount];
    
    // create NSURL for optional directory on server to mount; can also
    // just include the subdirectory in server URL (if that path is share-able).
    NSURL *mountDirectoryURL = NULL;
    NSString *mountDirectoryPath = [mountDictionary objectForKey:kMountDirectoryKey];
    if ( ![mountDirectoryPath isEqualToString:@""] ) {
        mountDirectoryPath = [NSString stringWithFormat:@"/Volumes/%@/%@", [mountDictionary objectForKey:kVolumeNameKey], mountDirectoryPath];
        mountDirectoryPath = [mountDirectoryPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        mountDirectoryURL = [NSURL URLWithString:mountDirectoryPath];
    }
    
    // To mount a volume quietly, without an authentication dialog, it's necessary
    // that FSMountServerVolumeSync's userName and password params *not* be NULL.
    // While it -is- possible to pass NULL for these (by encoding them into
    // the URL, see above), if the server doesn't exist, passing NULL for these params
    // causes the system to put up a "server is not available or may not be operational"
    // dialog even though the values are already encoded into the URL.
    
    // Solution: pass userName and password directly to FSMountServerVolumeSync,
    // and leave them out of the URL. This will mount the volume if it's possible,
    // and if not, will quietly return an error. No authentication dialog will appear.
    OSStatus error;
//    FSVolumeRefNum refNum;

//                                    );
//    error = FSMountServerVolumeSync(
//                                    <#CFURLRef url#>,
//                                    <#CFURLRef mountDir#>,
//                                    <#CFStringRef user#>,
//                                    <#CFStringRef password#>,
//                                    <#FSVolumeRefNum *mountedVolumeRefNum#>,
//                                    <#OptionBits flags#>);
//    
//    error = NetFSMountURLAsync(
//                               <#CFURLRef url#>,
//                               <#CFURLRef mountpath#>,
//                               <#CFStringRef user#>,
//                               <#CFStringRef passwd#>,
//                               <#CFMutableDictionaryRef open_options#>,
//                               <#CFMutableDictionaryRef mount_options#>,
//                               AsyncRequestID *requestID,
//                               <#dispatch_queue_t dispatchq#>,<#^(int status, AsyncRequestID requestID, CFArrayRef mountpoints)mount_report#>);
//
    
//    error = FSMountServerVolumeSync((__bridge CFURLRef)urlOfVolumeToMount,
//                                    (__bridge CFURLRef)mountDirectoryURL, // if NULL, default location is mounted.
//                                    (__bridge CFStringRef)[mountDictionary objectForKey:kUserNameKey],
//                                    (__bridge CFStringRef)[mountDictionary objectForKey:kPasswordKey],
//                                    &refNum,
//                                    0L /* OptionBits, currently unused */
//                                    );
    
//    error = NetFSMountURLAsync(
//                               (__bridge CFURLRef)urlOfVolumeToMount,
//                               (__bridge CFURLRef)mountDirectoryURL, // if NULL, default location is mounted.
//                               (__bridge CFStringRef)[mountDictionary objectForKey:kUserNameKey],
//                               (__bridge CFStringRef)[mountDictionary objectForKey:kPasswordKey],
//                               nil,
//                               nil,
//                               nil,
//                               nil,
//                               nil);

    CFArrayRef *mountpoints = NULL;
    error = NetFSMountURLSync(
                              (__bridge CFURLRef)urlOfVolumeToMount,
                              (__bridge CFURLRef)mountDirectoryURL, // if NULL, default location is mounted.
                              (__bridge CFStringRef)[mountDictionary objectForKey:kUserNameKey],
                              (__bridge CFStringRef)[mountDictionary objectForKey:kPasswordKey],
                              NULL,
                              NULL,
                              mountpoints);
    
//    if ( !error ) {
//        NSLog( @"Sync-mounted server %@, user == %@, refNum == %d",
//              [pathOfVolumeToMount stringByAppendingPathComponent:mountDirectoryPath],
//              [mountDictionary objectForKey:kUserNameKey],
//              refNum );
//        
//        // Experiment: see if -noteFileSystemChanged: has any effect on the occasional idisk
//        // which mounts successfully but which is not visible in Finder window sidebars and,
//        // sometimes, not even on the Desktop. (noticed with  under Tiger)
//        [[NSWorkspace sharedWorkspace] noteFileSystemChanged:[pathOfVolumeToMount stringByAppendingPathComponent:mountDirectoryPath]];
//    } else {
//        NSLog( @"Sync mount failed for server %@, error == %d",
//              pathOfVolumeToMount, error );
//    }
    
}

-(void)mountServers:(NSArray *)array {
    if ( array == NULL ) return;
    
    NSUInteger i, count = [array count];
    for (i = 0; i < count; i++) {
        NSDictionary *thisServer = [array objectAtIndex:i];
        [self mountServer:thisServer];
    }
}

- (IBAction)mountSomeServers:(id)sender {
    
    NSMutableArray *mountArray = [NSMutableArray array];
    NSDictionary *mountDictionary;
    
    // mount a file-shared volume on machine "MBPLeopard"
    //    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    //                       @"10.1.0.1", kServerNameKey,
    //                       @"Phototheque", kVolumeNameKey,
    //                       @"afp", kTransportNameKey,
    //                       @"", kMountDirectoryKey,
    //                       @"nico", kUserNameKey,
    //                       @"wny7a7c7", kPasswordKey,
    //                       [NSNumber numberWithBool:YES],
    //                       kAsyncKey, NULL];
    //    [mountArray addObject:mountDictionary];
    
    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"layout-macdata", kServerNameKey,
                       @"Phototheque", kVolumeNameKey,
                       @"smb", kTransportNameKey,
                       @"", kMountDirectoryKey,
                       @"Layout", kUserNameKey,
                       @"layout", kPasswordKey,
                       [NSNumber numberWithBool:YES],
                       kAsyncKey, NULL];
    [mountArray addObject:mountDictionary];
    
    //    // also mount user's home directory on the same server
    //    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    //                       @"MBPLeopar.local", kServerNameKey,
    //                       @"username", kVolumeNameKey, // home directory
    //                       @"afp", kTransportNameKey,
    //                       @"", kMountDirectoryKey,
    //                       @"username", kUserNameKey,
    //                       @"password", kPasswordKey,
    //                       [NSNumber numberWithBool:YES], kAsyncKey, NULL];
    //    [mountArray addObject:mountDictionary];
    //
    //    // an idisk
    //    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    //                       @"idisk.mac.com", kServerNameKey,
    //                       @"youriDisk-Public", kVolumeNameKey,
    //                       @"http", kTransportNameKey,
    //                       @"", kMountDirectoryKey,
    //                       @"username", kUserNameKey,
    //                       @"", kPasswordKey,  // assumes no password sort on idisk public folder
    //                       [NSNumber numberWithBool:YES], kAsyncKey, NULL];
    //    [mountArray addObject:mountDictionary];
    //
    //    // a subdirectory on the same idisk, without bothering
    //    //with the kMountDirectoryKey key
    //    mountDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    //                       @"idisk.mac.com", kServerNameKey,
    //                       @"youriDisk-Public/SomeExistentFolder", kVolumeNameKey,
    //                       @"http", kTransportNameKey,
    //                       @"", kMountDirectoryKey,
    //                       @"username", kUserNameKey,
    //                       @"", kPasswordKey,
    //                       [NSNumber numberWithBool:YES], kAsyncKey, NULL];
    //    [mountArray addObject:mountDictionary];
    
    // mount servers in array
    [self mountServers:mountArray];
    
}

- (IBAction)unmountServer:(id)sender {
    unmount("/Volumes/Phototheque",0);
//    BOOL result;
//    result = [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:@"/Volumes/Shared"];
//    NSLog(@"Umount volume: %c", result);
}

@end

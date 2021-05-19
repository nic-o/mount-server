//
//  HandleServer.m
//  Ttest
//
//  Created by Nicolas Georget on 9/25/12.
//  Copyright (c) 2012 Nicolas Georget. All rights reserved.
//

#import "HandleServer.h"

// For the command unmount() used in unmountServer()
#include <sys/param.h>
#include <sys/mount.h>

@implementation HandleServer

-(id)init {
    self = [super init];
    if (self) {
        kServerNameKey = @"kServerNameKey";
        kVolumeNameKey = @"kVolumeNameKey";
        kTransportNameKey = @"kTransportNameKey";
        kMountDirectoryKey = @"kMountDirectoryKey";
        kUserNameKey = @"kUserNameKey";
        kPasswordKey = @"kPasswordKey";
        kAsyncKey = @"kAsyncKey";
    }
    return self;
}

-(void)mountServer:(NSDictionary *)mountDictionary {
    
    NSString *pathOfVolumeToMount;
    
    #define kNoPasswordInURL 1
    
    #if kNoPasswordInURL
    // encode transportName://serverName/volumeName URL for server, without
    // userName/password
        pathOfVolumeToMount = [NSString stringWithFormat:@"%@://%@/%@",
                           [mountDictionary objectForKey:kTransportNameKey],
                           [mountDictionary objectForKey:kServerNameKey],
                           [mountDictionary objectForKey:kVolumeNameKey]];
    #else
    // It's possible to encode the userName/password into the URL, but this is
    // undesirable when trying to mount a volume quietly, without an
    // authentication dialog appearing. Instead, pass userName/password directly
    // to FSMountServerVolumeSync (see comments below).
    // encode transportName://userName:<password...>/volumeName URL for server,
    // with userName/password
        pathOfVolumeToMount = [NSString stringWithFormat:@"%@://%@:%@@%@/%@",
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
    FSVolumeRefNum refNum;
    
    error = FSMountServerVolumeSync((__bridge CFURLRef)urlOfVolumeToMount,
                                    (__bridge CFURLRef)mountDirectoryURL, // if NULL, default location is mounted.
                                    (__bridge CFStringRef)[mountDictionary objectForKey:kUserNameKey],
                                    (__bridge CFStringRef)[mountDictionary objectForKey:kPasswordKey],
                                    &refNum,
                                    0L /* OptionBits, currently unused */
                                    );
    if (!error) {
        NSLog( @"Sync-mounted server %@, user == %@, refNum == %d",
              [pathOfVolumeToMount stringByAppendingPathComponent:mountDirectoryPath],
              [mountDictionary objectForKey:kUserNameKey],
              refNum );
        
        // Experiment: see if -noteFileSystemChanged: has any effect on the occasional idisk
        // which mounts successfully but which is not visible in Finder window sidebars and,
        // sometimes, not even on the Desktop. (noticed with  under Tiger)
        [[NSWorkspace sharedWorkspace] noteFileSystemChanged:[pathOfVolumeToMount stringByAppendingPathComponent:mountDirectoryPath]];
    } else {
        NSLog( @"Sync mount failed for server %@, error == %d",
              pathOfVolumeToMount, error );
    }
    
}

-(void)mountServers:(NSArray *)array {
    if ( array == NULL ) return;
    
    NSUInteger i, count = [array count];
    for (i = 0; i < count; i++) {
        NSDictionary *thisServer = [array objectAtIndex:i];
        [self mountServer:thisServer];
    }
}

-(void)unmountServer:(NSString *)path {
    
    // First way (it works)
    const char *thisServer = [path UTF8String];
    int result;
    result = unmount(thisServer,0);
    NSLog(@"Unmount \"%@\": %i", path, result);
    
    // Second way
//    BOOL result;
//    result = [[NSWorkspace sharedWorkspace] unmountAndEjectDeviceAtPath:path];
//    NSLog(@"Umount \"%@\" successfully: %@", path, result ? @"YES" : @"NO");
}

-(void)unmountServers:(NSArray *)array {
    if ( array == NULL ) return;
    
    NSUInteger i, count = [array count];
    for (i = 0; i < count; i++) {
        NSString *thisServer = [array objectAtIndex:i];
        [self unmountServer:thisServer];
    }
    
}

+(id)listMountedVolume {
    NSArray *resourceKeys = [NSArray arrayWithObjects:
                             NSURLLocalizedNameKey, NSURLEffectiveIconKey, nil];
    
    // volumeURLs contains NSURL objects (not NSString)
    //    NSLog((@"Class Name: %@", [[volumeURLs objectAtIndex:4] className]));
    NSArray *volumeURLs = [[NSFileManager defaultManager]
                           mountedVolumeURLsIncludingResourceValuesForKeys:resourceKeys
                           options:0];
    
    return volumeURLs;
}


//- (NSURL *)volumeMountPathFromPath:(NSString *)path {
//    NSString *mountPath = nil;
//    NSString *testPath = [path copy];
//    while(![testPath isEqualToString:@"/"]){
//        NSURL *testUrl = [NSURL fileURLWithPath:testPath];
//        NSNumber *isVolumeKey;
//        [testUrl getResourceValue:&isVolumeKey forKey:NSURLIsVolumeKey error:nil];
//        if([isVolumeKey boolValue]){
//            mountPath = testPath;
//            break;
//        }
//        testPath = [testPath stringByDeletingLastPathComponent];
//    }
//    
//    if(mountPath == nil){
//        return nil;
//    }
//    
//    NSString *pathCompointents = [path substringFromIndex:[mountPath length]];
//    
//    FSRef pathRef;
//    FSPathMakeRef((UInt8*)[path fileSystemRepresentation], &pathRef, NULL);
//    FSCatalogInfo catalogInfo;
//    OSErr osErr = FSGetCatalogInfo(&pathRef, kFSCatInfoVolume|kFSCatInfoParentDirID,
//                                   &catalogInfo, NULL, NULL, NULL);
//    FSVolumeRefNum volumeRefNum = 0;
//    if(osErr == noErr){
//        volumeRefNum = catalogInfo.volume;
//    }
//    
//    CFURLRef serverLocation;
//    OSStatus result = FSCopyURLForVolume(volumeRefNum, &serverLocation);
//    if(result == noErr){
//        NSString *fullUrl = [NSString stringWithFormat:@"%@%@",
//                             CFURLGetString(serverLocation), pathCompointents];
//        return [NSURL URLWithString:fullUrl];
//    }else{
//        NSLog(@"Error getting the mount path: %i", result);
//    }
//    return nil;
//}

@end

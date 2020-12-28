//
//  SUSServerPlaylistLoader.m
//  iSub
//
//  Created by Benjamin Baron on 11/6/11.
//  Copyright (c) 2011 Ben Baron. All rights reserved.
//

#import "SUSServerPlaylistsLoader.h"
#import "SUSServerPlaylist.h"
#import "NSMutableURLRequest+SUS.h"
#import "RXMLElement.h"
#import "NSError+ISMSError.h"

@implementation SUSServerPlaylistsLoader

- (SUSLoaderType)type
{
    return SUSLoaderType_ServerPlaylist;
}

- (NSURLRequest *)createRequest {
    return [NSMutableURLRequest requestWithSUSAction:@"getPlaylists" parameters:nil];
}

- (void)processResponse {
    RXMLElement *root = [[RXMLElement alloc] initFromXMLData:self.receivedData];
    if (!root.isValid) {
        NSError *error = [NSError errorWithISMSCode:ISMSErrorCode_NotXML];
        [self informDelegateLoadingFailed:error];
    } else {
        RXMLElement *error = [root child:@"error"];
        if (error.isValid) {
            [self informDelegateLoadingFailed:[NSError errorWithSubsonicXMLResponse:error]];
        } else {
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            [root iterate:@"playlists.playlist" usingBlock:^(RXMLElement *e) {
                SUSServerPlaylist *serverPlaylist = [[SUSServerPlaylist alloc] initWithRXMLElement:e];
                [tempArray addObject:serverPlaylist];
            }];
        
            // Sort the array
            self.serverPlaylists = [tempArray sortedArrayUsingSelector:@selector(compare:)];
                        
            // Notify the delegate that the loading is finished
            [self informDelegateLoadingFinished];
        }
    }
}

@end

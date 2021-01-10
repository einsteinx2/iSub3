//
//  iSubBassGaplessPlayerDelegate.m
//  iSub
//
//  Created by Ben Baron on 9/8/12.
//  Copyright (c) 2012 Ben Baron. All rights reserved.
//

#import "iSubBassGaplessPlayerDelegate.h"
#import "BassGaplessPlayer.h"
#import "ISMSStreamHandler.h"
#import "MusicSingleton.h"
#import "SocialSingleton.h"
#import "ISMSStreamManager.h"
#import "Defines.h"
#import "EX2Kit.h"
#import "Swift.h"

@implementation iSubBassGaplessPlayerDelegate

- (instancetype)init
{
    if ((self = [super init]))
    {
        [NSNotificationCenter addObserverOnMainThread:self selector:@selector(grabCurrentPlaylistIndex:) name:ISMSNotification_CurrentPlaylistOrderChanged];
        [NSNotificationCenter addObserverOnMainThread:self selector:@selector(grabCurrentPlaylistIndex:) name:ISMSNotification_CurrentPlaylistShuffleToggled];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter removeObserverOnMainThread:self];
}

- (void)grabCurrentPlaylistIndex:(NSNotification *)notification
{
    
}

- (void)bassSeekToPositionStarted:(BassGaplessPlayer*)player
{
    
}

- (void)bassSeekToPositionSuccess:(BassGaplessPlayer*)player
{
    
}

- (void)bassStopped:(BassGaplessPlayer*)player
{
    
}

- (void)bassFirstStreamStarted:(BassGaplessPlayer*)player
{
    [socialS playerClearSocial];
}

- (void)bassSongEndedCalled:(BassGaplessPlayer*)player
{
    // Increment current playlist index
    (void)[PlayQueue.shared incrementIndex];
    
    // Clear the social post status
    [socialS playerClearSocial];
}

- (void)bassFreed:(BassGaplessPlayer *)player
{
    [socialS playerClearSocial];
}

- (NSUInteger)bassIndexAtOffset:(NSInteger)offset fromIndex:(NSUInteger)index player:(BassGaplessPlayer *)player
{
    return [PlayQueue.shared indexWithOffset:offset fromIndex:index];
}

- (ISMSSong *)bassSongForIndex:(NSUInteger)index player:(BassGaplessPlayer *)player
{
    return [PlayQueue.shared songWithIndex:index];
}

- (NSUInteger)bassCurrentPlaylistIndex:(BassGaplessPlayer *)player
{
    return PlayQueue.shared.currentIndex;
}

- (void)bassRetrySongAtIndex:(NSUInteger)index player:(BassGaplessPlayer*)player;
{
    [EX2Dispatch runInMainThreadAsync:^
     {
         [musicS playSongAtPosition:index];
     }];
}

- (void)bassUpdateLockScreenInfo:(BassGaplessPlayer *)player
{
	[musicS updateLockScreenInfo];
}

- (void)bassRetrySongAtOffsetInBytes:(NSUInteger)bytes andSeconds:(NSUInteger)seconds player:(BassGaplessPlayer*)player
{
    [musicS startSongAtOffsetInBytes:bytes andSeconds:seconds];
}

- (void)bassFailedToCreateNextStreamForIndex:(NSUInteger)index player:(BassGaplessPlayer *)player
{
    // The song ended, and we tried to make the next stream but it failed
    ISMSSong *aSong = [PlayQueue.shared songWithIndex:index];
    ISMSStreamHandler *handler = [streamManagerS handlerForSong:aSong];
    if (!handler.isDownloading || handler.isDelegateNotifiedToStartPlayback)
    {
        // If the song isn't downloading, or it is and it already informed the player to play (i.e. the playlist will stop if we don't force a retry), then retry
        [EX2Dispatch runInMainThreadAsync:^
         {
             [musicS playSongAtPosition:index];
         }];
    }
}

- (void)bassRetrievingOutputData:(BassGaplessPlayer *)player
{
    [socialS playerHandleSocial];
}

@end

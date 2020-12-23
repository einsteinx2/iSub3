//
//  SUSTagArtistDAO.m
//  iSub
//
//  Created by Benjamin Baron on 12/22/20.
//  Copyright © 2020 Ben Baron. All rights reserved.
//

#import "SUSTagArtistDAO.h"
#import "SUSTagArtistLoader.h"
#import "MusicSingleton.h"
#import "FMDatabaseQueueAdditions.h"
#import "SavedSettings.h"
#import "PlaylistSingleton.h"
#import "MusicSingleton.h"
#import "DatabaseSingleton.h"
#import "JukeboxSingleton.h"
#import "ISMSSong+DAO.h"
#import "EX2Kit.h"
#import "Swift.h"

LOG_LEVEL_ISUB_DEFAULT

@implementation SUSTagArtistDAO

#pragma mark Lifecycle

- (void)setup {
    _albumStartRow = [self.dbQueue intForQuery:@"SELECT ROWID FROM tagAlbum WHERE artistId = ? LIMIT 1", self.tagArtist.artistId];
    _albumsCount = [self.dbQueue intForQuery:@"SELECT count(*) FROM tagAlbum WHERE artistId = ?", self.tagArtist.artistId];
}

- (instancetype)init {
    NSAssert(NO, @"[SUSTagArtistDAO] init should never be called");
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<SUSLoaderDelegate> *)delegate {
    NSAssert(NO, @"[SUSTagArtistDAO] initWithDelegate should never be called");
    if (self = [super init]) {
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<SUSLoaderDelegate> *)delegate andTagArtist:(ISMSTagArtist *)tagArtist {
    if (self = [super init]) {
        _delegate = delegate;
        _tagArtist = tagArtist;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_loader cancelLoad];
    _loader.delegate = nil;
}

- (FMDatabaseQueue *)dbQueue {
    return databaseS.serverDbQueue;
}

#pragma mark Public DAO Methods

- (BOOL)hasLoaded {
    if (self.albumsCount > 0)
        return YES;
    
    return NO;
}

- (ISMSTagAlbum *)tagAlbumForTableViewRow:(NSUInteger)row {
    NSUInteger dbRow = self.albumStartRow + row;
    __block ISMSTagAlbum *tagAlbum = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM tagAlbum WHERE ROWID = %lu", (unsigned long)dbRow]];
        if ([result next]) {
            tagAlbum = [[ISMSTagAlbum alloc] initWithResult:result];
        } else if (db.hadError) {
            // TODO: Handle error
            DDLogError(@"[SUSTagArtistDAO] Failed to read album for table row - %d: %@", db.lastErrorCode, db.lastErrorMessage);
        }
        [result close];
    }];
    return tagAlbum;
}

#pragma mark Loader Manager Methods

- (void)restartLoad {
    [self startLoad];
}

- (void)startLoad {
    self.loader = [[SUSTagArtistLoader alloc] initWithDelegate:self];
    self.loader.artistId = self.tagArtist.artistId;
    [self.loader startLoad];
}

- (void)cancelLoad {
    [self.loader cancelLoad];
    self.loader.delegate = nil;
    self.loader = nil;
}

#pragma mark Loader Delegate Methods

- (void)loadingFailed:(SUSLoader *)theLoader withError:(NSError *)error {
    self.loader.delegate = nil;
    self.loader = nil;
    
    if ([self.delegate respondsToSelector:@selector(loadingFailed:withError:)]) {
        [self.delegate loadingFailed:nil withError:error];
    }
}

- (void)loadingFinished:(SUSLoader *)theLoader {
    self.loader.delegate = nil;
    self.loader = nil;
    
    [self setup];
    
    if ([self.delegate respondsToSelector:@selector(loadingFinished:)]) {
        [self.delegate loadingFinished:nil];
    }
}

@end
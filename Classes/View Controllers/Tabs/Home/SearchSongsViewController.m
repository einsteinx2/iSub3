//
//  SearchSongsViewController.m
//  iSub
//
//  Created by bbaron on 10/28/10.
//  Copyright 2010 Ben Baron. All rights reserved.
//

#import "SearchSongsViewController.h"
#import "ServerListViewController.h"
#import "FolderAlbumViewController.h"
#import "UIViewController+PushViewControllerCustom.h"
#import "NSMutableURLRequest+SUS.h"
#import "ViewObjectsSingleton.h"
#import "Defines.h"
#import "SavedSettings.h"
#import "MusicSingleton.h"
#import "DatabaseSingleton.h"
#import "JukeboxSingleton.h"
#import "EX2Kit.h"
#import "Swift.h"

LOG_LEVEL_ISUB_DEFAULT

@implementation SearchSongsViewController

#pragma mark View lifecycle

- (instancetype)initWithNibName:(NSString *)n bundle:(NSBundle *)b {
    if (self = [super initWithNibName:n bundle:b]) {
		_offset = 0;
		_isMoreResults = YES;
		_isLoading = NO;
    }
    return self;
}

- (void)viewDidLoad  {
    [super viewDidLoad];
	
	if (musicS.showPlayerIcon) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"music.quarternote.3"] style:UIBarButtonItemStylePlain target:self action:@selector(nowPlayingAction:)];
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
    
    self.tableView.rowHeight = Defines.rowHeight;
    [self.tableView registerClass:UniversalTableViewCell.class forCellReuseIdentifier:UniversalTableViewCell.reuseId];
}
		
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
    if (self.isLoading) {
        [self.dataTask cancel];
        self.dataTask = nil;
    }
}

- (void) settingsAction:(id)sender  {
	ServerListViewController *serverListViewController = [[ServerListViewController alloc] initWithNibName:@"ServerListViewController" bundle:nil];
	serverListViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:serverListViewController animated:YES];
}

- (IBAction)nowPlayingAction:(id)sender {
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    playerViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:playerViewController animated:YES];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.searchType == ISMSSearchSongsSearchType_Artists) {
		return self.folderArtists.count + 1;
	} else if (self.searchType == ISMSSearchSongsSearchType_Albums) {
		return self.folderAlbums.count + 1;
	} else {
		return self.songs.count + 1;
	}
}

- (void)loadMoreResults {
	if (self.isLoading) return;
	
	self.isLoading = YES;
	
	self.offset += 20;
    NSDictionary *parameters = nil;
    NSString *action = nil;
	NSString *offsetString = [NSString stringWithFormat:@"%lu", (unsigned long)self.offset];
	if (settingsS.currentServer.isNewSearchSupported) {
        action = @"search2";
		NSString *queryString = [NSString stringWithFormat:@"%@*", self.query];
		switch (self.searchType) {
			case ISMSSearchSongsSearchType_Artists:
				parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"20", @"artistCount", @"0", @"albumCount", @"0", @"songCount", 
							  n2N(queryString), @"query", n2N(offsetString), @"artistOffset", nil];
				break;
			case ISMSSearchSongsSearchType_Albums:
				parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"artistCount", @"20", @"albumCount", @"0", @"songCount", 
							  n2N(queryString), @"query", n2N(offsetString), @"albumOffset", nil];
				break;
			case ISMSSearchSongsSearchType_Songs:
				parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"artistCount", @"0", @"albumCount", @"20", @"songCount", 
							  n2N(queryString), @"query", n2N(offsetString), @"songOffset", nil];
				break;
			default:
				break;
		}
	} else {
        action = @"search";
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"20", @"count", n2N(self.query), @"any", n2N(offsetString), @"offset", nil];
	}
    
    NSURLRequest *request = [NSMutableURLRequest requestWithSUSAction:action parameters:parameters];
    self.dataTask = [APILoader.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [EX2Dispatch runInMainThreadAsync:^{
                if (settingsS.isPopupsEnabled) {
                    NSString *message = [NSString stringWithFormat:@"There was an error performing the search.\n\nError:%@", error.localizedDescription];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                self.isLoading = NO;
            }];
        } else {
            DDLogVerbose(@"additional search results: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            SearchXMLParser *parser = [[SearchXMLParser alloc] initWithData:data];
            
            if (self.searchType == ISMSSearchSongsSearchType_Artists) {
                if (parser.folderArtists.count == 0) {
                    self.isMoreResults = NO;
                } else {
                    [self.folderArtists addObjectsFromArray:parser.folderArtists];
                }
            } else if (self.searchType == ISMSSearchSongsSearchType_Albums) {
                if (parser.folderAlbums.count == 0) {
                    self.isMoreResults = NO;
                } else {
                    [self.folderAlbums addObjectsFromArray:parser.folderAlbums];
                }
            } else if (self.searchType == ISMSSearchSongsSearchType_Songs) {
                if (parser.songs.count == 0) {
                    self.isMoreResults = NO;
                } else {
                    [self.songs addObjectsFromArray:parser.songs];
                }
            }
            
            // Reload the table
            [EX2Dispatch runInMainThreadAsync:^{
                [self.tableView reloadData];
                self.isLoading = NO;
            }];
        }
    }];
    [self.dataTask resume];
}

- (UITableViewCell *)createLoadingCell:(NSUInteger)row {
	// This is the last cell and there could be more results, load the next 20 results;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoReuse"];
    cell.backgroundColor = [UIColor colorNamed:@"isubBackgroundColor"];
	if (self.isMoreResults) {
		cell.textLabel.text = @"Loading more results...";
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
		CGFloat y = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] / 2.;
		indicator.center = CGPointMake(300, y);
		indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[cell addSubview:indicator];
		[indicator startAnimating];
		
		[self loadMoreResults];
	} else {
		if (self.folderArtists.count > 0 || self.folderAlbums.count > 0 || self.songs.count > 0) {
			cell.textLabel.text = @"No more search results";
		} else {
			cell.textLabel.text = @"No results";
		}
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.searchType == ISMSSearchSongsSearchType_Artists) {
		if (indexPath.row < self.folderArtists.count) {
            // Artist
            UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UniversalTableViewCell.reuseId];
            cell.hideNumberLabel = YES;
            cell.hideCoverArt = YES;
            cell.hideSecondaryLabel = YES;
            cell.hideDurationLabel = YES;
            [cell updateWithModel:[self.folderArtists objectAtIndexSafe:indexPath.row]];
            return cell;
		} else if (indexPath.row == self.folderArtists.count) {
			return [self createLoadingCell:indexPath.row];
		}
	} else if (self.searchType == ISMSSearchSongsSearchType_Albums) {
		if (indexPath.row < self.folderAlbums.count) {
            // Album
            UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UniversalTableViewCell.reuseId];
            cell.hideNumberLabel = YES;
            cell.hideCoverArt = NO;
            cell.hideDurationLabel = YES;
            [cell updateWithModel:[self.folderAlbums objectAtIndexSafe:indexPath.row]];
            return cell;
		} else if (indexPath.row == [self.folderAlbums count]) {
			return [self createLoadingCell:indexPath.row];
		}
	} else {
		if (indexPath.row < self.songs.count) {
            // Song
            UniversalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UniversalTableViewCell.reuseId];
            cell.hideNumberLabel = YES;
            cell.hideCoverArt = NO;
            cell.hideDurationLabel = NO;
            [cell updateWithModel:[self.songs objectAtIndexSafe:indexPath.row]];
            return cell;
		} else if (indexPath.row == self.songs.count) {
			return [self createLoadingCell:indexPath.row];
		}
	}
	
	// In case somehow no cell is created, return an empty cell
	static NSString *cellIdentifier = @"EmptyCell";
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath) return;
	
	if (self.searchType == ISMSSearchSongsSearchType_Artists) {
		if (indexPath.row != self.folderArtists.count) {
			ISMSFolderArtist *folderArtist = [self.folderArtists objectAtIndexSafe:indexPath.row];
			FolderAlbumViewController *albumView = [[FolderAlbumViewController alloc] initWithFolderArtist:folderArtist orFolderAlbum:nil];
			[self pushViewControllerCustom:albumView];
			return;
		}
	} else if (self.searchType == ISMSSearchSongsSearchType_Albums) {
		if (indexPath.row != self.folderAlbums.count) {
			ISMSFolderAlbum *folderAlbum = [self.folderAlbums objectAtIndexSafe:indexPath.row];
            FolderAlbumViewController *albumView = [[FolderAlbumViewController alloc] initWithFolderArtist:nil orFolderAlbum:folderAlbum];
			[self pushViewControllerCustom:albumView];
			return;
		}
	} else {
		if (indexPath.row != self.songs.count) {
            (void)[Store.shared clearPlayQueue];

			// Add the songs to the playlist
			NSMutableArray *songIds = [[NSMutableArray alloc] init];
			for (ISMSSong *aSong in self.songs) {
				@autoreleasepool {
                    [aSong queue];

					// In jukebox mode, collect the song ids to send to the server
                    if (settingsS.isJukeboxEnabled) {
                        [songIds addObject:@(aSong.songId)];
                    }
				}
			}

			// If jukebox mode, send song ids to server
			if (settingsS.isJukeboxEnabled) {
				[jukeboxS stop];
				[jukeboxS clearPlaylist];
				[jukeboxS addSongs:songIds];
			}

			// Set player defaults
			PlayQueue.shared.isShuffle = NO;

            [NSNotificationCenter postNotificationToMainThreadWithName:ISMSNotification_CurrentPlaylistSongsQueued];

			// Start the song
			ISMSSong *playedSong = [musicS playSongAtPosition:indexPath.row];
            if (!playedSong.isVideo) {
                [self showPlayer];
            }

			return;
		}
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchType == ISMSSearchSongsSearchType_Artists) {
        if (indexPath.row != self.folderArtists.count) {
            return [SwipeAction downloadAndQueueConfigWithModel:[self.folderArtists objectAtIndexSafe:indexPath.row]];
        }
    } else if (self.searchType == ISMSSearchSongsSearchType_Albums) {
        if (indexPath.row != self.folderAlbums.count) {
            return [SwipeAction downloadAndQueueConfigWithModel:[self.folderAlbums objectAtIndexSafe:indexPath.row]];
        }
    } else {
        if (indexPath.row != self.songs.count) {
            return [SwipeAction downloadAndQueueConfigWithModel:[self.songs objectAtIndexSafe:indexPath.row]];
        }
    }
    return nil;
}

@end

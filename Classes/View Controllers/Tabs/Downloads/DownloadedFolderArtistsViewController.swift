//
//  DownloadedFolderArtistsViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 1/15/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import Resolver
import SnapKit
import CocoaLumberjackSwift

final class DownloadedFolderArtistsViewController: AbstractDownloadsViewController {
    @Injected private var store: Store
    @Injected private var settings: Settings
    @Injected private var cache: Cache
    @Injected private var cacheQueue: CacheQueue
        
    var serverId: Int { Settings.shared().currentServerId }
    
    private var downloadedFolderArtists = [DownloadedFolderArtist]()
    override var itemCount: Int { downloadedFolderArtists.count }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Downloaded Folders"
        saveEditHeader.set(saveType: "Folder", countType: "Folder", isLargeCount: true)
    }
    
    @objc override func reloadTable() {
        downloadedFolderArtists = store.downloadedFolderArtists(serverId: serverId)
        super.reloadTable()
        addOrRemoveSaveEditHeader()
    }
    
    override func deleteItems(indexPaths: [IndexPath]) {
        HUD.show()
        DispatchQueue.userInitiated.async {
            for indexPath in indexPaths {
                _ = self.store.deleteDownloadedSongs(downloadedFolderArtist: self.downloadedFolderArtists[indexPath.row])
            }
            self.cache.findCacheSize()
            NotificationCenter.postOnMainThread(name: Notifications.cachedSongDeleted)
            if (!self.cacheQueue.isDownloading) {
                self.cacheQueue.start()
            }
            HUD.hide()
        }
    }
}

extension DownloadedFolderArtistsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueUniversalCell()
        cell.show(cached: false, number: false, art: false, secondary: true, duration: false)
        cell.update(model: downloadedFolderArtists[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if !isEditing {
            let controller = DownloadedFolderAlbumViewController(folderArtist: downloadedFolderArtists[indexPath.row])
            pushViewControllerCustom(controller)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        SwipeAction.downloadQueueAndDeleteConfig(downloadHandler: nil, queueHandler: {
            // TODO: implement this
//            [HUD show];
//            [EX2Dispatch runInBackgroundAsync:^{
//                NSMutableArray *songMd5s = [[NSMutableArray alloc] initWithCapacity:50];
//                [databaseS.songCacheDbQueue inDatabase:^(FMDatabase *db) {
//                    FMResultSet *result = [db executeQuery:@"SELECT md5 FROM cachedSongsLayout WHERE seg1 = ? ORDER BY seg2 COLLATE NOCASE", folderArtist.name];
//                    while ([result next]) {
//                        @autoreleasepool {
//                            NSString *md5 = [result stringForColumnIndex:0];
//                            if (md5) [songMd5s addObject:md5];
//                        }
//                    }
//                    [result close];
//                }];
//
//                for (NSString *md5 in songMd5s) {
//                    @autoreleasepool {
//                        [[ISMSSong songFromCacheDbQueue:md5] addToCurrentPlaylistDbQueue];
//                    }
//                }
//
//                [NSNotificationCenter postNotificationToMainThreadWithName:Notifications.currentPlaylistSongsQueued];
//
//                [EX2Dispatch runInMainThreadAsync:^{
//                    [HUD hide];
//                }];
//            }];
        }, deleteHandler: {
            self.deleteItems(indexPaths: [indexPath])
//            HUD.show()
//            DispatchQueue.userInitiated.async {
//                if self.store.deleteDownloadedSongs(downloadedFolderArtist: self.downloadedFolderArtists[indexPath.row]) {
//                    self.cache.findCacheSize()
//                    NotificationCenter.postOnMainThread(name: Notifications.cachedSongDeleted)
//                    if (!self.cacheQueue.isDownloading) {
//                        self.cacheQueue.start()
//                    }
//                }
//                HUD.hide()
//            }
        })
    }
}

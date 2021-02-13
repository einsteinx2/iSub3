//
//  DownloadedTagAlbumsViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 1/15/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import Resolver
import SnapKit
import CocoaLumberjackSwift

// TODO: Make sure to call the getAlbum API for all downloaded songs or they won't show up here
final class DownloadedTagAlbumsViewController: AbstractDownloadsViewController {
    @Injected private var store: Store
    @Injected private var settings: Settings
    
    var serverId: Int { Settings.shared().currentServerId }
        
    private var downloadedTagAlbums = [DownloadedTagAlbum]()
    override var itemCount: Int { downloadedTagAlbums.count }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Downloaded Albums"
        saveEditHeader.set(saveType: "Album", countType: "Album", isLargeCount: true)
    }
    
    @objc override func reloadTable() {
        downloadedTagAlbums = store.downloadedTagAlbums(serverId: serverId)
        super.reloadTable()
        addOrRemoveSaveEditHeader()
    }
    
    // TODO: implement this
    override func deleteItems(indexPaths: [IndexPath]) {
//        HUD.show()
//        DispatchQueue.userInitiated.async {
//            for indexPath in indexPaths {
//                _ = self.store.deleteDownloadedSongs(downloadedFolderArtist: self.downloadedFolderArtists[indexPath.row])
//            }
//            self.cache.findCacheSize()
//            NotificationCenter.postOnMainThread(name: Notifications.cachedSongDeleted)
//            if (!self.cacheQueue.isDownloading) {
//                self.cacheQueue.start()
//            }
//            HUD.hide()
//        }
    }
}

extension DownloadedTagAlbumsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueUniversalCell()
        cell.show(cached: false, number: false, art: true, secondary: true, duration: false)
        cell.update(model: downloadedTagAlbums[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if !isEditing {
            let controller = DownloadedTagAlbumViewController(downloadedTagAlbum: downloadedTagAlbums[indexPath.row])
            pushViewControllerCustom(controller)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // TODO: implement this
        return nil
    }
}

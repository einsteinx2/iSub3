//
//  LibraryViewController.swift
//  iSub Release
//
//  Created by Benjamin Baron on 2/4/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import Resolver
import Tabman
import Pageboy

final class LibraryViewController: TabmanViewController {
    private enum TabType: Int, CaseIterable {
        case folders = 0, artists, bookmarks
        var name: String {
            switch self {
            case .folders:   return "Folders"
            case .artists:   return "Artists"
            case .bookmarks: return "Bookmarks"
            }
        }
    }

    @Injected private var settings: Settings
    
    private let buttonBar = TMBar.ButtonBar()
    private var controllerCache = [TabType: UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.background
        title = "Library"
        
        // TODO: implement this - make a function like setupDefaultTableView to add this and the two buttons in viewWillAppear automatically when in the tab bar and the controller is the root of the nav stack (do this for all view controllers to remove the duplicate code)
        // Or maybe just make a superclass that sets up the default table and handles all this
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(addURLRefBackButton), name: UIApplication.didBecomeActiveNotification)

        // Setup ButtonBar
        isScrollEnabled = false
        dataSource = self
        buttonBar.backgroundView.style = .clear
        buttonBar.layout.transitionStyle = .snap
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addURLRefBackButton()
        addBar(buttonBar, dataSource: self, at: .navigationItem(item: navigationItem))
        Flurry.logEvent("LibraryTab")
    }
    
    deinit {
        NotificationCenter.removeObserverOnMainThread(self)
    }
    
    private func viewController(index: Int) -> UIViewController? {
        guard let type = TabType(rawValue: index) else { return nil }
        
        if let viewController = controllerCache[type] {
            return viewController
        } else {
            let controller: UIViewController
            switch type {
            case .folders:
                let foldersMediaFolderId = settings.rootFoldersSelectedFolderId?.intValue ?? MediaFolder.allFoldersId
                let foldersDataModel = FolderArtistsViewModel(serverId: settings.currentServerId, mediaFolderId: foldersMediaFolderId)
                controller = ArtistsViewController(dataModel: foldersDataModel)
            case .artists:
                let artistsMediaFolderId = settings.rootArtistsSelectedFolderId?.intValue ?? MediaFolder.allFoldersId
                let artistsDataModel = TagArtistsViewModel(serverId: settings.currentServerId, mediaFolderId: artistsMediaFolderId)
                controller = ArtistsViewController(dataModel: artistsDataModel)
            case .bookmarks:
                controller = BookmarksViewController()
            }
            controllerCache[type] = controller
            return controller
        }
    }
}

extension LibraryViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return TabType.count
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewController(index: index)
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        return TMBarItem(title: TabType(rawValue: index)?.name ?? "")
    }
}

//
//  ServerPlaylist.swift
//  iSub
//
//  Created by Benjamin Baron on 1/11/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import Foundation
import Resolver

@objc final class ServerPlaylist: NSObject, NSCopying, Codable {
    // This is the format that my server seems to reply with
    private static let iso8601FormatterWithMilliseconds: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()
    // This is the format shown in the documentation
    private static let iso8601FormatterWithoutTimezone: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
    static func formatDate(dateString: String) -> Date? {
        iso8601FormatterWithMilliseconds.date(from: dateString) ?? iso8601FormatterWithoutTimezone.date(from: dateString)
    }
    
    @objc let serverId: Int
    @objc(playlistId) let id: Int
    @objc var coverArtId: String?
    @objc var name: String
    @objc var comment: String?
    @objc var songCount: Int
    @objc var duration: Int
    @objc var owner: String
    @objc var isPublic: Bool
    @objc var createdDate: Date? = nil
    @objc var changedDate: Date? = nil
    @objc var loadedSongCount: Int
    // TODO: Add allowed users array
    
    @objc var isLoaded: Bool { return songCount == loadedSongCount }
    
    @objc(initWithServerId:playlistId:coverArtId:name:comment:songCount:duration:owner:isPublic:createdDate:changedDate:loadedSongCount:)
    init(serverId: Int, id: Int, coverArtId: String?, name: String, comment: String?, songCount: Int, duration: Int, owner: String, isPublic: Bool, createdDate: Date?, changedDate: Date?, loadedSongCount: Int) {
        self.serverId = serverId
        self.id = id
        self.coverArtId = coverArtId
        self.name = name
        self.comment = comment
        self.songCount = songCount
        self.duration = duration
        self.owner = owner
        self.isPublic = isPublic
        self.createdDate = createdDate
        self.changedDate = changedDate
        self.loadedSongCount = loadedSongCount
        super.init()
    }
    
    @objc init(serverId: Int, element: RXMLElement) {
        self.serverId = serverId
        self.id = element.attribute("id").intXML
        self.coverArtId = element.attribute("coverArt")
        self.name = element.attribute("name").stringXML
        self.comment = element.attribute("comment")
        self.songCount = element.attribute("songCount").intXML
        self.duration = element.attribute("duration").intXML
        self.owner = element.attribute("owner").stringXML
        self.isPublic = element.attribute("public").boolXML
        if let createdDateString = element.attribute("created") {
            self.createdDate = Self.formatDate(dateString: createdDateString)
        }
        if let changedDateString = element.attribute("changed") {
            self.changedDate = Self.formatDate(dateString: changedDateString)
        }
        self.loadedSongCount = 0
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        ServerPlaylist(serverId: serverId, id: id, coverArtId: coverArtId, name: name, comment: comment, songCount: songCount, duration: duration, owner: owner, isPublic: isPublic, createdDate: createdDate, changedDate: changedDate, loadedSongCount: loadedSongCount)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? LocalPlaylist {
            return self === object || id == object.id
        }
        return false
    }
    
    override var description: String {
        "\(super.description): serverId: \(serverId), id: \(id), coverArtId: \(coverArtId ?? "nil"), name: \(name), comment: \(comment ?? "nil"), songCount: \(songCount), duration: \(duration), owner: \(owner), isPublic: \(isPublic), createdDate: \(createdDate?.description ?? "nil"), changedDate: \(changedDate?.description ?? "nil"), loadedSongCount: \(loadedSongCount)"
    }
}

extension ServerPlaylist: TableCellModel {
    var primaryLabelText: String? { name }
    var secondaryLabelText: String? {
        var secondaryLabelText = (songCount == 1 ? "1 song" : "\(songCount) songs")
        if let durationString = NSString.formatTime(Double(duration)) {
            secondaryLabelText += " • \(durationString)"
        }
        return secondaryLabelText
    }
    var durationLabelText: String? { NSString.formatTime(Double(duration)) }
    var isCached: Bool { false }
    func download() {
        let store: Store = Resolver.resolve()
        for position in 0..<self.songCount {
            store.song(serverId: serverId, serverPlaylistId: id, position: position)?.download()
        }
    }
    func queue() {
        let store: Store = Resolver.resolve()
        for position in 0..<self.songCount {
            store.song(serverId: serverId, serverPlaylistId: id, position: position)?.queue()
        }
    }
}

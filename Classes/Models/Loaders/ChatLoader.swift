//
//  ChatLoader.swift
//  iSub
//
//  Created by Benjamin Baron on 1/9/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

final class ChatLoader: APILoader {
    var serverId = Settings.shared().currentServerId
    
    var chatMessages = [ChatMessage]()
    
    override var type: APILoaderType { .chat }
    
    override func createRequest() -> URLRequest? {
        return NSMutableURLRequest(susAction: "getChatMessages", parameters: nil) as URLRequest
    }
    
    override func processResponse(data: Data) {
        let root = RXMLElement(fromXMLData: data)
        if !root.isValid {
            informDelegateLoadingFailed(error: NSError(ismsCode: Int(ISMSErrorCode_NotXML)))
        } else {
            if let error = root.child("error"), error.isValid {
                informDelegateLoadingFailed(error: NSError(subsonicXMLResponse: error))
            } else {
                chatMessages.removeAll()
                root.iterate("chatMessages.chatMessage") { e in
                    self.chatMessages.append(ChatMessage(serverId: self.serverId, element: e))
                }
                informDelegateLoadingFinished()
            }
        }
    }
}
//
//  WSRequest.swift
//  WSTest
//
//  Created by Wong, Benedict S on 6/12/15.
//  Copyright (c) 2015 ObsessiveOrange. All rights reserved.
//

import UIKit

// set all method types here, to prevent typos.
enum methodType: String{
    case null = "null"
    case echo = "echo"
    case startChat = "chat_startChat"
    case getChatIds = "chat_getChatIds"
    case sendChatMessage = "chat_sendChatMessage"
    case getMessagesForChat = "chat_getMessagesForChat"
}

//superclass for all requests, contains data shared across all instances
class WSRequest: NSObject {
    
    static var tagCounter: NSInteger = 0
    
    var data: NSMutableDictionary = NSMutableDictionary()
    var successHandler : ((NSDictionary) -> Void)?
    var failHandler : ((NSDictionary) -> Void)?
    
    init(method: NSString){
        data["tag"] = NSNumber(integer: WSRequest.tagCounter++)
        data["method"] = method
        
        super.init();	
    }
    
    func getData() -> NSMutableDictionary{
        return data
    }
}

// MARK: Subclasses for each different type of request.

class WSEchoRequest: WSRequest{
    
    init(message: NSString){
        super.init(method:methodType.echo.rawValue);
        
        data["message"] = message
    }
}

class WSStartChatRequest: WSRequest{
    
    init(itemId: NSString){
        super.init(method:methodType.startChat.rawValue);
        
        super.data["itemId"] = itemId
    }
}

class WSGetChatsRequest: WSRequest{
    
    init(itemId: NSString){
        super.init(method:methodType.getChatIds.rawValue);
        
        super.data["itemId"] = itemId
    }
}

class WSGetMessagesForChatRequest: WSRequest{
    
    init(chatId: NSString){
        super.init(method:methodType.getMessagesForChat.rawValue);
        
        super.data["chatId"] = chatId
    }
}

class WSSendChatMessageRequest: WSRequest{
    
    init(chatId: NSString, message: NSString){
        super.init(method:methodType.sendChatMessage.rawValue);
        
        super.data["chatId"] = chatId
        super.data["message"] = message
    }
}

//
//  wsManager.h
//  WSTest
//
//  Created by Wong, Benedict S on 6/11/15.
//  Copyright (c) 2015 ObsessiveOrange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocketRocket/SRWebSocket.h>
#import "Bakkle-Swift.h"

@interface WSManager : NSObject <SRWebSocketDelegate>

+(void) setAuthenticationWithUUID: (NSString*) uuid withToken: (NSString*) token;
+(void) setAutoRegister:(BOOL) autoRegister;
+(void) registerMessageHandler: (void (^)(NSDictionary*)) handler forNotification: (NSString*) notificationType;

+(BOOL) connectWS;
+(void) enqueueWorkPayload:(WSRequest*) payload;

@end

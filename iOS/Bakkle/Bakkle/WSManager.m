//
//  wsManager.m
//  WSTest
//
//  Created by Wong, Benedict S on 6/11/15.
//  Copyright (c) 2015 ObsessiveOrange. All rights reserved.
//

#import "WSManager.h"
//#if defined(TARGET_BAKKLE)
#import "Bakkle-Swift.h"
//#else
//#import "Goodwill-Swift.h"
//#endif


static WSManager *_wsManagerInstance;
static NSString *_wsUrl;
static BOOL debug = true;

@interface WSManager()

@property (nonatomic) BOOL socketOpen;
@property (nonatomic, strong) dispatch_semaphore_t socketOpenNotifier;
@property (nonatomic, strong) dispatch_semaphore_t queueItemNotifier;
@property (nonatomic, strong) NSMutableArray *workQueue;
@property (nonatomic, strong) NSMutableDictionary *successHandlers;
@property (nonatomic, strong) NSMutableDictionary *failHandlers;
@property (nonatomic, strong) NSMutableDictionary *onMessageHandlers;
@property (nonatomic, strong) NSNumber *tagCounter;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *auth_token;
@property (nonatomic) BOOL autoRegister;

@end

@implementation WSManager{
    SRWebSocket *webSocket;
}

// called on first class load - initializes all variables as needed.
+(void) initialize{
    _wsManagerInstance = [[WSManager alloc] init];
    _wsManagerInstance.socketOpenNotifier = dispatch_semaphore_create(0);
    _wsManagerInstance.queueItemNotifier = dispatch_semaphore_create(0);
    _wsManagerInstance.workQueue = [[NSMutableArray alloc] init];
    _wsManagerInstance.successHandlers = [[NSMutableDictionary alloc] init];
    _wsManagerInstance.failHandlers = [[NSMutableDictionary alloc] init];
    _wsManagerInstance.onMessageHandlers = [[NSMutableDictionary alloc] init];
    _wsManagerInstance.tagCounter = [NSNumber numberWithInt:0];}

#pragma mark - public static methods for interfacing with websockets.

+(void) setAuthenticationWithUUID: (NSString*) uuid withToken: (NSString*) token{
    _wsManagerInstance.uuid = uuid;
    _wsManagerInstance.auth_token = token;
}

+(void) registerMessageHandler: (void (^)(NSDictionary*)) handler forNotification: (NSString*) notificationType {
    [_wsManagerInstance.onMessageHandlers setObject:handler forKey:notificationType];
}

+(BOOL) connectWS{
    if(_wsManagerInstance.uuid == nil || _wsManagerInstance.auth_token == nil){
        [NSException raise:@"Authentication token/uuid not initialized. Call setAuthenticationWithUUID:withToken: first." format:@"Invalid token/UUID value: nil"];
    }
    [_wsManagerInstance connectWebSocket];
    return true;
}

+(void) enqueueWorkPayload:(WSRequest*) payload {
    if(!_wsManagerInstance.socketOpen || ![_wsManagerInstance isOpen]){
        [self connectWS];
    }
    
    if(_wsManagerInstance.uuid == nil || _wsManagerInstance.auth_token == nil){
        [NSException raise:@"Authentication token/uuid not initialized. Call setAuthenticationWithUUID:withToken: first." format:@"Invalid token/UUID value: nil"];
    }
    [_wsManagerInstance.workQueue addObject:payload];
    dispatch_semaphore_signal(_wsManagerInstance.queueItemNotifier);
}

#pragma mark - WSManagerInstance private helper methods

- (bool) isOpen{
    return webSocket.readyState == SR_OPEN;
}

- (void) send: (NSString*) message{
    if(debug){NSLog(@"[SendMessage] %@%@\n\n", @"Sending message: ", message);}
    [webSocket send: message];
}

- (void)connectWebSocket {
    
    if(self.socketOpen){
        return;
    }
    
    webSocket.delegate = nil;
    webSocket = nil;
    
    
    //NSString *urlString = @"ws://wongb.rhventures.org:8080/ws/";
    NSString *urlString;
    
    NSInteger serverNum = [[NSUserDefaults standardUserDefaults]integerForKey:@"server"];//NSUserDefaults.standardUserDefaults().integerForKey("server")
    switch( serverNum )
    {
        case 0:
            urlString = @"ws://app.bakkle.com:8000/ws/";
            break;
            //case 0: self.url_base = "https://PRODCLUSTER-16628191.us-west-2.elb.amazonaws.com/"
        case 1:
            urlString = @"ws://app-cluster.bakkle.com:8000/ws/";
            break;

        case 2:
            urlString = @"ws://bakkle.rhventures.org:8000/ws/";
            break;

        case 3:
            urlString = @"ws://wongb.rhventures.org:8000/ws/";
            break;

        case 4:
            urlString = @"ws://10.0.0.118:8000/ws/";
            break;

            //case 4: self.url_base = "http://137.112.57.140:8000/"
        case 5:
            urlString = @""; //Patrick;
            break;

        case 6:
            urlString = @""; //Xinyu;
            break;

        case 7:
            urlString = @""; //Joe;
            break;

        default:
            urlString = @"https://app.bakkle.com:8080/ws/";
            break;

    }
    
    urlString = [NSString stringWithFormat:@"%@?userId=%@&uuid=%@", urlString, [self.auth_token componentsSeparatedByString:@"_"][1], self.uuid];
    
    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    newWebSocket.delegate = self;
    
    [newWebSocket open];
    
    [self startQueueHandler];
}

- (void)startQueueHandler{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(true){
            if(!self.socketOpen){
                dispatch_semaphore_wait(self.socketOpenNotifier, DISPATCH_TIME_FOREVER);
            }
            while(self.workQueue.count > 0){
                WSRequest* nextRequest = [self.workQueue objectAtIndex:0];
                [self.workQueue removeObjectAtIndex:0];
                
                //                workPayload.method = method_getChats
                
                //                self.tagCounter = [NSNumber numberWithInteger:(self.tagCounter.integerValue + 1)];
                //                [workPayload.requestObject setValue:self.tagCounter forKey:@"tag"];
                
                NSMutableDictionary *data = [nextRequest getData];
                [data setValue:self.auth_token forKey:@"auth_token"];
                [data setValue:self.uuid forKey:@"uuid"];
                
                NSError* error;
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
                NSString* jsonMessageString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [_wsManagerInstance send: jsonMessageString];
                
                
                if(nextRequest.successHandler){
                    [self.successHandlers setObject:nextRequest.successHandler forKey:[data objectForKey:@"tag"]];
                }
                if(nextRequest.failHandler){
                    [self.failHandlers setObject:nextRequest.failHandler forKey:[data objectForKey:@"tag"]];
                }
            }
            //wait until next payload is entered, or check every 5s.
            dispatch_semaphore_wait(self.queueItemNotifier, dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC));
        }
        
    });
}



#pragma mark - SRWebSocket delegate methods

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    if(debug){NSLog(@"[SocketOpenedHandler] %@\n\n", @"Websocket opened");}
    webSocket = newWebSocket;
    
    self.socketOpen = true;
    dispatch_semaphore_signal(self.socketOpenNotifier);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    //    [self connectWebSocket];
    if(debug){NSLog(@"[SocketFailureHandler] %@%@\n\n", @"Websocket error: ",error);}
    self.socketOpen = false;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    //    [self connectWebSocket];
    if(debug){NSLog(@"[SocketClosedHandler] %@%@\n\n", @"Websocket closed: ",reason);}
    self.socketOpen = false;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if(debug){NSLog(@"[ReceivedMessageHandler] %@%@\n\n",@"Received message: ", message);}
    
    NSError* error;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    if ([[responseData objectForKey:@"success"] integerValue] == 1){
        if(debug){NSLog(@"[ReceivedMessageHandler] %@\n\n", @"Success Response detected, starting successHandler if present");}
        
        if([responseData objectForKey:@"tag"] != nil){
            if([self.successHandlers objectForKey:[responseData objectForKey:@"tag"]] != nil){
                
                void (^successHandler)(NSDictionary *response) = [self.successHandlers objectForKey:[responseData objectForKey:@"tag"]];
                [self.successHandlers removeObjectForKey:[responseData objectForKey:@"tag"]];
                
                successHandler(responseData);
            }
        }
        else{
            if([self.onMessageHandlers objectForKey:[responseData objectForKey:@"notificationType"]] != nil){
                
                void (^onMessageHandlers)(NSDictionary *messageData) = [self.onMessageHandlers objectForKey:[responseData objectForKey:@"notificationType"]];
                
                onMessageHandlers(responseData);
            }
        }
        
    }
    else {
        
        if([self.failHandlers objectForKey:[responseData objectForKey:@"tag"]] != nil){
            if(debug){NSLog(@"[ReceivedMessageHandler] %@\n\n", @"Fail Response detected, starting failHandler");}
            
            void (^failHandler)(NSDictionary *response) = [self.failHandlers objectForKey:[responseData objectForKey:@"tag"]];
            [self.failHandlers removeObjectForKey:[responseData objectForKey:@"tag"]];
            
            failHandler(responseData);
        }
        else{
            if(debug){NSLog(@"[ReceivedMessageHandler] %@%@\n\n", @"Fail Response detected: ", responseData);}
            
        }
    }
}
@end

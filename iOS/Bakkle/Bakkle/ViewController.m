//
//  ViewController.m
//  WSTest
//
//  Created by Wong, Benedict S on 6/11/15.
//  Copyright (c) 2015 ObsessiveOrange. All rights reserved.
//

#import "ViewController.h"
#import "WSManager.h"
#import "WSTest-Swift.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *chatHistory;
@property (weak, nonatomic) IBOutlet UITextField *chatInput;
@property (nonatomic, strong) NSString *chatId;

@end

@implementation ViewController

- (IBAction)chatSendBtn:(id)sender {
    WSRequest *request = [[WSSendChatMessageRequest alloc]
                          initWithChatId:self.chatId
                          message:self.chatInput.text];
    request.successHandler = ^void(NSDictionary* dict){
        NSLog(@"[SuccessHandler] SuccessHander received success response for tag: %@", [dict objectForKey:@"tag"]);
    };
    [WSManager enqueueWorkPayload:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [WSManager setAuthenticationWithUUID:@"81FEEEDD-C99C-4E50-B671-4302F146441B" withToken:@"4c708bda45351147d32b5c3f541b76ba_3"];
    [WSManager setAutoRegister:true];
    [WSManager connectWS];
    
    [WSManager registerMessageHandler:^void(NSDictionary* messageData){
        NSLog(@"[OnMessageHandler] OnMessageHandler received new message: '%@' from: %@", [messageData objectForKey:@"message"], [messageData objectForKey:@"messageOrigin"]);
        
        [self.chatHistory insertText:@"\n"];
        [self.chatHistory insertText:[NSString stringWithFormat:@"%@", [messageData objectForKey:@"messageOrigin"]]];
        [self.chatHistory insertText:@": "];
        [self.chatHistory insertText:[NSString stringWithFormat:@"%@", [messageData objectForKey:@"message"]]];
        
        [self.chatHistory scrollRangeToVisible:NSMakeRange(self.chatHistory.contentSize.height, 0)];
    } forNotification:@"newMessage"];
    
    
    WSRequest *request = [[WSStartChatRequest alloc] initWithItemId:@"12"];
    request.successHandler = ^void(NSDictionary* dict){
        
        NSLog(@"[SuccessHandler] SuccessHander received chatId: '%@' for tag: %@", [dict objectForKey:@"chatId"], [dict objectForKey:@"tag"]);
        self.chatId = [dict objectForKey:@"chatId"];
    };
    [WSManager enqueueWorkPayload:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

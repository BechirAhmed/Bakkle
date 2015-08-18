//
//  ViewController.m
//  StripeDemo
//
//  Created by Wong, Benedict S on 8/17/15.
//  Copyright (c) 2015 ObsessiveOrange. All rights reserved.
//

#import "ViewController.h"
#import <Stripe/Stripe.h>

@interface ViewController ()<PTKViewDelegate>
@property(weak, nonatomic) PTKView *paymentView;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(15,20,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    NSLog(@"Valid card with number: %@, expiry: %ld/%ld, cvc:%@", card.number, card.expMonth, card.expYear, card.cvc);
    
    [self saveWithNumber:card.number withExpMonth:card.expMonth withExpYear:card.expYear withCVC:card.cvc];
}

- (void) saveWithNumber: (NSString*) number withExpMonth: (NSUInteger) expMonth withExpYear: (NSUInteger) expYear withCVC: (NSString*) cvc{
    STPCard* card = [[STPCard alloc] init];
    
    card.number = number;
    card.expMonth = expMonth;
    card.expYear = expYear;
    card.cvc = cvc;
    card.name = @"Test User";
    
    [[STPAPIClient sharedClient] createTokenWithCard:card completion:^(STPToken *token, NSError *error){
        if(error){
            [self handleError: error];
        }
        else{
            NSLog(@"Token generation sucessful. Received token: %@.", token);
            [self createBackendChargeWithToken: token completion: nil];
        }
    }];
}

- (void) handleError: (NSError*) error{
    NSLog(@"Error thrown: %@", error);
}

- (void) handleErrorWithString: (NSString*) error{
    NSLog(@"Error thrown: %@", error);
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:@"http://bakkle.rhventures.org:8000/purchase/purchase/"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   [self handleErrorWithString:@"Backend returned error"];
                               } else {
                                   NSString* returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"Backend returned successful response: %@", returnData);
                               }
                           }];
}

@end

//
//  ServerSocketManager.m
//  TestApp
//
//  Created by liang jiajian on 2018/4/4.
//  Copyright © 2018年 liang jiajian. All rights reserved.
//

#import "ServerSocketManager.h"
#import "GCDAsyncSocket.h"
#import "ClientSocketHandler.h"

@interface ServerSocketManager () <GCDAsyncSocketDelegate, ClientSocketHandlerDelegate>
@property(strong,nonatomic) GCDAsyncSocket *serverSocket;
@property(strong,nonatomic) ClientSocketHandler *handler;

@end

@implementation ServerSocketManager

+ (ServerSocketManager *)sharedInstance {
    static ServerSocketManager *sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[ServerSocketManager alloc] init];
    });
    return sInstance;
}

- (instancetype)init {
    self = [super init];
    if(self){
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)setupServer {
    NSError *error;
    [self.serverSocket acceptOnPort:8888 error:&error];
    NSLog(@"setupServer error=%@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    self.handler = [[ClientSocketHandler alloc] initWithClientSocket:newSocket delegate:self];
    NSLog(@"didAcceptNewSocket");
}

@end

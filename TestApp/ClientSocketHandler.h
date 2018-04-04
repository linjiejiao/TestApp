//
//  ClientSocketHandler.h
//  TestApp
//
//  Created by liang jiajian on 2018/4/4.
//  Copyright © 2018年 liang jiajian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ClientSocketHandler;
@class GCDAsyncSocket;

typedef NS_ENUM(NSUInteger, ClientSocketHandlerStatus) {
    ClientSocketHandlerStatus_Initial,
    ClientSocketHandlerStatus_Handling,
    ClientSocketHandlerStatus_Finished,
};

typedef void(^SenDataCallback)(BOOL success);

@protocol ClientSocketHandlerDelegate <NSObject>
@optional
- (void)clientSocketHandlerDidFinished:(ClientSocketHandler *)handler withError:(nullable NSError *)err;

@end

@interface ClientSocketHandler : NSObject
@property (assign, nonatomic, readonly) ClientSocketHandlerStatus status;

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket delegate:(id<ClientSocketHandlerDelegate>)delegate;

- (void)finish;

- (void)onReceiveData:(NSData *)NSData dataReceived:(NSUInteger)dataReceived dataTotal:(NSUInteger)dataTotal;

- (void)sendData:(NSData *)data completion:(SenDataCallback)completion;

@end

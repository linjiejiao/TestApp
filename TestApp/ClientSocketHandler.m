//
//  ClientSocketHandler.m
//  TestApp
//
//  Created by liang jiajian on 2018/4/4.
//  Copyright © 2018年 liang jiajian. All rights reserved.
//

#import "ClientSocketHandler.h"
#import "GCDAsyncSocket.h"

#define SizeSegmentLength   4

#define SocketTag_Length    -1
#define SocketTag_SendOK    -1
#define SocketTag_Data      0

@interface ClientSocketHandler () <GCDAsyncSocketDelegate>
@property (weak, nonatomic) id<ClientSocketHandlerDelegate> delegate;
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@property (assign, nonatomic) NSUInteger dataLength;
@property (assign, nonatomic) NSUInteger dataReceived;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, SenDataCallback> *sendDataCallbacks;

@end

@implementation ClientSocketHandler

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket delegate:(id<ClientSocketHandlerDelegate>)delegate {
    self = [super init];
    if(self){
        _status = ClientSocketHandlerStatus_Initial;
        self.clientSocket = clientSocket;
        self.clientSocket.delegate = self;
        self.delegate = delegate;
        self.sendDataCallbacks = [[NSMutableDictionary alloc] init];
        [clientSocket readDataWithTimeout:-1 tag:SocketTag_Length];
        [clientSocket writeData:[@"OK" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:SocketTag_SendOK];
    }
    return self;
}

- (void)finish {
    _status = ClientSocketHandlerStatus_Finished;
    [self.clientSocket setDelegate:nil];
    [self.clientSocket disconnect];
    self.clientSocket = nil;
}

- (void)onReceiveData:(NSData *)NSData dataReceived:(NSUInteger)dataReceived dataTotal:(NSUInteger)dataTotal {

}

- (void)sendData:(NSData *)data completion:(SenDataCallback)completion {
    long tag = (long)([[NSDate date] timeIntervalSince1970] * 1000);
    [self.clientSocket writeData:data withTimeout:60 tag:tag];
    if(completion){
        [self.sendDataCallbacks setObject:completion forKey:@(tag)];
    }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"ClientSocketHandler didReadData data.length=%lu, tag=%ld", data.length, tag);
    if(tag == SocketTag_Length){
        NSData *lengthData = [data subdataWithRange:NSMakeRange(0, SizeSegmentLength)];
        for(int i=0; i<SizeSegmentLength; i++) {
            self.dataLength = self.dataLength * 10 + ((char *)lengthData.bytes)[i];
        }
        self.dataReceived = 0;
        data = [data subdataWithRange:NSMakeRange(SizeSegmentLength, data.length - SizeSegmentLength)];
        NSLog(@"ClientSocketHandler didReadData dataLength=%lu", self.dataLength);
    }
    [sock readDataWithTimeout:-1 tag:SocketTag_Data];
    [self onReceiveData:data dataReceived:self.dataReceived dataTotal:self.dataLength];
    self.dataReceived += data.length;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"ClientSocketHandler didWriteDataWithTag tag=%ld", tag);
    if(tag == SocketTag_SendOK){
        _status = ClientSocketHandlerStatus_Handling;
    }
    SenDataCallback completion = [self.sendDataCallbacks objectForKey:@(tag)];
    if(completion){
        completion(YES);
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    [self finish];
    if(self.delegate && [self.delegate respondsToSelector:@selector(clientSocketHandlerDidFinished:withError:)]) {
        [self.delegate clientSocketHandlerDidFinished:self withError:err];
    }
}

@end

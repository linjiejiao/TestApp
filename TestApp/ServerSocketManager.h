//
//  ServerSocketManager.h
//  TestApp
//
//  Created by liang jiajian on 2018/4/4.
//  Copyright © 2018年 liang jiajian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerSocketManager : NSObject

+ (ServerSocketManager *)sharedInstance;

- (void)setupServer;

@end

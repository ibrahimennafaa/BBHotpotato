//
// Copyright 2013 BiasedBit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

//
//  Created by Bruno de Carvalho (@biasedbit, http://biasedbit.com)
//  Copyright (c) 2013 BiasedBit. All rights reserved.
//

#import "BBHTTPRequest+PrivateInterface.h"

#import "BBHTTPUtils.h"



#pragma mark -

@implementation BBHTTPRequest (PrivateInterface)


#pragma mark Events

- (BOOL)executionStarted
{
    if ([self hasFinished]) return NO;

    _startTimestamp = BBHTTPCurrentTimeMillis();
    if (self.startBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.startBlock();
            self.startBlock = nil;
        });
    }

    return YES;
}

- (BOOL)executionFailedWithError:(NSError*)error
{
    if ([self hasFinished]) return NO;

    _endTimestamp = BBHTTPCurrentTimeMillis();
    _error = error;

    if (self.finishBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.finishBlock(self);
            self.finishBlock = nil;
        });
    }

    return YES;
}

- (BOOL)executionFinishedWithFinalResponse:(BBHTTPResponse*)response
{
    if ([self hasFinished]) return NO;

    _endTimestamp = BBHTTPCurrentTimeMillis();
    _response = response;

    if (self.finishBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.finishBlock(self);
            self.finishBlock = nil;
        });
    }

    return YES;
}

- (BOOL)uploadProgressedToCurrent:(NSUInteger)current ofTotal:(NSUInteger)total
{
    if ([self hasFinished]) return NO;

    _sentBytes = current;

    if (self.uploadProgressBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadProgressBlock(current, total);
        });
    }

    return YES;
}

- (BOOL)downloadProgressedToCurrent:(NSUInteger)current ofTotal:(NSUInteger)total
{
    if ([self hasFinished]) return NO;

    _receivedBytes = current;

    if (self.downloadProgressBlock != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadProgressBlock(current, total);
        });
    }

    return YES;
}

@end

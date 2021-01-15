//
//  InflectorKit+Helper.h
//  iSub
//
//  Created by Benjamin Baron on 1/14/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString(Helper)

- (NSString *)pluralize:(NSInteger)count NS_SWIFT_NAME(pluralize(amount:));

@end

NS_ASSUME_NONNULL_END

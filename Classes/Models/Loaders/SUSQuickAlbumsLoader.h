//
//  SUSQuickAlbumsLoader.h
//  iSub
//
//  Created by Ben Baron on 9/15/12.
//  Copyright (c) 2012 Ben Baron. All rights reserved.
//

#import "SUSLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface SUSQuickAlbumsLoader : SUSLoader

@property (nullable, strong) NSMutableArray *listOfAlbums;
@property (nullable, strong) NSString *modifier;
@property NSUInteger offset;

@end

NS_ASSUME_NONNULL_END

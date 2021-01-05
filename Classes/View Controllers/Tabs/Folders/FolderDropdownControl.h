//
//  FolderDropdownControl.h
//  iSub
//
//  Created by Ben Baron on 3/19/11.
//  Copyright 2011 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderDropdownDelegate.h"

@interface FolderDropdownControl : UIView

@property (nonatomic, weak) id<FolderDropdownDelegate> delegate;

- (void)selectFolderWithId:(NSInteger)folderId;
- (void)updateFolders;
- (void)closeDropdown;
- (void)closeDropdownFast;

- (BOOL)hasMultipleMediaFolders;

@end

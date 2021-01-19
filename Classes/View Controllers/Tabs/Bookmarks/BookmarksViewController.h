//
//  BookmarksViewController.h
//  iSub
//
//  Created by Ben Baron on 5/10/10.
//  Copyright 2010 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong) NSLayoutConstraint *tableViewTopConstraint;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL isNoBookmarksScreenShowing;
@property (nonatomic, strong) UIImageView *noBookmarksScreen;
@property (nonatomic) BOOL isSaveEditShowing;
@property (nonatomic, strong) UIView *saveEditContainer;
@property (nonatomic, strong) UILabel *bookmarkCountLabel;
@property (nonatomic, strong) UIButton *deleteBookmarksButton;
@property (nonatomic, strong) UILabel *deleteBookmarksLabel;
@property (nonatomic, strong) UILabel *editBookmarksLabel;
@property (nonatomic, strong) UIButton *editBookmarksButton;
@property (nonatomic, strong) NSMutableArray *bookmarkIds;

@end

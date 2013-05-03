//
//  TweiberViewController.h
//  Tweiber
//
//  Created by dx082 on 13-04-29.
//  Copyright (c) 2013 Xtreme Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
static const int MAX_TWEETS = 15;
static const int TOTAL_TWEETS = 65;
static const int MORE_TWEETS = 10;
static NSString * const NO_RESULTS_RETURNED = @"No Results Returned";
static NSString * const LOAD_MORE = @"Load More Tweets";
static NSString * const TWEET_URL = @"http://search.twitter.com/search.json";

@interface TweiberViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    int readCount;
    int displayCount;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeHashButton;

@property (strong, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) NSMutableArray* tweetList;

@property (strong, nonatomic) NSString* currentHashTag;
@property (strong, nonatomic) UITextField *changeHashTextField;
@property (strong, nonatomic) NSString *query;
@property Boolean moreButton;

@property Boolean didTweetsChange;

@end

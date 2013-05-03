//
//  TweiberDetailViewController.h
//  Tweiber
//
//  Created by dx082 on 13-04-30.
//  Copyright (c) 2013 Xtreme Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweiberDetailViewController : UIViewController

//Detail View
@property (strong, nonatomic) IBOutlet UIView *tweiberDetailView;

//UI Elements
@property (strong, nonatomic) IBOutlet UITextView *tweetTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *creationTimeLabel;

//Variables
@property (strong, nonatomic) NSString *tweetText;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *creationTime;
@property (strong, nonatomic) NSString *imageUrl;



@end

//
//  TweiberDetailViewController.m
//  Tweiber
//
//  Created by dx082 on 13-04-30.
//  Copyright (c) 2013 Xtreme Labs. All rights reserved.
//

#import "TweiberDetailViewController.h"

@interface TweiberDetailViewController ()

@end

@implementation TweiberDetailViewController

//Synthesizations
@synthesize tweetTextLabel;
@synthesize userNameLabel;
@synthesize creationTimeLabel;
@synthesize profilePicture;
@synthesize tweetText;
@synthesize userName;
@synthesize creationTime;
@synthesize imageUrl;

//Autocreated init function
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//overridden viewDidLoad function
- (void)viewDidLoad
{
    //Call super function
    [super viewDidLoad];
	
    //Set labels to information passed through segue
    tweetTextLabel.text = tweetText;
    userNameLabel.text = userName;
    creationTimeLabel.text = [creationTime stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    
    //Asynchronously load the image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *pic = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:pic];
        //Send picture back to main thread to post onto screen
        dispatch_async(dispatch_get_main_queue(), ^{
            profilePicture.image = img;
        });
    });
}

//Autocreated memore warning function
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

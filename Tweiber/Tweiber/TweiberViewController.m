//
//  TweiberViewController.m
//  Tweiber
//
//  Created by dx082 on 13-04-29.
//  Copyright (c) 2013 Xtreme Labs. All rights reserved.
//

#import "TweiberViewController.h"
#import "TweiberCell.h"
#import "TweiberDetailViewController.h"

@interface TweiberViewController ()
    
@end

@implementation TweiberViewController

@synthesize tweetTableView;
@synthesize changeHashButton;
@synthesize currentHashTag;
@synthesize didTweetsChange;
@synthesize query;
@synthesize moreButton;
@synthesize changeHashTextField;
@synthesize tweetList;

- (void) initProperties {

    displayCount = MAX_TWEETS;
    readCount = 0;
    [self setCurrentHashTag: @"Bieber"];
    [self setDidTweetsChange: YES];
    [self setQuery: nil];
    [self setMoreButton: YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if (self.currentHashTag == nil){
        [self initProperties];
    }
    [self setHashedTitle];
    
    [changeHashButton setTarget:self];
    [changeHashButton setAction:@selector(changeHashSearch:)];
    
    [self asyncFetch];
    [self startTimer];
}

- (void) startTimer {
    
    [NSTimer scheduledTimerWithTimeInterval:15
                                     target:self
                                   selector:@selector(asyncFetch)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) changeHashSearch:(id)sender {
    
    UIAlertView *changeHashAlert = [[UIAlertView alloc] initWithTitle:@"Change HashTag" message:nil delegate:(self) cancelButtonTitle:@"Cancel" otherButtonTitles:@"Search", nil];
    changeHashAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self setChangeHashTextField: [changeHashAlert textFieldAtIndex:0]];
    [[self changeHashTextField] setPlaceholder: [self currentHashTag]];
    [changeHashAlert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString* newHashTag = [[self changeHashTextField] text];
    //search button was clicked and hash tag was entered
    if (buttonIndex == 1 && [newHashTag length] > 0){
        [self setCurrentHashTag: newHashTag];
        [self setQuery: nil];
        [self setTweetList: nil];
        [self setHashedTitle];
        [self asyncFetch];
    }
}

-(void) setHashedTitle {
    
    [self setTitle: [NSString stringWithFormat: @"#%@", [self currentHashTag]]];
}

- (void) asyncFetch {
    
    if ([self query] == nil) {
        [self setQuery: [NSString stringWithFormat: @"%@?q=%@%@", TWEET_URL, @"%23", [self currentHashTag]] ];
    }
    
    //Asynchronously get the JSON for the tweets from the API
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        NSData* data  = [NSData dataWithContentsOfURL:([NSURL URLWithString: [self query]])];
            [self fetchTweets: data];
            //Get the main UI thread to refresh the table once loading of tweets is complete.
            if ([self didTweetsChange]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[self tweetTableView] reloadSections: [NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationBottom];
                });
            }
        });
}

//Wrapper method to fetch the data from JSON results
-(void)fetchTweets:(NSData *)responseData {
    
    NSError* error;
    //number of new tweets
    int rangeSize;
    
    //Serialize the JSON
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options: 0
                                                           error:&error];
    //Parse JSON into an array of single results
    NSMutableArray *newTweetList = [[json objectForKey:@"results"] mutableCopy];

    //update query to reflect refresh url - only return tweets since last query
    [self setQuery:[NSString stringWithFormat: @"%@%@",TWEET_URL, [json objectForKey:@"refresh_url"]]];

    rangeSize = [newTweetList count];
    [self setDidTweetsChange:(rangeSize > 0)];
    
    [newTweetList addObjectsFromArray:[self tweetList]];
    
    if ([newTweetList count] == 0) {
        //no tweets found
        [newTweetList addObject:([NSDictionary dictionaryWithObjectsAndKeys: NO_RESULTS_RETURNED, @"text", nil])];
        //view needs to be refreshed to show 'no tweets' message
        [self setDidTweetsChange: YES];
    } else if (displayCount <= TOTAL_TWEETS && [newTweetList count] > displayCount && moreButton) {
        //number of tweets displayed is more than size of tweet list
        [self setMoreButton: NO];    
    }
    
    [self setTweetList:newTweetList];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int) getDisplayedTweets {
    
    return ((displayCount) < ([[self tweetList] count]) ? (displayCount) : ([[self tweetList] count]));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self getDisplayedTweets];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tweetTableIdentifier = @"tweetCell";
    
    TweiberCell *cell = [tableView dequeueReusableCellWithIdentifier:tweetTableIdentifier];
    
    //defensive code
    if (cell == nil) {
        cell = [[TweiberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: tweetTableIdentifier];
    }
    
    //Create dictionary from parsed tweet
    NSDictionary *tweet = [[self tweetList] objectAtIndex: indexPath.row];
    
    //Populate cell label with tweet text
    cell.tweetLabel.text = [NSString stringWithFormat: @"%@",[tweet objectForKey:@"text"]];
     
    if ([cell.tweetLabel.text isEqualToString: NO_RESULTS_RETURNED]) {
        //no results were found - disable cell
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        //enabled cell
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.userInteractionEnabled = YES;
        if (indexPath.row == [self getDisplayedTweets] - 1 && !moreButton) {
            //last cell
            cell.tweetLabel.text = LOAD_MORE;
            cell.tag = 1;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if ([tweet objectForKey:@"read"] == nil) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

-(void )tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    if (cell.tag == 1) {
        //load more button
        displayCount += MORE_TWEETS;
        moreButton = YES;
        //force reload of tweets
        [self.tweetTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    //the loadMore button has tag 1, prevent segue
    TweiberCell *tmp = sender;
    return ([tmp tag] == 0);
};

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"detailSegue"]) {
        
        //Get index path for selected cell
        NSIndexPath *indexPath = [self.tweetTableView indexPathForSelectedRow];
        
        //get tweet corresponding to cell
        NSMutableDictionary* tweet = [[[self tweetList] objectAtIndex: indexPath.row] mutableCopy];
        //mark as read
        [tweet setObject:@"YES" forKey:@"read"];
        [[self tweetList] replaceObjectAtIndex:indexPath.row withObject:tweet];
        
        //Populate the detail view of the tweet
        TweiberDetailViewController *destination = segue.destinationViewController;
        destination.tweetText = [tweet objectForKey:@"text"];
        destination.userName = [NSString stringWithFormat: @"%@%@", @"@", [tweet objectForKey:@"from_user"]];
        destination.imageUrl = [tweet objectForKey:@"profile_image_url"];
        
        //regex to retrieve source of tweet
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&gt;(.*)&lt;" options:0 error:NULL];
        NSArray* matches = [regex matchesInString:[tweet objectForKey:@"source"]
                                          options:0
                                            range:NSMakeRange(0, [[tweet objectForKey:@"source"] length])];
        //source is appended to creation time
        for (NSTextCheckingResult *match in matches) {
            destination.creationTime = [NSString stringWithFormat: @"%@ via %@", [tweet objectForKey:@"created_at"],
                                        [[tweet objectForKey:@"source"] substringWithRange:
                                         NSMakeRange(match.range.location + 4, match.range.length - 8)]];
        }
    }
}

@end

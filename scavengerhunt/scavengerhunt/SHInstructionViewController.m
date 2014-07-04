//
//  SHInstructionViewController.m
//  scavengerhunt
//
//  Created by Francis Nguyen on 7/3/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import "SHInstructionViewController.h"
#import "SHAppDelegate.h"

@interface SHInstructionViewController ()

@end

@implementation SHInstructionViewController {
    SHAppDelegate *_appDelegate;
    UIImageView *_splashImage;
    NSTimer *_timer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    self.title = @"Scavenger Hunt";
    [self.navigationItem setHidesBackButton:YES];
    _appDelegate = (SHAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"splash_ipad" ofType:@"png"];
        _splashImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        _splashImage.frame = CGRectMake(0,44,768,1024+44); // nav bar is 44 high
    }
    else {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"splash" ofType:@"png"];
        _splashImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        _splashImage.frame = CGRectMake(0,44,320,568+44); // nav bar is 44 high
    }

    if (_splashImage) {
        [self.view addSubview:_splashImage];
        NSLog(@"Splash image should be shown.");
        _timer = [NSTimer
                  scheduledTimerWithTimeInterval:(NSTimeInterval)(2.0)
                  target:self
                  selector:@selector(hideSplash)
                  userInfo:nil
                  repeats:NO];
    }
}

-(void)hideSplash{
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:1.0];
    _splashImage.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startTapped:(id)sender {
    NSLog(@"startTapped called");
    [_appDelegate startTargetCollection];
}
@end

//
//  SHInstructionViewController.m
//  scavengerhunt
//
//  Created by Francis Nguyen on 7/3/14.
//  Copyright (c) 2014 RadiusNetworks. All rights reserved.
//

#import "SHInstructionViewController.h"
#import "SHAppDelegate.h"
#import "SHHunt.h"

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


    
    //initializing splash screen
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        
        NSData *pngData = [NSData dataWithContentsOfFile:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"splash"]];
        _splashImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:pngData]];
        _splashImage.contentMode = UIViewContentModeScaleAspectFill;
        _splashImage.frame = CGRectMake(0,44,768,1024+44); // nav bar is 44 high
    }
    else {
        
        NSData *pngData = [NSData dataWithContentsOfFile:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"splash"]];
        _splashImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:pngData]];
        _splashImage.contentMode = UIViewContentModeScaleAspectFill;
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
    
    //setting logo image
    NSData* logoData = [NSData dataWithContentsOfFile:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"instruction_image"]];
    __instructionsImage.image = [UIImage imageWithData:logoData];
    __instructionsImage.contentMode = UIViewContentModeScaleAspectFit;
    

    //setting text
    [self.titleLabel setText:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"instruction_title"]];
    [self.instructionsLabel setText:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"instruction_text_1"]];
    
    //adjusting background color
    NSString *cString = [[[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"instruction_background_color"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    //if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    //if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    self.background.backgroundColor = [UIColor colorWithRed:((float) r / 255.0f)
                                                      green:((float) g / 255.0f)
                                                       blue:((float) b / 255.0f)
                                                      alpha:1.0f];


    
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
    [[SHHunt sharedHunt] start]; // mark the scavenger hunt as started
    [_appDelegate.manager start]; // start pk looking for beacons
    [_appDelegate startTargetCollection];
}
@end

/*
 * SHViewController.m
 * ScavengerHunt
 *
 * Created by David G. Young on 8/28/13.
 * Copyright (c) 2013,2014 RadiusNetworks. All rights reserved.
 * http://www.radiusnetworks.com
 *
 * @author David G. Young
 *
 * Licensed to the Attribution Assurance License (AAL)
 * (adapted from the original BSD license) See the LICENSE file
 * distributed with this work for additional information
 * regarding copyright ownership.
 *
 */

#import "SHHunt.h"
#import "SHAppDelegate.h"
#import "SHFinishViewController.h"

#define kDeg2Rad (3.1415926/180.0)


@implementation SHFinishViewController {
    SHAppDelegate *_appDelegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _appDelegate = (SHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController setToolbarHidden:YES];
    self.title = @"Scavenger Hunt";
    
    // If there are custom screen values then apply to finish screen
    if ([[SHHunt sharedHunt] hasCustomStartScreen]) {
        //setting logo image
        NSData* logoData = [NSData dataWithContentsOfFile:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"finish_image"]];
        _finishImage.image = [UIImage imageWithData:logoData];
        _finishImage.contentMode = UIViewContentModeScaleAspectFit;
    
        // Setting text
        [self.finishLabel setText:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"finish_text_1"]];
    
        // Set button title
        [_finishButton setTitle:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"finish_button_name"] forState:UIControlStateNormal];
    
        //adjusting background color
        [self.redeemView setBackgroundColor: [self colorWithHexString:[[[SHHunt sharedHunt] customStartScreenData] objectForKey:@"finish_background_color"]]];
    }
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blueColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor blueColor];
    
    NSLog(@"colorWithHexString: %@",cString);
    
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
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.redemptionLabel.text = [NSString stringWithFormat:@"Your completion code is:\n%@", [SHHunt sharedHunt].deviceId];
}

/*
 This method gets called when the user taps OK on the warning dialog about restarting
 the scavenger hunt
 */
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"alert button pressed index is %ld", (long)buttonIndex);
    if (buttonIndex > 0) {
        return;
    }
    [_appDelegate resetHunt];
}


- (IBAction)startHunt:(id)sender {
    NSLog(@"Start hunt button clicked");
    [[SHHunt sharedHunt] start];

    // If I do the following, it fires the segue, but I don't have a reference to the controller.  How do I get that?
    //[self performSegueWithIdentifier:@"startHunt" sender:self];
    NSLog(@"Pushing collection controller: %@",_collectionViewController);

    [self.navigationController pushViewController:_collectionViewController animated:YES];
}

- (IBAction)reset:(id)sender {
    NSLog(@"Reset pushed");
    
    UIAlertView *alert;
    NSLog(@"making sure the user realy wants to reset");
    
    if ([[SHHunt sharedHunt] everythingFound]) {
        alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you are finished?"
                                           message:@"You will not be allowed to return to this page."
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:@"Cancel", nil];
    }
    else {
        alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                           message:@"All found locations will be cleared."
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:@"Cancel", nil];
    }

    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
        [alert show];
     }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

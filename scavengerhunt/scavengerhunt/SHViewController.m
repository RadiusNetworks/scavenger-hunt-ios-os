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

#import "SHViewController.h"
#import "SHTargetCollectionViewController.h"
#import "SHHunt.h"

#define kDeg2Rad (3.1415926/180.0)

@interface SHViewController ()
{
    int _blinkCount;
    NSTimer *_timer;
    UIImageView *_splashImage;
    SHTargetCollectionViewController *_collectionViewController;
    SHAppDelegate *_appDelegate;
}
@end

@implementation SHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _appDelegate = (SHAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _collectionViewController = [_appDelegate.storyboard instantiateViewControllerWithIdentifier:@"TargetCollectionViewController"];
    
    NSLog(@"Collection view controller is no longer null: %@", self.collectionViewController);
    
    self.title = @"Scavenger Hunt";
}


-(void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self showViewForHuntState];
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

/*
 
 This method picks one of several views to display, depending on the state of the hunt.
 Each is a subview on the storyboard, and only one is shown at a time.  Note:  In order 
 to view and edit these subviews on the storyboard, drag the one you want do edit to the
 bottom, an operation that is a little tricky so that you don't end up nesting them 
 improperly.
 
*/
-(void)showViewForHuntState {
    NSLog(@"showViewForHuntState on %@", [SHHunt sharedHunt]);

    UIView *viewToDisplay = self.unstartedView; // default

    if ([[SHHunt sharedHunt] everythingFound]) {
        NSLog(@"Finished");
        viewToDisplay = self.finishedView;
    }
    else if ([[SHHunt sharedHunt] elapsedTime] > 0) {
        NSLog(@"Started");
        viewToDisplay = self.startedView;
        self.huntProgressLabel.text = [NSString stringWithFormat:@"You have found %d of %lu locations and have been hunting for %ld minutes.", [[SHHunt sharedHunt] foundCount], (unsigned long)[[SHHunt sharedHunt] targetList].count, [[SHHunt sharedHunt] elapsedTime]/60];
    }
    else {
        NSLog(@"Unstarted");
    }
    NSLog(@"showing view %@", viewToDisplay);
    [self showView:viewToDisplay];
    
}

-(void) showView: (UIView *) view{

    CGRect currentBounds=self.view.bounds;
    
    [view setHidden: NO];

    if (view != self.unstartedView) {
        [self.unstartedView setHidden: YES];
    }
    if (view != self.startedView) {
        [self.startedView setHidden: YES];
    }
    if (view != self.redeemView) {
        [self.redeemView setHidden: YES];
    }
    if (view != self.finishedView) {
        [self.finishedView setHidden: YES];
    }
    if (view != self.unstartedViewLandscape) {
        [self.unstartedViewLandscape setHidden: YES];
    }
    if (view != self.startedViewLandscape) {
        [self.startedViewLandscape setHidden: YES];
    }

    self.view.bounds=currentBounds;
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

- (IBAction)redeem:(id)sender {
    self.redemptionLabel.text = [NSString stringWithFormat:@"Your completion code is:\n%@", [SHHunt sharedHunt].deviceId];
    
    [self showView:self.redeemView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

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



#import "SHTargetItemViewController.h"
#import "SHTargetItem.h"

@interface SHTargetItemViewController ()
{
    SHTargetItem* _item;
    UILabel* _rangeLabel;
    __weak IBOutlet UILabel * _distanceLabel;
    __weak IBOutlet UIProgressView *_distanceProgress;
}
@end

@implementation SHTargetItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Target Distance";
    [self displayItem];
}

-(void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) showItem:(SHTargetItem *) item {
    _item = item;
    [self displayItem];
}
-(void) displayItem {
    if (_item) {
        if (_item.title == Nil) {
            self.titleLabel.text = [NSString stringWithFormat:@"Target %@", _item.huntId];
        }
        else {
            self.titleLabel.text = _item.title;
        }
        if (_item.description == Nil) {
            self.descriptionLabel.text = [NSString stringWithFormat:@"You must within %0.0f meters to find this item.", _item.triggerDistance];
        }
        else {
            self.descriptionLabel.text = _item.description;
        }

        NSLog(@"title is %@ and description is %@", _item.title, _item.description);
            
        [self showRange];
    }
    else {
        self.title = @"unknown";
    }
}
-(void) showRange {
    if (_item.distance >= 0) {
        if (_item.distance < 10) {
            self.distanceLabel.text = [NSString stringWithFormat:@"%1.1f", _item.distance];

        }
        else {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.0f", _item.distance];
        }
        
        float progress = 0.0;
        if (_item.distance < 10) {
            // if distance is 0-10 meters, show it as 0.6-1.0 on the meter
            progress = 1-(_item.distance/40.0);
        }
        else if (_item.distance < 100) {
            // if distance is 10-30 meters, show it as 0.1 to 0.6 on the meter
            progress = 1-(_item.distance/40.0-0.15);
        }
        else {
            // anything over 30 meters shows at 0.1
            progress = 0.1;
        }
        NSLog(@"progress: %f", progress);

        self.distanceProgress.progress=progress;
    }
    else {
        self.distanceLabel.text = @"--";
        self.distanceProgress.progress=0.0;
    }
    return;
}

@end

/*
 * SHTargetCollectionViewController.m
 * ScavengerHunt
 *
 * Created by David G. Young on 9/4/13.
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

#import "SHTargetCollectionViewController.h"
#import "SHHunt.h"
#import "SHTargetItem.h"
#import "SHAppDelegate.h"
#import "SHTargetItemViewController.h"

@interface SHTargetCollectionViewController ()
{
    SHTargetItemViewController *_itemViewController;
    SHAppDelegate *_appDelegate;
    NSMutableArray *_foundImageCache;
    NSMutableArray *_notFoundImageCache;
}
@end

@implementation SHTargetCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"initWithNibName on collectionViewController");
    if (self) {

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear - collection");
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];  //for example
    
    //set the toolbar buttons
    [self setToolbarItems:[NSArray arrayWithObjects: self.startOverButton, Nil, Nil]];
    NSLog(@"Start over button is %@",self.startOverButton );
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad on collectionViewController");
    _appDelegate = (SHAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.navigationItem.hidesBackButton = YES;
    [self loadImageCaches];
    self.title = @"Scavenger Hunt List";
    _itemViewController = [_appDelegate.storyboard instantiateViewControllerWithIdentifier:@"TargetItemViewController"];
    [self.foundTargetDialog setHidden:YES];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
   return [SHHunt sharedHunt].targetList.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TargetCell";
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    SHTargetItem *item = (SHTargetItem *)[[SHHunt sharedHunt].targetList objectAtIndex:indexPath.row];

    UIImage *icon;
    
    if (item.found) {
        if (indexPath.row < _foundImageCache.count) {
            icon = [_foundImageCache objectAtIndex: indexPath.row];
        }
    }
    else {
        if (indexPath.row < _notFoundImageCache.count) {
            icon = [_notFoundImageCache objectAtIndex: indexPath.row];
        }
    }
    NSLog(@"Icon is %@", icon);

    UIImageView *iconView = [[ UIImageView alloc ] initWithImage:icon];
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad) {
        iconView.frame  = CGRectMake(0, 0, 315, 315);

    }
    else {
        iconView.frame  = CGRectMake(0, 0, 130, 130);
    }
    
    [[cell subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell addSubview: iconView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SelecteItemAtIndexPath called with %@",indexPath);
    
    SHTargetItem *item = (SHTargetItem *)[[SHHunt sharedHunt].targetList objectAtIndex:indexPath.row];
    [_itemViewController showItem:item];
    [self.navigationController pushViewController:_itemViewController animated:YES];
}

// Utility method to make a new image with an applied alpha.  Used for cases where we don't have a greyed out version of the icon
- (UIImage *)greyedOutImage:(UIImage *) image  {
    if (!image) {
        return image;
    }
    
    float alpha = 0.2;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// We cache these up front because loading them in real time is too slow
- (void) loadImageCaches {
    NSLog(@"Loading image caches with %@ %@",_appDelegate,_appDelegate.remoteAssetCache);
    if (_foundImageCache != nil) {
        NSLog(@"already loaded.");
        return;
    }
    _foundImageCache = [[NSMutableArray alloc] init];
    _notFoundImageCache = [[NSMutableArray alloc] init];
    for (int i = 0; i < [SHHunt sharedHunt].targetList.count; i++) {
        SHTargetItem *item = (SHTargetItem *)[[SHHunt sharedHunt].targetList objectAtIndex:i];
        UIImage *image = [_appDelegate.remoteAssetCache getImageByName:[NSString stringWithFormat:@"target%d_found",i+1]];
        if (image == nil) {
            NSLog(@"Cannot find %@_found image", item.huntId);
        }
        else {
            [_foundImageCache setObject:image atIndexedSubscript:i];
        }
        image = [_appDelegate.remoteAssetCache getImageByName:[NSString stringWithFormat:@"target%d",i+1]];
        if (image == nil) {
          NSLog(@"Cannot find %@ image", item.huntId);
        }
        else {
            [_notFoundImageCache setObject:image atIndexedSubscript:i];
        }

    }
    NSLog(@"Done loading image caches");
}

- (IBAction)tappedStartOver:(id)sender {
    NSLog(@"Reset pushed");
    
    UIAlertView *alert;
    NSLog(@"making sure the user realy wants to reset");
    
    alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                           message:@"All found locations will be cleared."
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:@"Cancel", nil];
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [alert show];
     }];
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



- (void) fadeBackground: (UIView *) view {
    [UIView animateWithDuration:2.0
                          delay: 1.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.alpha = 0.0;
                     }
                     completion:nil];
}

-(void) showFoundForTarget: (SHTargetItem *) target {
    return;
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];

    /*
    if (false ) {
        cell.backgroundColor = [UIColor blackColor];
        [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
    else {
        NSLog(@"Can't scroll to position %@ because no cell exists there", index);
        
    }
    */
    
    return;
    

    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         self.foundTargetDialog.alpha = 1.0;
         [self.foundTargetImage setImage:[_foundImageCache objectAtIndex:0]];
         [self.foundTargetDialog setHidden:NO];
         
         // I have verified this is a subview of the collection view
         //[self.collectionView bringSubviewToFront:self.overlayView];
         //[self.overlayView bringSubviewToFront:self.collectionView];

         // If I add the overlay view to self.view, something removes it within a second of adding it

         // desperate try to get this view on top
         [self.overlayView removeFromSuperview];
         [self.collectionView addSubview:self.overlayView];
         [self.collectionView bringSubviewToFront:self.overlayView];
         

         /*
         logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageName.png"]];
         
         logo.contentMode = UIViewContentModeScaleAspectFit;
         [self.collectionView addSubview:logo];
         [self.collectionView sendSubviewToBack:logo];
         
         [logo sendSubviewToBack:logo];
          */
         
         
         //[self fadeDialog];
         
         NSLog(@"overlay view is %@", self.overlayView);
         NSLog(@" ----- subviews of collectionView view ------");
         for (UIView *view in [self.collectionView subviews]) {
             if (view == self.overlayView) {
                 NSLog(@"OVERLAY VIEW: %@", view);
             }
             else {
                 NSLog(@"OTHER VIEW: %@", view);
             }
                 
         }
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 1000),dispatch_get_main_queue(), ^{
             NSLog(@" ----- subviews of collectionView (one sec later) ------");
             for (UIView *view in [self.collectionView subviews]) {
                 if (view == self.overlayView) {
                     NSLog(@"OVERLAY VIEW: %@", view);
                 }
                 else {
                     NSLog(@"OTHER VIEW: %@", view);
                 }
                 
             }

         });
         
         

     }];


}








- (void) fadeDialog {
    [UIView animateWithDuration:2.0
                          delay: 1.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.foundTargetDialog.alpha = 0.0;
                     }
                     completion:nil];
}

@end

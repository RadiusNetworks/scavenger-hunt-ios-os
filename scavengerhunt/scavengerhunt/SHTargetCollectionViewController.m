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
#import "SHTargetItemViewController.h"

@interface SHTargetCollectionViewController ()
{
    SHTargetItemViewController *_itemViewController;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad on collectionViewController");
    self.appDelegate = (SHAppDelegate *) [[UIApplication sharedApplication] delegate];
    [self loadImageCaches];
    self.title = @"Scavenger Hunt List";
    _itemViewController = [self.appDelegate.storyboard instantiateViewControllerWithIdentifier:@"TargetItemViewController"];
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
        iconView.frame  = CGRectMake(0, 0, 350, 350);

    }
    else {
        iconView.frame  = CGRectMake(0, 0, 145, 145);
    }
    
    [[cell subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [cell addSubview: iconView];
    return cell;
}

-(void)handleSingleTap {
    
}

-(void)simulateNotification:(NSString *) message {
    NSLog(@"telling the user he found one");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                    message:@""
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         [alert show];
     }];
    
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
    
    /*
     
    //This greys out the image but it is super slow
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:ciimage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:0.0f] forKey:@"inputSaturation"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    return [UIImage imageWithCGImage:cgImage];
     */
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


- (UIImage *) iconImageFor: (NSString*) identifier withSuffix:(NSString *) suffix {
    UIImage * image = [self iconImageFor:identifier withSuffix:suffix ofType:@"png"];
    if (!image) {
        image = [self iconImageFor:identifier withSuffix:suffix ofType:@"jpg"];
    }
    return image;
}

- (UIImage *)iconImageFor:identifier withSuffix:suffix ofType: type {
    
    
    // TODO: actually load images loaded from the cloud here
    
    return nil;
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
    NSLog(@"Loading image caches with %@ %@",self.appDelegate,self.appDelegate.remoteAssetCache);
    if (_foundImageCache != nil) {
        NSLog(@"already loaded.");
        return;
    }
    _foundImageCache = [[NSMutableArray alloc] init];
    _notFoundImageCache = [[NSMutableArray alloc] init];
    for (int i = 0; i < [SHHunt sharedHunt].targetList.count; i++) {
        SHTargetItem *item = (SHTargetItem *)[[SHHunt sharedHunt].targetList objectAtIndex:i];
        UIImage *image = [self.appDelegate.remoteAssetCache getImageByName:[NSString stringWithFormat:@"target%d_found",i+1]];
        if (image == nil) {
            NSLog(@"Cannot find %@_found image", item.huntId);
        }
        else {
            [_foundImageCache setObject:image atIndexedSubscript:i];
        }
        image = [self.appDelegate.remoteAssetCache getImageByName:[NSString stringWithFormat:@"target%d",i+1]];
        if (image == nil) {
          NSLog(@"Cannot find %@ image", item.huntId);
        }
        else {
            [_notFoundImageCache setObject:image atIndexedSubscript:i];
        }

    }
    NSLog(@"Done loading image caches");
}

@end

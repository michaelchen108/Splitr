//
//  PictureViewController.h
//  cameraTest
//
//  Created by Michael Chen on 1/10/15.
//  Copyright (c) 2015 Michael Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PictureViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;

@end

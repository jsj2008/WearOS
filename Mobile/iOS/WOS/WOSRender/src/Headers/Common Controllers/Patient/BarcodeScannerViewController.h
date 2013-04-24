//
//  BarcodeScannerViewController.h
//  MedTrack
//
//  Created by Larry Suarez on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"

@class WSStyle;
@class Patient;


@interface BarcodeScannerViewController : UIViewController <ZXingDelegate, UITextFieldDelegate> {
    IBOutlet UITextField*      patientIdView_;
    IBOutlet UIButton*         scanBtn_;
    IBOutlet UIBarButtonItem*  saveBtn_;
    IBOutlet UIBarButtonItem*  cancelBtn_;
	IBOutlet UIImageView*      backgroundImageView_;
    Patient*                   patient_;
	WSStyle*                   style_;
}

@property (nonatomic, retain) Patient* patient;

- (IBAction)scanBarcode:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

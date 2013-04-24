//
//  RewardViewController.h
//  REPs
//
//  Created by Larry Suarez on 9/28/12.
//
//

#import <UIKit/UIKit.h>
#import "WSInteractionViewController.h"


@interface RewardViewController : WSInteractionViewController {
	IBOutlet UILabel*     currentPointsLabel_;
	IBOutlet UILabel*     levelCompletedLabel_;
	IBOutlet UILabel*     amountEarnedLabel_;
	IBOutlet UIButton*    nextLevelBtn_;
	IBOutlet UILabel*     nextLevelLabel_;
}

- (IBAction)nextLevel:(id)sender;

@end

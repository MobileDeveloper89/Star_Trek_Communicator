//
//  OverlaySoundSettingTableCell.h
//  SpaceRadio
//
//  Created by Poonam on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlaySoundSettingTableCell : UITableViewCell {
    NSString *soundName;
    NSUInteger soundIndex;
}

@property(nonatomic, retain) IBOutlet UIImageView * backgroundImage;
@property(nonatomic, retain) IBOutlet UILabel * titleLabel;
@property(nonatomic, retain) IBOutlet UILabel * soundPackLabel;
@property(nonatomic, retain) IBOutlet UIButton * leftButton;
@property(nonatomic, retain) IBOutlet UIButton * rightButton;
@property(nonatomic, copy) NSString *currentButton;

-(void) setUpDataForSound:(NSString *)sndName atIndex:(NSUInteger)index cellHighlighted:(BOOL)cellHighlighted;
-(IBAction) previewButtonPressed;
-(IBAction) leftButtonClicked:(id)sender;
-(IBAction) rightButtonClicked:(id)sender;

@end
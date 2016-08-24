//
//  ViewController.h
//  ABPeoplePickerNavigationControllerBug
//
//  Created by marco on 12/23/15.
//  Copyright © 2015 ocz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ViewController : UIViewController<ABPeoplePickerNavigationControllerDelegate>


- (IBAction)pickSomeContact:(id)sender;
@end


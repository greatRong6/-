//
//  AppDelegate.h
//  ABPeoplePickerNavigationControllerBug
//
//  Created by marco on 12/23/15.
//  Copyright © 2015 ocz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


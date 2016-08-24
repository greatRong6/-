//
//  AppDelegate.m
//  ABPeoplePickerNavigationControllerBug
//
//  Created by marco on 12/23/15.
//  Copyright © 2015 ocz. All rights reserved.
//
// bug appears in this file.

#import "AppDelegate.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ViewController.h"

@interface AppDelegate (){
    ABAddressBookRef _addressBook;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Blank view controller, and check contact authentication.
    UIViewController *v = [[UIViewController alloc]init];
    self.window.rootViewController = v;
    [self.window makeKeyAndVisible];
    _addressBook =  ABAddressBookCreateWithOptions(NULL, NULL);
    [self authenticateContact];
    return YES;
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    NSLog(@"AppDelegate: peoplePickerNavigationController - peoplePicker");
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

// new iOS8 API
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}

// called in ios7 or earlier
// Bug will appear after altering system contact several time.

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSLog(@"peoplePickerNavigationController - shouldContinueAfterSelectingPerson2");
    
    // FIXME duplicate code from FavoritesListController.personViewController
    if (kABPersonPhoneProperty == property)
    {
        NSLog(@"this is a phone property");
        ABMultiValueRef phonePro = ABRecordCopyValue(person, property);
        CFIndex count = ABMultiValueGetCount(phonePro);
        CFIndex idx = ABMultiValueGetIndexForIdentifier(phonePro, identifier);
        for (int i = 0; i < count; i++) {
            NSString* phoneNumber = (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phonePro, i));
            NSLog(@"tapped phone number:%@ at %d,id:%d",phoneNumber,i,ABMultiValueGetIdentifierAtIndex(phonePro, i)) ;
        }
        
        NSString* phoneNumber = (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phonePro, idx));
        //NSLog(@"tapped phone number:%@ at %ld",phoneNumber,idx) ;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"tapped phone number:%@ at %ld",phoneNumber,idx] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return YES;
    
}

- (void)authenticateContact
{
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusNotDetermined: {
            //[self accessContactAuthenticated:NO];
            ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self accessContactAuthenticated:YES];
                    }else{
                        [self accessContactAuthenticated:NO];
                    }
                });
            });
        } break;
        case kABAuthorizationStatusAuthorized: {
            [self accessContactAuthenticated:YES];
        } break;
        case kABAuthorizationStatusDenied: {
            [self accessContactAuthenticated:NO];
        } break;
        case kABAuthorizationStatusRestricted: {
            [self accessContactAuthenticated:NO];
        } break;
            
        default: {
        } break;
    }
}

- (void)accessContactAuthenticated:(BOOL)authenticated
{
    if (authenticated) {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
        controller.tabBarItem.title = @"item 2";
        
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
        picker.peoplePickerDelegate = self;
        NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                                   [NSNumber numberWithInt:kABPersonOrganizationProperty], nil];
        
        picker.displayedProperties = displayedItems;
        picker.tabBarItem.title = @"item 1";
        
        
        UITabBarController *tabVC = [[UITabBarController alloc]init];
        tabVC.viewControllers = @[picker,controller];
        self.window.rootViewController = tabVC;

    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please authenticate app to visit your contact!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end

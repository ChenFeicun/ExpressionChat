//
//  SettingsViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/2.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "SettingsViewController.h"
#import "Friends+Methods.h"
#import "NotifyMsg+Methods.h"
#import "AppDelegate.h"
#import "Animation.h"
#import <AddressBook/AddressBook.h>
#import <AVOSCloud/AVOSCloud.h>

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableArray *all;
@property (retain, nonatomic) AppDelegate *appDelegate;
//@property (strong, nonatomic) NSMutableArray *phoneArray;
@end

@implementation SettingsViewController
- (IBAction)touchDown:(id)sender {
    [Animation setBackgroundColorWithGrey:sender];
}

- (IBAction)swipeToBack:(id)sender {
    [self performSegueWithIdentifier:@"SettingsToMain" sender:self];
}

- (IBAction)logout:(id)sender {
    //弹出提醒
    //清除数据库
    [Animation setBackgroundColorWithDark:sender];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (IBAction)validatePhone:(id)sender {
    [Animation setBackgroundColorWithDark:sender];
    [self performSegueWithIdentifier:@"ValidatePhone" sender:self];
}

- (IBAction)addFriendsFromPeople:(id)sender {
    [Animation setBackgroundColorWithDark:sender];
    [self readAllPhoneNumber];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"确定");
        [Friends deleteAllFriends:_context];
        [NotifyMsg deleteAllMsg:_context];
        [AVUser logOut];
        //跳至登录页面
        [self performSegueWithIdentifier:@"Logout" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([AVUser currentUser].mobilePhoneNumber) {
        [_phoneButton setTitle:[AVUser currentUser].mobilePhoneNumber forState:UIControlStateNormal];
        _phoneButton.enabled = NO;
    }
    _appDelegate = [[UIApplication sharedApplication] delegate];
    _document = _appDelegate.document;
    if (_document.documentState == UIDocumentStateNormal) {
        _context = _document.managedObjectContext;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readAllPhoneNumber {
    //IOS6.0以上版本
    ABAddressBookRef tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        NSLog(@"%@", error);
        if (greanted) {
            //
            if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
                return ;
            }
            CFErrorRef error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            //查询所有
            NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            //_phoneArray =
            NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
            for (id person in people) {
                ABMultiValueRef phone = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
                for (int k = 0; k < ABMultiValueGetCount(phone); k++)
                {
                    //获取該Label下的电话值
                    NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                    //去掉+86 以及中间的 -
                    personPhone = [personPhone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    personPhone = [personPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    [phoneArray addObject:personPhone];
                    NSLog(@"%@", personPhone);
                }
            }
            CFRelease(addressBook);
            [self searchAndAddFriends:phoneArray];
        }
    });
}

- (void)searchAndAddFriends:(NSMutableArray *)phoneArray {
    if (![phoneArray count]) {
        return;
    } else {
        //NSLog(@"%i", [phoneArray count]);
        AVQuery *query = [AVUser query];
        [query whereKey:@"mobilePhoneNumber" containedIn:phoneArray];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"%@", error.localizedDescription);
            if (!error) {
                //
                for (AVUser *user in objects) {
                    if (![Friends isFriendExistInDB:user.username inManagedObjectContext:_context]) {
                        //入库
                        NSLog(@"%@", user.username);
                        [Friends addFriend:user inManagedObjectContext:_context];
                    }
                }
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

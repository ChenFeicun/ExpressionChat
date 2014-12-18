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
//#import "SoundManager.h"
#import "Animation.h"
#import "ResourceManager.h"
#import "Toast.h"
#import "UINavigationController+YRBackGesture.h"
#import <AddressBook/AddressBook.h>
#import <AVOSCloud/AVOSCloud.h>

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableArray *all;
@property (retain, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) Toast *loadToast;
//@property (strong, nonatomic) NSMutableArray *phoneArray;
@end

@implementation SettingsViewController

- (IBAction)openOrCloseSound:(id)sender {
    BOOL oOrC = [[NSUserDefaults standardUserDefaults] boolForKey:@"OpenOrClose"];
    [[NSUserDefaults standardUserDefaults] setBool:!oOrC forKey:@"OpenOrClose"];
    NSString *soundTitle = !oOrC ? @"声音: 关" : @"声音: 开";
    [_soundButton setTitle:soundTitle forState:UIControlStateNormal];
}

- (IBAction)aboutBiu:(id)sender {
    [self performSegueWithIdentifier:@"AboutBiu" sender:self];
}

- (IBAction)logout:(id)sender {
    //弹出提醒
    //清除数据库
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登出" message:@"此操作将删除本地数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (IBAction)validatePhone:(id)sender {
    [self performSegueWithIdentifier:@"ValidatePhone" sender:self];
}

- (IBAction)addFriendsFromPeople:(id)sender {
    [self readAllPhoneNumber];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"确定");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OpenOrClose"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MainTip"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"EmojiTip"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SettingsTip"];
        [Friends deleteAllFriends:_context];
        [NotifyMsg deleteAllMsg:_context];
        //删除录音文件
        //AVFile缓存文件
        [AVFile clearAllCachedFiles];
        [[ResourceManager sharedInstance] removeAllSoundFile];
        [AVUser logOut];
        //跳至登录页面
        [self performSegueWithIdentifier:@"Logout" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SettingsTip"]) {
        [[Toast makeTip] pageTip:@"" andCenter:@"向右滑动返回主界面" andBottom:@""];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SettingsTip"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setEnableBackGesture:YES];
    if ([AVUser currentUser].mobilePhoneVerified) {
        [_phoneButton setTitle:[AVUser currentUser].mobilePhoneNumber forState:UIControlStateNormal];
        _phoneButton.enabled = NO;
    }
    _appDelegate = [[UIApplication sharedApplication] delegate];
    _document = _appDelegate.document;
    if (_document.documentState == UIDocumentStateNormal) {
        _context = _document.managedObjectContext;
    }

    NSString *soundTitle = [[NSUserDefaults standardUserDefaults] boolForKey:@"OpenOrClose"] ? @"声音: 关" : @"声音: 开";
    [_soundButton setTitle:soundTitle forState:UIControlStateNormal];
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
            _loadToast = [Toast makeToast:@"请稍候"];
            [_loadToast loading];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
                    return ;
                }
                CFErrorRef error = NULL;
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
                //查询所有
                NSArray *people = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
                
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
            });
        }
    });
}

- (void)searchAndAddFriends:(NSMutableArray *)phoneArray {
    if (![phoneArray count]) {
        [_loadToast endLoading];
        [self performSegueWithIdentifier:@"SettingsToMain" sender:self];
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
            [_loadToast endLoading];
            [self performSegueWithIdentifier:@"SettingsToMain" sender:self];
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

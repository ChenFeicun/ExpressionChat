//
//  ValidateViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/3.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "ValidateViewController.h"
#import "Animation.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ValidateViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
//定时器
@property (strong, nonatomic) NSTimer *timer;
@end

static int count = 9;
static BOOL editingOrNot = NO;
//记录当前 验证的手机号码
static NSString *phoneNumber = nil;
@implementation ValidateViewController
//- (IBAction)swipeToBack:(id)sender {
//    [self performSegueWithIdentifier:@"BackToSettings" sender:self];
//}

- (IBAction)send:(id)sender {
    //先查是否手机号码被注册
    AVQuery *query = [AVUser query];
    [query whereKey:@"mobilePhoneNumber" equalTo:_phoneTextField.text];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (!error) {
            //已经被注册了
            [Animation shakeView:_phoneTextField];
        } else {
            [Animation setBackgroundColorWithDark:sender];
            [AVOSCloud requestSmsCodeWithPhoneNumber:_phoneTextField.text appName:@"Biu" operation:@"验证" timeToLive:10 callback:^(BOOL succeeded, NSError *error) {
                NSLog(@"!!!--%@--!!!", error.localizedDescription);
                if (succeeded) {
                    phoneNumber = _phoneTextField.text;
                    _codeTextField.enabled = YES;
                    _sendButton.enabled = NO;
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                } else if ([error.localizedDescription isEqualToString:@"The mobile phone number was invalid."]) {
                    [Animation shakeView:_phoneTextField];
                }
            }];
        }
    }];
}

- (void)countdown {
    if (count) {
        //会闪
        [_sendButton setTitle:[NSString stringWithFormat:@"发送(%i)", count--] forState:UIControlStateNormal];
    } else {
        [_timer invalidate];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.enabled = YES;
        count = 9;
    }
    
}

- (IBAction)validate:(id)sender {
    [Animation setBackgroundColorWithDark:sender];
    [AVOSCloud verifySmsCode:_codeTextField.text callback:^(BOOL succeeded, NSError *error) {
        //code
        if (succeeded) {
            NSLog(@"Validate Successed");
            //验证成功   更新_User表 加入电话号码
            AVUser *user = [AVUser currentUser];
            user.mobilePhoneNumber = phoneNumber;
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"phoneNumber: %@", [AVUser currentUser].mobilePhoneNumber);
                }
            }];
            //返回上一页
            [self performSegueWithIdentifier:@"BackToSettings" sender:self];
        }
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    editingOrNot = YES;
    [Animation moveViewForEditing:self.view orNot:editingOrNot];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    editingOrNot = NO;
    [Animation moveViewForEditing:self.view orNot:editingOrNot];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:_phoneTextField]) {
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"normal.png"] forState:UIControlStateNormal];
        _sendButton.enabled = ([newText length] > 0);
    } else if ([textField isEqual:_codeTextField]) {
        
        NSLog(@"length:%lu  text:%@", (unsigned long)newText.length, newText);
        if (newText.length == 6) {
            //NSLog(@"%@", newText);
            _sendButton.hidden = YES;
            _validateButton.hidden = NO;
        } else {
            _sendButton.hidden = NO;
            _validateButton.hidden = YES;
        }
    }
    
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _phoneTextField.delegate = self;
    _codeTextField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

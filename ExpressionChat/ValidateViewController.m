
 //
 //  ValidateViewController.m
 //  ExpressionChat
 //
 //  Created by Feicun on 14/11/3.
 //  Copyright (c) 2014年 Feicun. All rights reserved.
 //
 
 #import "ValidateViewController.h"
 #import "Animation.h"
 #import "Toast.h"
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
 //记录当前 验证的手机号码
 static NSString *phoneNumber = nil;
static bool editingOrNot = YES;
 @implementation ValidateViewController
 
 
 - (IBAction)send:(id)sender {
     //先查是否手机号码被注册
     AVUser *user = [AVUser currentUser];
     user.mobilePhoneNumber = _phoneTextField.text;;
     [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         //NSLog(@"%@", error.localizedDescription);
         if (succeeded && !error) {
             //NSLog(@"phoneNumber: %@", [AVUser currentUser].mobilePhoneNumber);
             phoneNumber = _phoneTextField.text;
             [AVUser requestMobilePhoneVerify:phoneNumber withBlock:^(BOOL succeeded, NSError *error) {
                 if (succeeded && !error) {
                     _codeTextField.enabled = YES;
                     _sendButton.enabled = NO;
                     _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                 }
             }];
         } else if ([error.localizedDescription isEqualToString:@"The mobile phone number was invalid."]) {
             [[Toast makeToast:@"无效的手机号码"] show:NO];
             [Animation shakeView:_phoneTextField];
         } else if ([error.localizedDescription isEqualToString:@"Mobile phone number has already been taken"]) {
             [Animation shakeView:_phoneTextField];
             [[Toast makeToast:@"该号码已经被注册"] show:NO];
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
     [AVUser verifyMobilePhone:_codeTextField.text withBlock:^(BOOL succeeded, NSError *error) {
         //NSLog(@"%@", error.localizedDescription);
         if (succeeded && !error) {
             [self performSegueWithIdentifier:@"BackToSettings" sender:self];
         } else if ([error.localizedDescription isEqualToString:@"Invalid sms code."]) {
             [Animation shakeView:_codeTextField];
             [[Toast makeToast:@"无效的验证码"] show:NO];
         }
     }];
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
 
 - (void)viewWillDisappear:(BOOL)animated {
     [super viewWillDisappear:animated];
     AVUser *user = [AVUser currentUser];
     if (!user.mobilePhoneVerified) {
         //NSLog(@"%@", [user dictionaryForObject]);
         if (user.mobilePhoneNumber) {
             user.mobilePhoneNumber = (NSString *)[NSNull null];
             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
             }];
         }
     }
 }
 
 - (void)viewDidLoad {
     [super viewDidLoad];
     _phoneTextField.delegate = self;
     _codeTextField.delegate = self;
     //键盘将出现事件监听
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
     //键盘将隐藏事件监听
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
     
 }
 
- (void)handleKeyboardWillShow:(NSNotification *)notification {
    if (editingOrNot) {
        [Animation moveViewForEditing:self.view orNot:editingOrNot];
        editingOrNot = !editingOrNot;
    }
    
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    if (!editingOrNot) {
        [Animation moveViewForEditing:self.view orNot:editingOrNot];
        editingOrNot = !editingOrNot;
    }
}
 
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }
 
 
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
// }

@end

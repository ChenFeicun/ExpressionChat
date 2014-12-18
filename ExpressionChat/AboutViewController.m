//
//  AboutViewController.m
//  ExpressionChat
//
//  Created by Feicun on 14/11/21.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import "AboutViewController.h"
#import "Toast.h"
@implementation AboutViewController

//
- (IBAction)leanCloud:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://leancloud.cn"]];
}

- (IBAction)sendEmail:(id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [[Toast makeToast:@"当前系统版本不支持应用内发送邮件功能"] show:NO];
        //[self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"];
        return;
    }
    //[self launchMailAppOnDevice];
    if (![mailClass canSendMail]) {
        [[Toast makeToast:@"您尚未设置邮件账户"] show:NO];
        return;
    }
    [self displayMailPicker];
}

- (void)displayMailPicker {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"Biu"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"shuxiajian@outlook.com"];
    [mailPicker setToRecipients: toRecipients];
    
    NSString *emailBody = @"<font color='red'></font>";
    [mailPicker setMessageBody:emailBody isHTML:YES];

    [self presentViewController:mailPicker animated:YES completion:^{
        ;
    }];
//    [self presentModalViewController: mailPicker animated:YES];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    BOOL successed;
    [controller dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    //[self dismissModalViewControllerAnimated:YES];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            successed = NO;
            break;
        case MFMailComposeResultSaved:
            successed = YES;
            msg = @"邮件保存成功";
            break;
        case MFMailComposeResultSent:
            successed = YES;
            msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            successed = NO;
            msg = @"邮件发送失败";
            break;
        default:
            //msg = @"";
            break;
    }
    if (!successed)
        [[Toast makeToast:msg] show:NO];
    else
        [[Toast makeToast:msg] show:YES];
    //[self alertWithMessage:msg];
}
@end

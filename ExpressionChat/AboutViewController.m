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
        [[Toast makeToast:@"当前系统版本不支持应用内发送邮件功能"] show];
        //[self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"];
        return;
    }
    //[self launchMailAppOnDevice];
    if (![mailClass canSendMail]) {
        [[Toast makeToast:@"您尚未设置邮件账户"] show];
        return;
    }
    [self displayMailPicker];
}

- (void)displayMailPicker {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"树下见"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"276549366@qq.com"];
    [mailPicker setToRecipients: toRecipients];
    
    NSString *emailBody = @"<font color='red'></font> 正文";
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
    [controller dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    //[self dismissModalViewControllerAnimated:YES];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            break;
        default:
            //msg = @"";
            break;
    }
    if (![msg isEqualToString:@"邮件发送成功"] && ![msg isEqualToString:@"邮件保存成功"])
        [[Toast makeToast:msg] show];
    //[self alertWithMessage:msg];
}
@end

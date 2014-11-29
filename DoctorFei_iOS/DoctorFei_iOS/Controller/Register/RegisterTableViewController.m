//
//  RegisterTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/22.
//
//

#import "RegisterTableViewController.h"
#import "CountDownManager.h"
#import "NSString+Crypt.h"
static const NSTimeInterval kDuration = 1;

@interface RegisterTableViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *capthaTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTextField;
@property (weak, nonatomic) IBOutlet UIButton *getCapthaButton;
- (IBAction)getCapthaButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end

@implementation RegisterTableViewController
{
    NSTimer *countDownTimer;
    long timeCount;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNumber *recordTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"LastTimeGetCapthaTime"];
    if (recordTime) {
        long nowTime = [[NSDate date]timeIntervalSince1970];
        long interval = (nowTime - [recordTime longValue]);
        if (interval > kDuration) {
            [self.getCapthaButton setEnabled:YES];
            [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        }
        else{
            [self.getCapthaButton setEnabled:NO];
            [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
            timeCount = kDuration - interval;
            [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
            countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
- (void)countDown
{
    timeCount --;
    if (timeCount > 0) {
        [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    }
    else{
        [self.getCapthaButton setEnabled:YES];
        [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getCapthaButtonClicked:(id)sender {
    long nowTime = [[NSDate date]timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults]setObject:@(nowTime) forKey:@"LastTimeGetCapthaTime"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.getCapthaButton setEnabled:NO];
    [self.getCapthaButton.titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
    timeCount = kDuration;
    [self.getCapthaButton setTitle:[NSString stringWithFormat:@"%ld秒后重新获取", timeCount] forState:UIControlStateDisabled];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    //TODO 获取验证码请求
    NSDictionary *params = @{@"mobile": @"18073181979", @"type": @(1)};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = nil;
    if (jsonData) {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *urlString =[NSString createResponseURLWithMethod:@"set.sms.sendcode" Params:jsonString];
    NSLog(@"%@", urlString);
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        else{
            NSLog(@"%@", data);
            NSString *retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *retJson =[NSString decodeFromPercentEscapeString:[retStr decryptWithDES]];
        }
    }]resume];
}

- (IBAction)nextButtonClicked:(id)sender {
}
@end
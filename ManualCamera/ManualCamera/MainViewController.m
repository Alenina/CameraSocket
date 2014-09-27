//
//  MainViewController.m
//  ManualCamera
//
//  Created by LoveStar_PC on 9/27/14.
//  Copyright (c) 2014 IT_Mobile. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"
#import "Define_Public.h"

@interface MainViewController ()<UITextFieldDelegate>
{
    UITextField *txtServerAddress;
    UITextField *txtPortNumber;

}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel * lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(10 * MULTIPLY_VALUE, 0, 140 * MULTIPLY_VALUE, 30 * MULTIPLY_VALUE)];
    [lblAddress setCenter:CGPointMake(lblAddress.center.x, SCREEN_HEIGHT * 0.2)];
    [lblAddress setText:@"Server Address : "];
    [lblAddress setFont:[UIFont systemFontOfSize:14 * MULTIPLY_VALUE]];
    [self.view addSubview:lblAddress];
    
    txtServerAddress = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140 * MULTIPLY_VALUE, 30 * MULTIPLY_VALUE)];
    [txtServerAddress setCenter:CGPointMake(SCREEN_WIDTH * 0.7, SCREEN_HEIGHT * 0.2)];
    [txtServerAddress setFont:[UIFont systemFontOfSize:18 * MULTIPLY_VALUE]];
    [txtServerAddress setBackgroundColor:[UIColor grayColor]];
    [txtServerAddress setText:@"192.168.100.230"];
    [txtServerAddress setDelegate:self];
    [self.view addSubview:txtServerAddress];
    
    UILabel * lblPort = [[UILabel alloc] initWithFrame:CGRectMake(10 * MULTIPLY_VALUE, 0, 140 * MULTIPLY_VALUE, 30 * MULTIPLY_VALUE)];
    [lblPort setCenter:CGPointMake(lblPort.center.x, SCREEN_HEIGHT * 0.4)];
    [lblPort setText:@"Port Number : "];
    [lblPort setFont:[UIFont systemFontOfSize:14 * MULTIPLY_VALUE]];
    [self.view addSubview:lblPort];
    
    txtPortNumber = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140 * MULTIPLY_VALUE, 30 * MULTIPLY_VALUE)];
    [txtPortNumber setCenter:CGPointMake(SCREEN_WIDTH * 0.7, SCREEN_HEIGHT * 0.4)];
    [txtPortNumber setFont:[UIFont systemFontOfSize:20 * MULTIPLY_VALUE]];
    [txtPortNumber setBackgroundColor:[UIColor grayColor]];
    [txtPortNumber setText:@"9092"];
    [txtPortNumber setDelegate:self];
    [self.view addSubview:txtPortNumber];
    
    UIButton * btnStart = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120 * MULTIPLY_VALUE, 50 * MULTIPLY_VALUE)];
    [btnStart setCenter:CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.6)];
    [btnStart setTitle:@"Start" forState:UIControlStateNormal];
    [btnStart setBackgroundColor:[UIColor blueColor]];
    [btnStart addTarget:self action:@selector(onStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnStart];
    
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

- (void)onStart:(id)sender {
    if ([[txtServerAddress.text componentsSeparatedByString:@"."] count] != 4) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input correct Address!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![txtPortNumber.text length]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input correct Port Number!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    ViewController * vcCamera = [self.storyboard instantiateViewControllerWithIdentifier:@"ID_VC_CAMERA"];
    vcCamera.strServerAddress = txtServerAddress.text;
    vcCamera.nPortNumber = [txtPortNumber.text integerValue];
    
    [self presentViewController:vcCamera animated:YES completion:nil];
}
#pragma mark -
#pragma mark UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end

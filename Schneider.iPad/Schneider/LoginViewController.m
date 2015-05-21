//
//  LoginViewController.m
//  Schneider
//
//  Created by iStig on 13-11-4.
//  Copyright (c) 2013年 xhgong. All rights reserved.
//

#import "LoginViewController.h"
#define HUD_SIZE CGSizeMake(300, 100)
@interface LoginViewController ()

@property (nonatomic, strong)   UIButton *login_Btn;
@property (nonatomic, strong)   ATMHud  *atm_hud;
@property (nonatomic, strong) UITextField *userNameTxt;
@property (nonatomic, strong) UITextField *passWordTxt;

@end

@implementation LoginViewController
@synthesize userNameTxt,passWordTxt,login_Btn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 1024, 748);
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *background_ImgV= [[UIImageView alloc] initWithFrame:CGRectMake((1024-306)/2, 160, 306, 90)];
    background_ImgV.image = [UIImage imageNamed:@"schneider_loginLogo.png"];
    [self.view addSubview:background_ImgV];
    
    
    userNameTxt = [[UITextField alloc] initWithFrame:CGRectMake((1024-280)/2, 290, 280, 35)];
    userNameTxt.backgroundColor = [UIColor whiteColor];
    userNameTxt.borderStyle = UITextBorderStyleRoundedRect;
    userNameTxt.placeholder = @"Username";
    userNameTxt.returnKeyType = UIReturnKeyNext;
    userNameTxt.delegate = self;
    userNameTxt.tag = 1000;

    
    passWordTxt = [[UITextField alloc] initWithFrame:CGRectMake((1024-280)/2, self.userNameTxt.frame.origin.y+45, 280, 35)];
    passWordTxt.borderStyle =UITextBorderStyleRoundedRect;
    passWordTxt.backgroundColor = [UIColor whiteColor];
    passWordTxt.placeholder = @"Password";
    passWordTxt.secureTextEntry = YES;
    passWordTxt.returnKeyType = UIReturnKeyDone;
    passWordTxt.delegate = self;
    passWordTxt.tag = 1001;
    
    [self.view addSubview:userNameTxt];
    [self.view addSubview:passWordTxt];

 

  
    login_Btn =[UIButton buttonWithType:UIButtonTypeCustom];
    login_Btn.frame = CGRectMake((1024-280)/2, 768-20-340 , 280, 45);
    [login_Btn setBackgroundImage:[UIImage imageNamed:@"LoginBtn.png"] forState:UIControlStateNormal];
    [login_Btn addTarget:self action:@selector(loginIn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:login_Btn];
    
    
    _atm_hud = [[ATMHud alloc] initWithDelegate:self];
    _atm_hud.view.center =self.view.center;
  
    [self.view addSubview:_atm_hud.view];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)hide{

    [_atm_hud hide];

}
-(void)loginIn{

    NSLog(@"login");
    
    if ([userNameTxt.text length]== 0||[passWordTxt.text length] == 0) {
    
        [_atm_hud setFixedSize:HUD_SIZE];
        [_atm_hud setCaption:@"Please enter in"];
        [_atm_hud show];
        
        [ self performSelector:@selector(hide) withObject:nil afterDelay:1.f];
        return;
    }
    if ([userNameTxt.text isEqualToString:@"schneider"]&&[passWordTxt.text isEqualToString:@"imicrologic"]) {
        NSLog(@"putongyonghu");
        [_atm_hud setFixedSize:HUD_SIZE];
        [_atm_hud setCaption:@"Normal mode"];
        [_atm_hud show];
        saveUDObject(@"normal", Default_Login);
        [ self performSelector:@selector(hide) withObject:nil afterDelay:1.f];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CHECKLOGIN" object:nil];
   [self dismissViewControllerAnimated:NO completion:nil];
        
    }
    

    else if ([userNameTxt.text isEqualToString:@"schneider"]&&[passWordTxt.text isEqualToString:@"lvpadmin"]) {
      NSLog(@"vip");
        
        [_atm_hud setFixedSize:HUD_SIZE];
        [_atm_hud setCaption:@"Vip mode"];
        [_atm_hud show];
        saveUDObject(@"vip", Default_Login);
        [ self performSelector:@selector(hide) withObject:nil afterDelay:1.f];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CHECKLOGIN" object:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
       
    }
    
    else{
    
        [_atm_hud setFixedSize:HUD_SIZE];
        [_atm_hud setCaption:@"Input Error"];
        [_atm_hud show];
        
        [ self performSelector:@selector(hide) withObject:nil afterDelay:1.f];
    
    }
    
    


}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    if (textField.tag == 1000) {
        [passWordTxt becomeFirstResponder];
    }
    
    if (textField.tag == 1001) {
        [self  loginIn];
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)dealloc{

   
    [passWordTxt release];
    [userNameTxt release];
    [login_Btn release];
    [super dealloc];
}

@end

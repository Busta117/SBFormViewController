//
//  SBFormViewController.m
//  
//
//  Created by Santiago Bustamante on 3/4/14.
//  Copyright (c) 2014 Busta. All rights reserved.
//

#import "SBFormViewController.h"

#define SB_FORM_SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

@interface SBFormViewController ()
{
    
    BOOL keyboardShown;
    CGPoint originalPoint_;
    
    NSTimeInterval animationDuration_;
    UIViewAnimationCurve animationCurve_;
}

@end

@implementation SBFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.maxYTolerance = 145; //Default
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.formView) {
        self.formView = self.view;
    }
    
}

- (void) setFormView:(UIView *)formView{
    _formView = formView;
    originalPoint_ = _formView.frame.origin;
    
//    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault && ![UIApplication sharedApplication].statusBarHidden && SB_FORM_SYSTEM_VERSION_GREATER_THAN(@"6.9")) {
//        originalPoint_.y += 20;
//    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    animationDuration_ = durationValue.doubleValue;
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    animationCurve_ = curveValue.intValue;
    
    
    keyboardShown = YES;
    [self moveViewIfNecesary];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    keyboardShown = NO;
    
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    animationDuration_ = durationValue.doubleValue;
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    animationCurve_ = curveValue.intValue;
    
    
    CGRect viewFrame = self.formView.frame;
    if (viewFrame.origin.y < originalPoint_.y) {
        
        viewFrame.origin.y = originalPoint_.y;
        
        
        [UIView animateWithDuration:animationDuration_
                              delay:0.0
                            options:(animationCurve_ << 16)
                         animations:^{
                             self.formView.frame = viewFrame;
                             currentField = nil;
                         }
                         completion:nil];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    currentField = textField;
    currentTextView = nil;
    [self moveViewIfNecesary];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    //currentField = nil;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return [textField resignFirstResponder];
}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    currentTextView = textView;
    currentField = nil;
    [self moveViewIfNecesary];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    //currentField = nil;
    return YES;
}


-(void)moveViewIfNecesary {
    
    if (!keyboardShown)
        return;
    
    
    UIView *reference = currentField?:currentTextView;
    
    
    
    //Calculate if the field needs to be moved
    int originY = reference.frame.origin.y;
    
    originY = [self.formView.window convertPoint:CGPointMake(0, originY) fromView:reference.superview].y;
    
    int deltaY = 0;
    if (originY > self.maxYTolerance)
        deltaY = originY - self.maxYTolerance;
    
    //If there is not delta but the view is moved, then we need to get the view down a bit
    if (deltaY == 0 && self.formView.frame.origin.y < originalPoint_.y) {
        deltaY = originY - self.maxYTolerance;
    }
    
    
    //Do the up animation
    if (deltaY > 0) {
        
        CGRect viewFrame = self.formView.frame;
        viewFrame.origin.y -= deltaY;
        
        
        [UIView animateWithDuration:animationDuration_
                              delay:0.0
                            options:(animationCurve_ << 16)
                         animations:^{
                             self.formView.frame = viewFrame;
                         }
                         completion:nil];
        
        //Do the down animation
    } else if (deltaY < 0) {
        
        CGRect viewFrame = self.formView.frame;
        viewFrame.origin.y -= deltaY;
        
        if (viewFrame.origin.y > originalPoint_.y)
            viewFrame.origin.y = originalPoint_.y;
        
        [UIView animateWithDuration:animationDuration_
                              delay:0.0
                            options:(animationCurve_ << 16)
                         animations:^{
                             self.formView.frame = viewFrame;
                         }
                         completion:nil];
    }
}


- (void) hideKeyboard{
    if (currentField) {
        [currentField resignFirstResponder];
    }
    if (currentTextView) {
        [currentTextView resignFirstResponder];
    }
}


#pragma mark - memory

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.formView.window == nil) {
        
        self.formView = nil;
    }
    
    if (![self isViewLoaded]) {
        
        //Clean outlets here
        currentField = nil;
        currentTextView = nil;
    }
    
    //Clean rest of resources here eg:arrays, maps, dictionaries, etc
}


@end

//
//  SBFormViewController.h
//
//
//  Created by Santiago Bustamante on 3/4/14.
//  Copyright (c) 2014 Busta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBFormViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    UITextField * currentField;
    UITextView * currentTextView;
}

@property (nonatomic, assign) int maxYTolerance;
@property (nonatomic, assign) BOOL moveFormViewParent;
@property (nonatomic, weak) UIView *formView;

-(void)keyboardWillShow:(NSNotification *)notification;
-(void)keyboardWillHide:(NSNotification *)notification;

- (void) hideKeyboard;


@end

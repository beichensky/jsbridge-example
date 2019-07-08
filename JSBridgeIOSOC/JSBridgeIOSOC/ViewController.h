//
//  ViewController.h
//  JSBridgeIOSOC
//
//  Created by BeiChen.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@interface ViewController : UIViewController

@property WKWebView *webView;
@property NSUserDefaults *defaults;
@property WebViewJavascriptBridge *bridge;
@property WKWebViewConfiguration *webConfig;

@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *cookieText;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;

- (void)setWebConfig;
- (void)initWebView;
- (void)registerHandlers;

- (IBAction)onChangeNameBtnClick:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)onCookieBtnClick:(UIButton *)sender forEvent:(UIEvent *)event;

- (void)syncCookie:(NSString *)cookie;
+ (BOOL)judgeIsEmptyWithString:(NSString *)string;
+ (void)addToastWithString:(NSString *)string inView:(UIView *)view;
+ (void) removeToastWithView:(NSTimer *)timer;

@end


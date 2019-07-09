//
//  ViewController.m
//  JSBridgeIOSOC
//
//  Created by BeiChen.
//

#import "ViewController.h"

//尺寸设置
#define aiScreenWidth [UIScreen mainScreen].bounds.size.width
#define aiScreenHeight [UIScreen mainScreen].bounds.size.height
#define STATUS_BAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height
//#define NAVIGATION_BAR_HEIGHT self.navigationController.navigationBar.frame.size.height
//#define TAB_BAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@interface ViewController ()<WKNavigationDelegate, WKUIDelegate>

@end

@implementation ViewController

/**
 *  注意事项：
 *      一、Webview 初始化时设置 cookie 方式：
 *      1.WebViewJavascriptBridge 必须是一个全局对象，不然的话界面不显示了
 *      2.将app中设置的cookie同步到js的话，使用下面这段代码
 *            WKUserContentController* userContentController = WKUserContentController.new;
 *            NSString *cookie = [self.defaults objectForKey:@"cookie"];
 *            if (![ViewController judgeIsEmptyWithString:cookie]) {
 *              NSString *cookieValue = [NSString stringWithFormat:@"document.cookie = '%@%@", cookie, @"';"];
 *              WKUserScript * cookieScript = [[WKUserScript alloc]
 *              initWithSource: cookieValue
 *              injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
 *              [userContentController addUserScript:cookieScript];
 *            }
 *            webConfig.userContentController = userContentController;
 *
 *      二、Webview 已经存在时设置 cookie 的方式
 *      NSString *cookieValue = [NSString stringWithFormat:@"document.cookie = '%@%@", cookie, @"';"];
 *      [_webView evaluateJavaScript:cookieValue completionHandler:^(id _Nullable result, NSError * _Nullable error) {
 *          NSLog(@"cookie-------%@", result);
 *       }];
 *
 *
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化 WKWebViewConfiguration 对象
    self.webConfig = [[WKWebViewConfiguration alloc] init];
    
    // 设置 webConfig 属性
    [self setWebConfig];
    
    // 初始化 WKWebView
    [self initWebView];
    
    // 注册与 H5 交互的事件函数
    [self registerHandlers];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 设置 webConfig 属性
 */
- (void)setWebConfig {
    
    // 设置偏好设置
    _webConfig.preferences = [[WKPreferences alloc] init];
    // 默认为0
    _webConfig.preferences.minimumFontSize = 10;
    // 默认认为YES
    _webConfig.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    _webConfig.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
}

/**
 * 初始化 WKWebView
 */
- (void)initWebView {
    // URL 网络请求地址
    // TODO: 请替换成页面的 url 地址
    NSString *URLSTR = @"http://xxx.xxx.xxx.xx:xxxx";
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 360) configuration:_webConfig];
    // 设置 UserAgent 后缀
    _webView.customUserAgent = [NSString stringWithFormat:self.webView.customUserAgent, @"app"];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    NSURL *url = [NSURL URLWithString:URLSTR];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
    [self.view addSubview:_webView];
}

/**
 * 使用 WebViewJavascriptBridge 注册与 H5 交互的事件函数
 */
- (void)registerHandlers {
    // 启用 WebViewJavascriptBridge
    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    // 注册刷新页面的 reloadUrl 函数
    [self.bridge registerHandler:@"reloadUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.webView reload];
        [ViewController addToastWithString:@"刷新成功~" inView:self.view];
        if (responseCallback) {
            responseCallback(@"");
        }
    }];
    
    // 注册修改 User 名称的 changeUser 函数
    [self.bridge registerHandler:@"changeUser" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.userLabel setText:data];
        if (responseCallback) {
            responseCallback(@"");
        }
    }];
}

/**
 * 修改 name 按钮被点击时触发
 */
- (IBAction)onChangeNameBtnClick:(UIButton *)sender forEvent:(UIEvent *)event {
    NSString *name = [self.nameText text];
    // 调用 H5 界面的 changeName 事件函数
    [self.bridge callHandler:@"changeName" data:name responseCallback:^(id responseData) {
        [ViewController addToastWithString:@"name 修改成功" inView:self.view];
        [self.nameText setText:@""];
    }];
}

/**
 * 设置 Cookie 按钮被点击时触发
 */
- (IBAction)onCookieBtnClick:(UIButton *)sender forEvent:(UIEvent *)event {
    NSString *cookie = [NSString stringWithFormat:@"token=%@", [self.cookieText text]];
    [self syncCookie:cookie];
    // 调用 H5 界面的 syncCookie 事件函数
    [self.bridge callHandler:@"syncCookie" data:@"" responseCallback:^(id responseData) {
        [ViewController addToastWithString:@"Cookie 同步成功" inView:self.view];
        [self.cookieText setText:@""];
    }];
}

/**
 * 用来t设置并同步 Cookie 的工具函数
 */
- (void) syncCookie: (NSString *)cookie {
    // 使用 WKUserScript 携带 cookie 参数传递到 js 页面
    NSString *cookieValue = [NSString stringWithFormat:@"document.cookie = '%@%@", cookie, @"';"];
    [_webView evaluateJavaScript:cookieValue completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"cookie-------%@", result);
    }];
}

/**
 * 判断字符串是否为空或者 null 的方法
 */
+ (BOOL)judgeIsEmptyWithString:(NSString *)string {
    if (string.length == 0 || [string isEqualToString:@""] || string == nil || string == NULL || [string isEqual:[NSNull null]])
    {
        return YES;
    }
    return NO;
}

/**
 * 模拟 Toast效果 的工具方法
 */
+ (void) addToastWithString:(NSString *)string inView:(UIView *)view {
    
    CGRect initRect = CGRectMake(0, STATUS_BAR_HEIGHT, aiScreenWidth, 0);
    CGRect rect = CGRectMake(0, STATUS_BAR_HEIGHT, aiScreenWidth, 22);
    UILabel* label = [[UILabel alloc] initWithFrame:initRect];
    label.text = string;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:0.9 alpha:0.6];
    
    [view addSubview:label];
    
    //弹出label
    [UIView animateWithDuration:0.5 animations:^{
        
        label.frame = rect;
        
    } completion:^ (BOOL finished){
        //弹出后持续1s
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(removeToastWithView:) userInfo:label repeats:NO];
    }];
}

/**
 * 移除 Toast
 */
+ (void) removeToastWithView:(NSTimer *)timer {
    
    UILabel* label = [timer userInfo];
    
    CGRect initRect = CGRectMake(0, STATUS_BAR_HEIGHT, aiScreenWidth, 0);
    //    label消失
    [UIView animateWithDuration:0.5 animations:^{
        
        label.frame = initRect;
    } completion:^(BOOL finished){
        
        [label removeFromSuperview];
    }];
}


@end


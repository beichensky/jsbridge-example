//
//  ViewController.swift
//  JSBridgeIOSSwift
//
//  Created by BeiChen.
//

import UIKit
import WebKit

/**
 *  注意事项：
 *      一、Webview 初始化时设置 cookie 方式：
 *      1.WebViewJavascriptBridge 必须是一个全局对象，不然的话界面不显示了
 *      2.将app中设置的cookie同步到js的话，使用下面这段代码
 *          let userContentController = WKUserContentController()
 *          let cookie = defaults["cookie"] as? String
 *          if !ViewController.judgeIsEmpty(with: cookie) {
 *              let cookieValue = "document.cookie = '\(cookie ?? "")\("';")"
 *              let cookieScript = WKUserScript(source: cookieValue, injectionTime: .atDocumentStart, forMainFrameOnly: false)
 *              userContentController.addUserScript(cookieScript)
 *          }
 *          webConfig.userContentController = userContentController
 *
 *      二、Webview 已经存在时设置 cookie 的方式
 *          let cookieValue = "document.cookie = '\(cookie)\("';")"
 *          webView.evaluateJavaScript(cookieValue, completionHandler: { result, error in
 *              if let result = result {
 *                  print("cookie-------\(result)")
 *              }
 *          })
 *
 */

//尺寸设置
let aiScreenWidth = UIScreen.main.bounds.size.width
let aiScreenHeight = UIScreen.main.bounds.size.height
let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    var bridge: WebViewJavascriptBridge!
    var webConfig: WKWebViewConfiguration!
    
    @IBOutlet var nameText: UITextField!
    @IBOutlet var cookieText: UITextField!
    @IBOutlet var userLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化 WKWebViewConfiguration 对象
        webConfig = WKWebViewConfiguration()
        
        // 设置 webConfig 属性
        setWebConfig()
        
        // 初始化 WKWebView
        initWebView()
        
        // 注册与 H5 交互的事件函数
        registerHandlers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    /**
     * 设置 webConfig 属性
     */
    func setWebConfig() {
        
        // 设置偏好设置
        webConfig.preferences = WKPreferences()
        // 默认为0
        webConfig.preferences.minimumFontSize = 10
        // 默认认为YES
        webConfig.preferences.javaScriptEnabled = true
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = false
    }
    
    /**
     * 初始化 WKWebView
     */
    func initWebView() {
        // URL 网络请求地址
        // TODO: 请替换成页面的 url 地址
        let URLSTR = "http://xxx.xxx.xxx.xxx:xxxx"
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 420), configuration: webConfig!)
        // 设置 UserAgent 后缀
        webView.customUserAgent = String(format: webView!.customUserAgent!, "app")
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = URL(string: URLSTR)
        var urlRequest: URLRequest? = nil
        if let url = url {
            urlRequest = URLRequest(url: url)
        }
        if let urlRequest = urlRequest {
            webView.load(urlRequest)
        }
        view.addSubview(webView)
    }
    
    /**
     * 使用 WebViewJavascriptBridge 注册与 H5 交互的事件函数
     */
    func registerHandlers() {
        // 启用 WebViewJavascriptBridge
        WebViewJavascriptBridge.enableLogging()
        
        // 初始化 WebViewJavascriptBridge
        bridge = WebViewJavascriptBridge(forWebView: webView!);
        bridge.setWebViewDelegate(self);

        // 注册刷新页面的 reloadUrl 函数
        bridge.registerHandler("reloadUrl", handler: { data, responseCallback in
            self.webView?.reload()
            ViewController.addToast(with: "刷新成功~", in: self.view)
            responseCallback?("")
        })

        // 注册修改 User 名称的 changeUser 函数
        bridge.registerHandler("changeUser", handler: { data, responseCallback in
            self.userLabel.text = data as? String
            responseCallback?("")
        })
    }
    
    /**
     * 修改 name 按钮被点击时触发
     */
    @IBAction func onChangeNameBtnClick(_ sender: UIButton, forEvent event: UIEvent) {
        let name = nameText.text
        // 调用 H5 界面的 changeName 事件函数
        bridge.callHandler("changeName", data: name, responseCallback: { responseData in
            ViewController.addToast(with: "name 修改成功", in: self.view)
            self.nameText.text = ""
        })
    }
    
    /**
     * 设置 Cookie 按钮被点击时触发
     */
    @IBAction func onCookieBtnClick(_ sender: UIButton, forEvent event: UIEvent) {
        let cookie = "token=\(cookieText.text ?? "")"
        syncCookie(cookie)
        // 调用 H5 界面的 syncCookie 事件函数
        bridge.callHandler("syncCookie", data: "", responseCallback: { responseData in
            ViewController.addToast(with: "Cookie 同步成功", in: self.view)
            self.cookieText.text = ""
        })
    }
    
    
    /**
     * 用来t设置并同步 Cookie 的工具函数
     */
    func syncCookie(_ cookie: String?) {
        // 使用 WKUserScript 携带 cookie 参数传递到 js 页面
        let cookieValue = "document.cookie = '\(cookie ?? "")\("';")"
        webView.evaluateJavaScript(cookieValue, completionHandler: { result, error in
            if let result = result {
                print("cookie-------\(result)")
            }
        })
    }
    
    /**
     * 判断字符串是否为空或者 null 的方法
     */
    class func judgeIsEmpty(with string: String?) -> Bool {
        if (string?.count ?? 0) == 0 || (string == "") || string == nil || string == nil || string?.isEqual(NSNull()) ?? false {
            return true
        }
        return false
    }
    
    /**
     * 模拟 Toast效果 的工具方法
     */
    class func addToast(with string: String?, in view: UIView?) {
        
        let initRect = CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: aiScreenWidth, height: 0)
        let rect = CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: aiScreenWidth, height: 22)
        let label = UILabel(frame: initRect)
        label.text = string
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0.9, alpha: 0.6)
        
        view?.addSubview(label)
        
        //弹出label
        UIView.animate(withDuration: 0.5, animations: {
            
            label.frame = rect
        }) { finished in
            //弹出后持续1s
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(removeToast(withView:)), userInfo: label, repeats: false)
        }
    }
    
    /**
     * 移除 Toast
     */
    @objc class func removeToast(withView timer: Timer?) {
        
        let label = timer?.userInfo as? UILabel
        
        let initRect = CGRect(x: 0, y: STATUS_BAR_HEIGHT, width: aiScreenWidth, height: 0)
        //    label消失
        UIView.animate(withDuration: 0.5, animations: {
            
            label?.frame = initRect
        }) { finished in
            
            label?.removeFromSuperview()
        }
    }
    
}




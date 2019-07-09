package com.beichen.jsbridgeandroidjava;

import android.annotation.SuppressLint;
import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebChromeClient;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.github.lzyzsd.jsbridge.BridgeHandler;
import com.github.lzyzsd.jsbridge.BridgeWebView;
import com.github.lzyzsd.jsbridge.CallBackFunction;


public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private BridgeWebView mWebView;
    // URL 网络请求地址
    // TODO: 请替换成页面的 url 地址
    private static final String URL = "http://xxx.xxx.xxx.xxx:xxxx/";

    long exitTime = 0;
    private TextView mTvUser;
    private EditText mEditName;
    private EditText mEditCookie;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        initWebView();

        registerHandlers();

        initViews();

    }

    @Override
    protected void onResume() {
        super.onResume();
        mWebView.reload();
    }

    /**
     * 初始化 WebView
     */
    @SuppressLint("SetJavaScriptEnabled")
    private void initWebView() {
        mWebView = findViewById(R.id.main_wv);

        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setAppCacheEnabled(true);
        mWebView.getSettings().setDatabaseEnabled(true);
        // 开启 localStorage
        mWebView.getSettings().setDomStorageEnabled(true);
        // 设置支持javascript
        mWebView.getSettings().setJavaScriptEnabled(true);
        // 进行缩放
        mWebView.getSettings().setBuiltInZoomControls(true);
        // 设置UserAgent
        mWebView.getSettings().setUserAgentString(mWebView.getSettings().getUserAgentString() + "app");
        // 设置不用系统浏览器打开,直接显示在当前WebView
        mWebView.setWebChromeClient(new WebChromeClient());
        mWebView.setWebViewClient(new MyWebViewClient(mWebView));

        mWebView.loadUrl(URL);
    }

    /**
     * 注册与 H5 交互的事件函数
     */
    private void registerHandlers() {
        // 设置默认接收函数
        mWebView.setDefaultHandler(new BridgeHandler() {
            @Override
            public void handler(String data, CallBackFunction function) {
                Toast.makeText(MainActivity.this, data, Toast.LENGTH_LONG).show();
                function.onCallBack("安卓返回给 JS 的消息内容");
            }
        });

        // 注册刷新页面的 reloadUrl 函数
        mWebView.registerHandler("reloadUrl", new BridgeHandler() {

            @Override
            public void handler(String data, CallBackFunction function) {
                mWebView.reload();
                Toast.makeText(MainActivity.this, "刷新成功~", Toast.LENGTH_SHORT).show();
                function.onCallBack("");
            }
        });

        // 注册修改 User 名称的 changeUser 函数
        mWebView.registerHandler("changeUser", new BridgeHandler() {

            @Override
            public void handler(String user, CallBackFunction function) {
                mTvUser.setText(user);
                function.onCallBack("");
            }
        });
    }

    /**
     * 初始化其他 View 组件
     */
    private void initViews() {
        findViewById(R.id.btn_cookie).setOnClickListener(this);
        findViewById(R.id.btn_name).setOnClickListener(this);
        findViewById(R.id.btn_init).setOnClickListener(this);
        mTvUser = findViewById(R.id.tv_user);
        mEditCookie = findViewById(R.id.edit_cookie);
        mEditName = findViewById(R.id.edit_name);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_init:
                // 调用 H5 界面的默认接收函数
                mWebView.send("安卓传递给 JS 的消息", new CallBackFunction() {
                    @Override
                    public void onCallBack(String data) {
                        Toast.makeText(MainActivity.this, data, Toast.LENGTH_LONG).show();
                    }
                });
                break;
            case R.id.btn_name:
                // 调用 H5 界面的 changeName 事件函数
                mWebView.callHandler("changeName", mEditName.getText().toString(), new CallBackFunction() {
                    @Override
                    public void onCallBack(String data) {
                        Toast.makeText(MainActivity.this, "name 修改成功", Toast.LENGTH_SHORT).show();
                        mEditName.setText("");
                    }
                });
                break;
            case R.id.btn_cookie:
                syncCookie(this, URL, "token=" + mEditCookie.getText().toString());
                // 调用 H5 界面的 syncCookie 事件函数
                mWebView.callHandler("syncCookie", "", new CallBackFunction() {
                    @Override
                    public void onCallBack(String data) {
                        Toast.makeText(MainActivity.this, "Cookie 同步成功", Toast.LENGTH_SHORT).show();
                        mEditCookie.setText("");
                    }
                });
                break;
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && mWebView.canGoBack()) {
            // 返回前一个页面
            mWebView.goBack();
            return true;
        } else if (keyCode == KeyEvent.KEYCODE_BACK) {
            exit();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 退出应用
     */
    public void exit() {
        if ((System.currentTimeMillis() - exitTime) > 2000) {
            Toast.makeText(getApplicationContext(), "再按一次退出程序",
                    Toast.LENGTH_SHORT).show();
            exitTime = System.currentTimeMillis();
        } else {
            finish();
            System.exit(0);
        }
    }

    /**
     * 这只并同步 Cookie 的工具函数
     * @param context   上下文对象
     * @param url       url 地址
     * @param cookie    需要设置的 cookie 值，例如："token=azhd57hkslz"
     */
    @SuppressWarnings("deprecation")
    private static void syncCookie(Context context, String url, String cookie){
        CookieSyncManager.createInstance(context);
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        cookieManager.removeSessionCookie();// 移除
        cookieManager.removeAllCookie();
        cookieManager.setCookie(url, cookie);
        String newCookie = cookieManager.getCookie(url);
        Log.i("tag ",  "newCookie == " + newCookie);
        CookieSyncManager.getInstance().sync();
    }

}

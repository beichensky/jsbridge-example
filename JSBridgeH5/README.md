# JSBridgeH5
`JSBridge` 实例中 `H5` 端代码实现。

此项目使用 react 进行编写，但是关于 react 的代码不多，其中关于 jsbridge 使用的代码在任意项目或者框架中均可使用。

代码中有详细注释。


## 下载项目
``` bash
git clone https://github.com/beichensky/jsbridge-example.git
```

## 安装插件
``` bash
# 打开 JSBridgeH5 项目
cd JSBridgeH5

# 安装依赖
npm install
```


## 运行项目
``` bash
npm run start
```

打开浏览器，输入：`localhost:8000` 查看项目运行效果。

运行项目后，才能在原生应用中展示，否则移动端 Webview 加载不出来页面。请记得在将当前的 ip 地址和端口替换到移动端 url 上。



## 项目打包
``` bash
npm run build
```

新增 `dist` 目录，里面是打包好的项目代码



## 更多
关于项目的更多介绍请查看我的博客：[使用 JSBridge 与原生 IOS、Android 进行交互（含H5、Android、IOS端代码，附 Demo）]()

import React, { Component, useState } from 'react';
import { Button, Input, message } from 'antd';
import Cookie from 'js-cookie';

// 使用 CSS Module 的方式引入 App.less
import styles from './App.less';


const isAndroid = navigator.userAgent.endsWith('android');

export default (props) => {

    const [user, setUser] = useState();
    const [name, setName] = useState();
    const [token, setToken] = useState(Cookie.get('token'));

    window.setupWebViewJavascriptBridge(bridge => {
        bridge.registerHandler("changeName", (data, fn) => {
            setName(data);
            fn && fn("");
        });

        bridge.registerHandler("syncCookie", (data, fn) => {   
            setToken(Cookie.get('token'));
            fn && fn("");
        });
    });

    /**
     * 调用原生的默认接受方法
     */
    const handleInit = () => {
        window.setupWebViewJavascriptBridge(bridge => {
            bridge.send("JS 传递给原生的消息", (data) => {
                message.success(data);
            })
        })
    };
    
    /**
     * 调用原生方法刷新 H5 界面
     */
    const handleReload = () => {
        window.setupWebViewJavascriptBridge(bridge => {
            bridge.callHandler('reloadUrl');
        })
    };

    /**
     * 修改原生界面的 User 名称
     */
    const handleChangeUser = () => {
        window.setupWebViewJavascriptBridge(bridge => {
            bridge.callHandler('changeUser', user, () => {
                message.success('user 修改成功！');
                setUser('');
            });
        })
    };

    return (
        <div className={ styles.app }>
            <h2>H5 界面：</h2>
            { isAndroid ? <Button style={{ margin: '10px 0 30px' }} type="primary" onClick={ handleInit }>调用原生默认接收方法</Button> : null}
            <br />
            <Button style={{ marginBottom: 30 }} type="primary" onClick={ handleReload }>调用原生方法刷新 H5 界面</Button>
            <br />
            <Button type="primary" onClick={ handleChangeUser }>修改原生界面的 user 值</Button>
            <Input value={ user } onChange={ (e) => setUser(e.target.value) } style={{ marginLeft: 10, width: 160 }} placeholder="请输入新的 user 名称" />
            <div style={{ marginTop: 30, fontSize: 16 }}>
                <label>Name 值：</label><span style={{ marginLeft: 40 }}>{ name }</span>
            </div>
            <div style={{ marginTop: 30, fontSize: 16 }}>
                <label>同步原生设置的 Cookie 值：</label><span style={{ marginLeft: 20 }}>{ token }</span>
            </div>
        </div>
    )

}

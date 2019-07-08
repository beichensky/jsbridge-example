const path = require('path');
const webpack = require('webpack');
const merge = require('webpack-merge');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const common = require('./webpack.common');

const appPublic = path.resolve(__dirname, '../public');

const config = merge(common, {
    mode: 'development',
    devtool: 'inline-source-map',
    devServer: {
        // 作为服务器发布的目录
        contentBase: appPublic,
        // 热加载
        hot: true,
        // host 地址，设置成 0.0.0.0 才能在移动端使用 ip 地址访问到
        host: '0.0.0.0',
        // 端口号
        port: 8000,
        historyApiFallback: true,
        // 是否在浏览器蒙层展示错误信息
        overlay: true,
        inline: true,
        // 展示的统计信息
        stats: 'errors-only',
        // 配置代理
        proxy: {
            '/api': {
                changeOrigin: true,
                target: 'https://easy-mock.com/mock/5c2dc9665cfaa5209116fa40/example',
                pathRewrite: {
                    '^/api/': '/'
                }
            }
        }
    },
    plugins: [
        // 热加载插件
        new webpack.HotModuleReplacementPlugin(),
        // 提取 css 文件
        new MiniCssExtractPlugin({
            filename: 'public/styles/[name].css',
            chunkFilename: 'public/styles/[name].chunk.css'
        })
    ]
});

module.exports = config;
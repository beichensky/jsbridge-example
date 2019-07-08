const webpack = require('webpack');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const merge = require('webpack-merge');
const common = require('./webpack.common');

const config = merge(common, {
    mode: 'production',
    devtool: 'hidden-source-map',
    plugins: [
        // 提取 css 文件
        new MiniCssExtractPlugin({
            filename: 'public/styles/[name].[contenthash:8].css',
            chunkFilename: 'public/styles/[name].[contenthash:8].chunk.css'
        }),
        // 区分环境
        new webpack.DefinePlugin({
            // 定义 NODE_ENV 环境变量为 production
            'process.env': {
                NODE_ENV: JSON.stringify('production')
            }
        }),
        // 清理 dist 文件，2.0。0 版本之后不需要设置参数就可以自动清除打包生成的目录
        new CleanWebpackPlugin()
    ],
    optimization: {
        // 打包压缩js/css文件
        minimizer: [
            new UglifyJsPlugin({
                uglifyOptions: {
                    compress: {
                        // 在UglifyJs删除没有用到的代码时不输出警告
                        warnings: false,
                        // 删除所有的 `console` 语句，可以兼容ie浏览器
                        drop_console: true,
                        // 内嵌定义了但是只用到一次的变量
                        collapse_vars: true,
                        // 提取出出现多次但是没有定义成变量去引用的静态值
                        reduce_vars: true,
                    },
                    output: {
                        // 最紧凑的输出
                        beautify: false,
                        // 删除所有的注释
                        comments: false,
                    }
                }
            }),
            // 压缩 CSS 代码
            new OptimizeCSSAssetsPlugin({})
        ],
        // 拆分公共模块
        splitChunks: {
            cacheGroups: {
                styles: {
                    name: 'styles',
                    test: /\.(css|less)/,
                    chunks: 'all',
                    enforce: true,
                    // 表示是否使用已有的 chunk
                    reuseExistingChunk: true 
                },
                commons: {
                    name: 'commons',
                    chunks: 'initial',
                    minChunks: 2,
                    reuseExistingChunk: true
                },
                vendors: {
                    name: 'vendors',
                    test: /[\\/]node_modules[\\/]/,
                    priority: -10,
                    reuseExistingChunk: true
                }
            }
        },
        // 为每个仅含有 runtime 的入口起点添加一个额外 chunk
        runtimeChunk: true
    },
    // 性能提醒
    performance: {
        hints: false
    },
    // 统计信息展示
    stats: {
        modules: false,
        children: false,
        chunks: false,
        chunkModules: false
    }
});

module.exports = config;
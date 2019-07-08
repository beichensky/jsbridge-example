module.exports = (api) => {
    api.cache(true);

    return {
        presets: [
            "@babel/preset-env",
            "@babel/preset-react"
        ],
        plugins: [
            [
                "@babel/plugin-proposal-decorators",
                {
                    "legacy": true
                }
            ],
            [
                "import",
                {
                    "libraryName": "antd",
                    "style": true
                }
            ],
            [
                "@babel/plugin-transform-runtime",
                {
                    "corejs": 2
                }
            ],
            [
                "@babel/plugin-proposal-class-properties", 
                { 
                    "loose": true
                }
            ],
            "@babel/plugin-syntax-dynamic-import",
            // "@babel/plugin-syntax-import-meta",
            // 可以用 const ex = "before
            // after"; 这种方式编写字符串
            // "@babel/plugin-proposal-json-strings",
            // 可以使用 generate 语法
            // "@babel/plugin-proposal-function-sent",
            // 可以使用 export * 这种命名空间的方式导出模块
            "@babel/plugin-proposal-export-namespace-from",
            // 可以使用数字分离器书写数字
            // "@babel/plugin-proposal-numeric-separator"
            // 可以使用异常抛出表达式,
            "@babel/plugin-proposal-throw-expressions",
            // 默认导出
            "@babel/plugin-proposal-export-default-from",
            // 可以使用逻辑赋值运算符
            "@babel/plugin-proposal-logical-assignment-operators",
            // 可以使用可选链的方式访问深层嵌套的属性或者函数 ?.
            "@babel/plugin-proposal-optional-chaining",
            // 可以使用管道运算符 |> 
            [
                "@babel/plugin-proposal-pipeline-operator",
                {
                    "proposal": "minimal"
                }
            ],
            // 可以使用空值合并语法 ??
            "@babel/plugin-proposal-nullish-coalescing-operator",
            // 可以使用 do 表达式（可以认为是三元运算符的复杂版本）
            "@babel/plugin-proposal-do-expressions",
            // 可以使用功能绑定语法 obj::func
            "@babel/plugin-proposal-function-bind"
        ]
    }
}

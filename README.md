# Rhino

一个简单的浏览器引擎（DEMO）。

1. 解析 css 和 html 代码，生成 dom 和 stylesheet
2. 把 dom 和 stylesheet 组装成 style tree
3. 根据 style tree 生成 layout tree
4. 计算布局
5. 使用 Native 组件渲染
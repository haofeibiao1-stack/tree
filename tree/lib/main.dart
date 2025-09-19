import 'package:flutter/material.dart';

void main() {
  // 1. 替换为有效的网络图片URL（使用Flutter官方图标确保可访问）
  final String imageUrl = "https://p0.qhimg.com/t11ebd0e73367a37cba1af42507.png";
  // 2. 文本方向（从左到右）
  final TextDirection direct = TextDirection.ltr;
  // 3. 文本样式（黑色字体，增加字号提升可读性）
  final TextStyle style = TextStyle(
    color: Colors.black,
    fontSize: 16,
  );

  // 4. 启动应用（用MaterialApp包裹以避免渲染警告）
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false, // 隐藏调试横幅
    home: Container(
      color: Colors.white, // 白色背景
      child: Row(
        textDirection: direct, // 必须指定文本方向，否则会有警告
        mainAxisAlignment: MainAxisAlignment.center, // 子组件水平居中
        crossAxisAlignment: CrossAxisAlignment.center, // 子组件垂直居中
        children: [
          // 网络图片组件
          Image.network(
            imageUrl,
            width: 100,
            height: 100, // 补充高度，避免图片拉伸
            excludeFromSemantics: true, // 修复原代码拼写错误（少了's'）
            // 图片加载中显示进度条
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            // 图片加载失败显示错误图标
            errorBuilder: (context, error, stack) => const Icon(Icons.error),
          ),
          // 文本组件
          Text(
            "测试",
            textDirection: direct,
            style: style,
          ),
        ],
      ),
    ),
  ));
}

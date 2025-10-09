import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobalKey 状态保留测试（无路由）',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), // MyApp 仅返回 HomePage，不暴露 home 属性
      debugShowCheckedModeBanner: false,
    );
  }
}

// 首页：通过条件渲染切换 PageA 和 PageB，持有 PageA 的 GlobalKey
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showPageA = true; // 控制显示 PageA 还是 PageB
  // 持有 PageA 的 GlobalKey（公开 getter，供 PageA 访问）
  final GlobalKey<PageAState> _pageAKey = GlobalKey<PageAState>();

  // 公开 getter：让子组件（PageA）能获取到这个 GlobalKey
  GlobalKey<PageAState> get pageAKey => _pageAKey;

  @override
  Widget build(BuildContext context) {
    print('=== HomePage build（当前显示：${_showPageA ? "PageA" : "PageB"}） ===');
    return Scaffold(
      appBar: AppBar(title: const Text('首页（无路由）')),
      body: Center(
        // 条件渲染：切换 PageA 和 PageB
        child: _showPageA
            ? PageA(key: _pageAKey)  // 传入 GlobalKey
            : const PageB(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('--- 切换显示：${_showPageA ? "PageA → PageB" : "PageB → PageA"} ---');
          setState(() => _showPageA = !_showPageA);
        },
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }
}

// PageA：通过 BuildContext 找到父组件，获取 GlobalKey
class PageA extends StatefulWidget {
  const PageA({super.key});

  @override
  State<PageA> createState() => PageAState();
}

class PageAState extends State<PageA> {
  final TextEditingController _inputController = TextEditingController();
  String lastInput = ''; // 公开属性，供外部查看

  // 从父组件 _HomePageState 获取 GlobalKey（核心修正）
  GlobalKey<PageAState> get _pageAKey {
    // 通过 BuildContext 找到父组件 HomePage 的状态
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    assert(homeState != null, "PageA 必须在 HomePage 内部使用");
    return homeState!.pageAKey;
  }

  @override
  void initState() {
    super.initState();
    print('=== PageAState initState（首次创建） ===');
    print('PageAState 当前输入框内容：${_inputController.text}');
    _inputController.addListener(() {
      lastInput = _inputController.text;
      print('--- PageA 输入变化：$lastInput ---');
    });
  }

  @override
  void activate() {
    super.activate();
    print('=== PageAState activate（Element 复用，恢复活跃） ===');
    print('PageAState 复用后输入框内容：${_inputController.text}');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('=== PageAState deactivate（Element 失活，进入 inactive） ===');
    print('PageAState 失活时输入框内容：${_inputController.text}');
  }

  @override
  void dispose() {
    _inputController.dispose();
    print('=== PageAState dispose（State 卸载，资源释放） ===');
    print('PageAState 卸载时输入框内容：$lastInput');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('=== PageA build ===');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('我是 PageA（带 GlobalKey）', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: '输入内容（验证状态保留）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 检查 GlobalKey 状态（通过父组件获取的 Key）
              final hasElement = _pageAKey.currentContext != null;
              final currentState = _pageAKey.currentState;
              print('--- PageA 内部检查 Key 状态 ---');
              print('Element 是否存在：$hasElement');
              print('State 是否存在：${currentState != null}');
              print('当前输入内容：${currentState?.lastInput ?? "无"}');
            },
            child: const Text('检查 Key 状态'),
          ),
        ],
      ),
    );
  }
}

// PageB：普通无状态组件
class PageB extends StatelessWidget {
  const PageB({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== PageB build ===');
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('我是 PageB（无 GlobalKey）', style: TextStyle(fontSize: 20, color: Colors.red)),
          SizedBox(height: 20),
          Text('切换回 PageA 可验证状态是否保留', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
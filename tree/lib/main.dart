import 'package:flutter/material.dart';

void main() => runApp(const UpdateDebugApp());

class UpdateDebugApp extends StatelessWidget {
  const UpdateDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 更新流程调试',
      home: const UpdateDebugPage(),
      // 启用调试模式日志
      debugShowCheckedModeBanner: true,
    );
  }
}

class UpdateDebugPage extends StatefulWidget {
  const UpdateDebugPage({super.key});

  @override
  State<UpdateDebugPage> createState() => _UpdateDebugPageState();
}

class _UpdateDebugPageState extends State<UpdateDebugPage> {
  int _counter = 0;
  bool _toggle = false;
  String _childKey = 'initial_key';

  // 打印日志（带时间戳）
  void _log(String message) {
    final time = DateTime.now().toString().split(' ')[1];
    print('[$time] 父组件State: $message');
  }

  @override
  void initState() {
    super.initState();
    _log('initState 调用（初始化状态）');
  }

  @override
  void didUpdateWidget(covariant UpdateDebugPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log('didUpdateWidget 调用（Widget实例更新）');
    _log('  旧Widget哈希: ${oldWidget.hashCode}，新Widget哈希: ${widget.hashCode}');
  }

  @override
  void dispose() {
    _log('dispose 调用（组件销毁）');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log('build 调用（开始构建Widget树）');
    _log('  当前状态: counter=$_counter, toggle=$_toggle, childKey=$_childKey');

    return Scaffold(
      appBar: AppBar(title: const Text('更新流程调试')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态展示
            Text('计数器: $_counter', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('开关状态: ${_toggle ? "开" : "关"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // 子组件（Stateful）
            _logWidget(
              child: DebugStatefulChild(
                key: ValueKey(_childKey), // 用key控制复用
                data: '子组件数据: $_counter',
                toggle: _toggle,
              ),
              name: 'DebugStatefulChild',
            ),

            // 子组件（Stateless）
            _logWidget(
              child: DebugStatelessChild(
                data: '无状态子组件: ${_toggle ? "激活" : "未激活"}',
              ),
              name: 'DebugStatelessChild',
            ),
            const SizedBox(height: 20),

            // 操作按钮
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _log('👉 点击计数器按钮，调用setState');
                    setState(() => _counter++);
                  },
                  child: const Text('计数器+1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _log('👉 点击切换按钮，调用setState');
                    setState(() => _toggle = !_toggle);
                  },
                  child: const Text('切换状态'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _log('👉 点击改变子组件key，调用setState');
                    setState(() => _childKey = 'new_key_${DateTime.now().second}');
                  },
                  child: const Text('改变子组件Key'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 包装子组件，打印构建日志
  Widget _logWidget({required Widget child, required String name}) {
    final widgetHash = child.hashCode;
    _log('  构建$name: 哈希=$widgetHash');
    return child;
  }
}

// 调试用的Stateful子组件
class DebugStatefulChild extends StatefulWidget {
  final String data;
  final bool toggle;

  const DebugStatefulChild({
    super.key,
    required this.data,
    required this.toggle,
  });

  @override
  State<DebugStatefulChild> createState() => _DebugStatefulChildState();
}

class _DebugStatefulChildState extends State<DebugStatefulChild> {
  int _internalCount = 0; // 子组件内部状态

  void _log(String message) {
    final time = DateTime.now().toString().split(' ')[1];
    print('[$time] 子组件State: $message');
  }

  @override
  void initState() {
    super.initState();
    _log('initState 调用（子组件初始化）');
  }

  @override
  void didUpdateWidget(covariant DebugStatefulChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log('didUpdateWidget 调用（子组件Widget更新）');
    _log('  旧数据: ${oldWidget.data}, 新数据: ${widget.data}');
    _log('  旧Widget哈希: ${oldWidget.hashCode}, 新Widget哈希: ${widget.hashCode}');
  }

  @override
  void dispose() {
    _log('dispose 调用（子组件销毁）');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log('build 调用（子组件构建）');
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: widget.toggle ? Colors.blue[50] : Colors.grey[50],
      child: Column(
        children: [
          Text(widget.data, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('子组件内部计数: $_internalCount'),
          ElevatedButton(
            onPressed: () {
              _log('👉 子组件内部按钮点击，调用setState');
              setState(() => _internalCount++);
            },
            child: const Text('子组件计数+1'),
          ),
        ],
      ),
    );
  }
}

// 调试用的Stateless子组件
class DebugStatelessChild extends StatelessWidget {
  final String data;

  const DebugStatelessChild({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now().toString().split(' ')[1];
    print('[$time] 无状态子组件: build 调用（哈希=${hashCode}）');
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.green[50],
      child: Text(data, style: const TextStyle(fontSize: 16)),
    );
  }
}
// see example/hello

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  // Normally this would be obtained dynamically, but for this example
  // we hard-code the "remote" widgets into the app.
  //
  // Also, normally we would decode this with [decodeLibraryBlob] rather than
  // parsing the text version using [parseLibraryFile]. However, to make it
  // easier to demo, this uses the slower text format.
  static final RemoteWidgetLibrary _remoteWidgets = parseLibraryFile('''
    // The "import" keyword is used to specify dependencies, in this case,
    // the built-in widgets that are added by initState below.
    import core.widgets;
    // The "widget" keyword is used to define a new widget constructor.
    // The "root" widget is specified as the one to render in the build
    // method below.
    widget root = Container(
      color: 0xFFFFFF,
      child: Center(
        child: Text(text: ["Hello Remote, ", data.greet.name, "!"], textDirection: "ltr"),
      ),
    );
  ''');

  @override
  void initState() {
    super.initState();
    _runtime.update(
        const LibraryName(<String>['core', 'widgets']), createCoreWidgets());
    _runtime.update(const LibraryName(<String>['main']), _remoteWidgets);
    _data.update('greet', <String, Object>{'name': 'Widget'});
  }

  void _backPage() => context.go('/');

  static const String _title = "Remote Flutter Widget Page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _backPage),
        title: const Text(_title),
      ),
      body: RemoteWidget(
        runtime: _runtime,
        data: _data,
        widget: const FullyQualifiedWidgetName(
            LibraryName(<String>['main']), 'root'),
        onEvent: (String name, DynamicMap arguments) {
          // The example above does not have any way to trigger events, but if it
          // did, they would result in this callback being invoked.
          debugPrint('user triggered event "$name" with data: $arguments');
        },
      ),
    );
  }
}

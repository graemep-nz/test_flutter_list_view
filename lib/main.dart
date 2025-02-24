import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'article_frame3.dart';


String formatnum(int val) {
  var f = NumberFormat("###,###,###,###", "en_US");
  return f.format(val);
  //return (f.format(int.parse(val)));
}
int startupTime = DateTime.now().millisecondsSinceEpoch;


void commonDebugPrint(Object? obj, [String name = ""]) {
  if (obj is String) {
    String s1 = "##$name " + formatnum(DateTime.now().millisecondsSinceEpoch - startupTime);
    print(s1 + "  " + obj);   //
  } else {
    print(obj);
  }
}

void _dbprint(Object? obj) {
  commonDebugPrint(obj);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  UniqueKey  myUniqueKey = UniqueKey();
  FlutterListViewController  flutterListViewScrollController = FlutterListViewController();
  int delay = 500;
  int maxitems = 24;
  bool reatt = false;
  GlobalKey fred = GlobalKey(debugLabel: "a3");
  int catchLockupCounter = 0;
  int catchLockupIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // workaround for problem with flutter_list_view
      //checkForReattach();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20,),
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _dbprint("animate top");
                    flutterListViewScrollController.sliverController.animateToIndex(
                      0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                  },
                  child: const Text('top'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {
                    _dbprint("animate bottom");
                    flutterListViewScrollController.sliverController.animateToIndex(
                      maxitems - 1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
                  },
                  child: const Text('bottom'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {
                    delay += 20;  print("delay  $delay");
                  },
                  child: const Text('slower'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {
                    delay -= 20;  print("delay  $delay");
                  },
                  child: const Text('faster'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {    _dbprint("page down"); _scrollPageDown();  },
                  child: const Text('page down'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () { _dbprint("page up"); _scrollPageUp();  },
                  child: const Text('page up'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {  _dbprint("jump bottom"); _jumpToBottom();  },
                  child: const Text('jump bottom'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () { _dbprint("jump top"); _jumpToTop();  },
                  child: const Text('jump top'),
                ),
                SizedBox(width: 15,),
                ElevatedButton(
                  onPressed: () {
                      reatt = !reatt; _dbprint("reattach = $reatt"); setState(() {});
                  },
                  child: const Text('toggle reattach'),
                ),

              ],
            ),
            SizedBox(height:20),
            SizedBox(
              height: 290,
              child: bigWidget(),
            ),



          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  static Widget buildItem(int num) {
    DateTime abc = DateTime.now();
    return Container(
      height: 80,
      width: 480,
      key: ValueKey(num),
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child:
        GestureDetector(
          key: ValueKey(num),
          onTap: () => print("Tap $num"),
          child: Card(
            key: ValueKey(num),
            //color: Colors.blue[50],
            child:
              Padding(
                padding: const EdgeInsets.all(8.0),

                //padding: const EdgeInsets.fromLTRB(6, 2, 2, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text( "Date now  ${DateFormat.yMMMEd().add_jm().format(abc)}",
                           //"  ${formatnum(abc.millisecondsSinceEpoch - startupTime)}",
                      //style: TextStyle(color: Color.fromRGBO(33, 217, 17, 1.0),
                      //style: TextStyle(color: Color.fromRGBO(18,107,250, 1.0),
                      //style: TextStyle(color: Color.fromRGBO(0x9d, 0x42, 0xff, 1.0),
                      style: const TextStyle(color: Color(0xFF168BC4),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                      )
                    ),
                    Text("Index  $num")
                  ],
                ),
              ),
          ),
        )
    );
  }

  Widget smallWidget() {
    return ArticleFrame3(
      key: fred,
      frameTitle: "Announcements /News23",
      frameWidth: 480,
      frameHeight2: 240,
      allowHeightChange: true,
      myColNumber: 2,
      flutterListViewScrollController: flutterListViewScrollController,
      maxItemCountCallback: () => maxitems,
      clientListViewItemBuilder: (context, index) {
        return buildItem(index);
      },

      //listItems: List<NewsItem>.generate(30, (index) => NewsItem(date: DateTime.now()))
    );

  }
  Widget bigWidget() {
    final horizontalScrollController = ScrollController();
    return SizedBox(
      width: 350,
      height:290,
      child: Scrollbar(
        controller: horizontalScrollController,
        //thumbVisibility: false,
        //trackVisibility: true,
        child: SingleChildScrollView(
          //key: PageStorageKey(horizontalScrollController),
          scrollDirection: Axis.horizontal,
          controller: horizontalScrollController,
          child: Column(
            key: const ValueKey(123443648),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Something here"),
              SizedBox(height: 20,),
              //======================================================================================
              WidgetSize(
                onChange: (Size ns) {
                  // postFrameCallback
                  //frameSize2 = ns;
                },
                child: Container(
                  //constraints: BoxConstraints(maxHeight: frameHeight2, maxWidth: (frameWidth - 2 - (2*(borderWidth + 2)))   ),
                  child:
                      SizedBox(
                        height: 240,
                        width:350,
                        child: FlutterListView(
                          key: myUniqueKey,
                          controller: flutterListViewScrollController,
                          shrinkWrap: true,
                          cacheExtent: 20,  // pixels
                          delegate: FlutterListViewDelegate(
                            (BuildContext context, int index) {
                              _dbprint("xxxxxxxxxxxxxxxxx $index");
                              if (index == catchLockupIndex) {
                                if (++catchLockupCounter > 5) {
                                  if (catchLockupCounter == 6) {
                                    _dbprint(">>>>>>>>>>>>>  locked up");
                                  }
                                  return SizedBox();
                                }
                              } else {
                                catchLockupCounter = 0;
                                catchLockupIndex = index;
                              }

                              return buildItem(index);
                            },
                            childCount: maxitems,
                          )
                        ),
                      ),
                ),
              ),
              SizedBox(height:10),
              //==========================================================================================
            ],
          ),
        ),
      ),
    );

  }

  void _scrollPageDown() {
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.pageDown();
    }
  }

  void _scrollPageUp() {
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.pageUp();
    }
  }

  void _jumpToTop() {
      if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.jumpToIndex(0);
    }
  }

  /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    need this code in flutter_sliver_list_controller.dart line 58
    FlutterListViewElement? lastKnownListView;

    void attach(FlutterListViewElement listView) {
      _listView = listView;
      lastKnownListView = listView;
    }

    void checkForReattach() {
      if (_listView == null && lastKnownListView != null) {
        _listView = lastKnownListView;
      }
    }
  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

  void checkForReattach() {
    if (reatt && flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.checkForReattach();
    }
  }

  void _jumpToBottom() {
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.jumpToIndex(maxitems - 1);
    }
  }



}


class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function(Size) onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  _WidgetSizeState createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(_) async {
    var context = widgetKey.currentContext;
    //await Future.delayed(
      //  const Duration(milliseconds: 100)); // wait till the widget is drawn
    if (!mounted || context == null) return; // not yet attached to layout

    var newSize = context.size!;
    if (oldSize == newSize) return;
    oldSize = newSize;
    widget.onChange(newSize);
  }
}

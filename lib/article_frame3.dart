//******************************************************************
// Copyright 2024 Graeme F Prentice.  All rights reserved
//******************************************************************

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import "main.dart";

void _dbprint(Object? obj) {
  commonDebugPrint(obj);
}





enum articleFrameStatus {
  statusExtToolbarOff,
  statusExtToolbarOn,
}


class ArticleFrame3 extends StatefulWidget {
  final Color titleBarColor;
  final String frameTitle;
  final double frameWidth;
  final double frameHeight1;
  final double frameHeight2;
  final bool allowHeightChange;

  final TextEditingController?                widgetFrameTitleTextController;
  final int?                                  clientListViewItemCount;
  final int                                   clientListViewItemPos;
  int Function()?                             maxItemCountCallback;
  final Widget Function(BuildContext, int)?   clientListViewItemBuilder;
  //final IndexedWidgetBuilder?                 clientListViewSeparatorBuilder;
  final Widget?                               clientTopWidget;
  final Widget?                               listViewHeader;
  Widget Function()?                          clientTopWidgetFunction;
  BoxConstraints?                             clientTopWidgetConstraints;
  final int                                   clientRatio;
  //final MultiColumnScrollControllers?         multiColScroll;
  final int?                                  myColNumber;
  final void Function(articleFrameStatus)?    articleFrameStatusCallback;
  final void Function(State<ArticleFrame3> myState)? passbackStatefulWidget;
  final FlutterListViewController?            flutterListViewScrollController;
  final ValueNotifier?                        notifyRebuild;
  final GlobalKey                             myKey;
  final Widget?                               headerWidget;
  final bool                                  justFrame;

  ArticleFrame3({
    required super.key,
    required this.frameTitle,
    required this.frameWidth,
    this.widgetFrameTitleTextController,
    //this.multiColScroll,
    this.myColNumber = 1,
    this.clientListViewItemBuilder,
    this.maxItemCountCallback,
    this.clientListViewItemCount,
    this.clientListViewItemPos = 0,
    this.clientTopWidget,
    //this.clientListViewSeparatorBuilder,
    this.clientTopWidgetFunction,
    this.clientTopWidgetConstraints,
    this.titleBarColor = Colors.lightBlueAccent,
    this.frameHeight1 = 200,   // client widget
    this.frameHeight2 = 250,   // listview
    this.allowHeightChange = true,
    this.clientRatio = 4,  // out of 16
    this.articleFrameStatusCallback,
    this.passbackStatefulWidget,
    this.flutterListViewScrollController,
    this.headerWidget,
    this.notifyRebuild,
    this.justFrame = false,
    this.listViewHeader,

  }) : myKey = key as GlobalKey {
    maxItemCountCallback ??= () => clientListViewItemCount ?? 0;
    if (clientTopWidgetFunction == null && clientTopWidget != null) {
      clientTopWidgetFunction = () => clientTopWidget!;
    }
    if (clientTopWidgetFunction != null && clientTopWidgetConstraints == null) {
      clientTopWidgetConstraints = const BoxConstraints();  // no constraints
    }
  }
  @override
  State<ArticleFrame3> createState() => _ArticleFrame3();
}


class _ArticleFrame3 extends State<ArticleFrame3> /*with AutomaticKeepAliveClientMixin*/ {
  bool _twoToolbars = false;
  int lastIndex = 0;
  late double frameHeightX;
  late double frameWidth;
  late Widget Function()? clientWidgetFunction;
  ScrollController innerClientVerticalScrollController = ScrollController();
  late TextEditingController frameTitleTextController;
  //late IndexedWidgetBuilder clientListViewSeparatorBuilder;
  static const Color separatorColor = Colors.black12;
  bool hideWindow = false;
  bool articleScrollInViewRequested = false;
  late FlutterListViewController flutterListViewScrollController;
  late ValueNotifier?   xnotifyRebuild;
  int saveListLength = 0;
  int clientListViewItemPos = 0;
  UniqueKey myUniqueKey = UniqueKey();

  double frameHeight1 = 200;
  double frameHeight2 = 200;
  Size frameSize1 = const Size(0,0);
  Size frameSize2 = const Size(0,0);
  int catchLockupCounter = 0;
  int catchLockupIndex = 0;

  //@override
  //bool get wantKeepAlive => true; // Preserve state

  @override
  void initState() {
    super.initState();
    if (widget.passbackStatefulWidget != null) {
      widget.passbackStatefulWidget!(this);
    }
    if (widget.clientListViewItemPos != 0) {
      clientListViewItemPos = widget.clientListViewItemPos;
    }
    frameWidth = widget.frameWidth;
    frameHeight1 = widget.frameHeight1;
    frameHeight2 = widget.frameHeight2;
    frameSize1 = const Size(200, 300);
    frameSize2 = const Size(200, 300);
    _twoToolbars = false;
    frameTitleTextController = TextEditingController(text: widget.frameTitle);
    flutterListViewScrollController = widget.flutterListViewScrollController ?? FlutterListViewController();
    //clientListViewSeparatorBuilder = widget.clientListViewSeparatorBuilder ??
    //   (_, __) => const Divider(height: 1.0, indent : 3, endIndent: 3, color: separatorColor);
    xnotifyRebuild = widget.notifyRebuild;
    setListener();
  }

  @override
  void didUpdateWidget(covariant ArticleFrame3 oldWidget) {
    frameWidth = widget.frameWidth;
    frameHeight1 = widget.frameHeight1;
    frameHeight2 = widget.frameHeight2;
    frameTitleTextController.text = widget.frameTitle;
    //flutterListViewScrollController = widget.flutterListViewScrollController ?? FlutterListViewController();
    //clientListViewSeparatorBuilder = widget.clientListViewSeparatorBuilder ??
    //   (_, __) => const Divider(height: 1.0, indent : 3, endIndent: 3, color: separatorColor);
    if (xnotifyRebuild != null && !identical(xnotifyRebuild, widget.notifyRebuild)) {
      removeListener();
      xnotifyRebuild = widget.notifyRebuild;
      setListener();
    }
    super.didUpdateWidget(oldWidget);
  }

  void setListener() {
    if (xnotifyRebuild != null) {
      xnotifyRebuild!.addListener(callSetState);
    }
  }
  void removeListener() {
    if (xnotifyRebuild != null) {
      xnotifyRebuild!.removeListener(callSetState);
    }
  }

  void callSetState() {
    setState(() {});
  }

  @override
  void dispose() {
    frameTitleTextController.dispose();
    removeListener();
    super.dispose();
  }


  Future<void> _runsAfterBuild() async {
    // https://stackoverflow.com/questions/49466556/flutter-run-method-on-widget-build-complete
    // This code runs after build ...
    if (widget.myKey != null && widget.myKey!.currentContext != null) {
      Scrollable.ensureVisible(
        widget.myKey!.currentContext!,
        duration: const Duration(milliseconds: 700),
       );
    }
  }

  Future<void> _runsAfterBuild2() async {
      flutterListViewScrollController.sliverController.jumpToIndex(widget.maxItemCountCallback!() - 2);
  }

  Future<void> _runsAfterBuild3() async {
    if (widget.myKey != null && widget.myKey!.currentContext != null) {
      Scrollable.ensureVisible(widget.myKey!.currentContext!, duration: const Duration(milliseconds: 700));
    }
    flutterListViewScrollController.sliverController.jumpToIndex(-1);
  }


  @override
  Widget build(BuildContext context23) {
    //super.build(context); // Important for AutomaticKeepAlive

    //_dbprint("3333 building  ${flutterListViewScrollController}  ${widget.frameTitle}");
    if (clientListViewItemPos != 0) {
      if (clientListViewItemPos == -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop() );
      }
      clientListViewItemPos = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // workaround for bug in flutter_list_view
      checkForReattach();
    });
    
    if (articleScrollInViewRequested) {
      articleScrollInViewRequested = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.myKey.currentContext != null) {
          Timer(const Duration(milliseconds: 100), () async {
            Scrollable.ensureVisible(widget.myKey.currentContext!, duration: const Duration(milliseconds: 700));
          });
        }
      });
    }

    if (innerClientVerticalScrollController.hasClients) {
      //print("Extent >>>>>  ${innerClientVerticalScrollController.position.maxScrollExtent}   ${innerClientVerticalScrollController.position.extentTotal}");
    }
    //const Color borderColor = Color(0xFF42A5F5);  // alpha, R,G,B
    const Color borderColor = Color(0xFF68b6f7);  // alpha, R,G,B
    const double borderWidth = 0.8;
    double frameWidth = widget.frameWidth;

    Widget getIconButton({required IconData icon, required String tooltip,
        required void Function() onPressed, Color color = Colors.amberAccent  }) {
      return IconButton(
        key: ObjectKey(icon),
        icon: Icon(icon),
        iconSize: 28,
        tooltip: tooltip,
        splashRadius: 3,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints( maxHeight: 28, ),
        color: color,
        hoverColor: Colors.grey,
        onPressed: onPressed,
        padding: const EdgeInsets.only(top: 0.0, bottom: 0.0, left:5, right:5),
      );
    }

    String tt1 = "Much smaller window";
    String tt2 = "Much bigger window";
    String tt3 = "Smaller window";
    String tt4 = "Bigger window";

    void noTooltips() {
      tt1 = tt2 = tt3 = tt4 = "";
    }

    void makeSmallerWindow([int amount = 40]) {
      noTooltips();
      //_dbprint("smaller $amount");
      // get the current actual height of "clientWidget" as measured by WidgetSize
      frameHeight1 = frameSize1.height;
      if (frameHeight1 - amount > 100) {
        frameHeight1 -= amount;
        articleScrollInViewRequested = true;
        setState(() {});
        //_dbprint("smaller 1 now $frameHeight1");
      }
      // get the current actual height of the ListView as measured by WidgetSize
      frameHeight2 = frameSize2.height;
      if (frameHeight2 - amount > 100) {
        frameHeight2 -= amount;
        articleScrollInViewRequested = true;
        setState(() {});
        //_dbprint("smaller 2 now $frameHeight2");
      }
    }

    void makeBiggerWindow([int amount = 40]) {
      noTooltips();
      //_dbprint("bigger $amount");
      // get the current actual height of "clientWidget" as measured by WidgetSize
      frameHeight1 = frameSize1.height;
      if (frameHeight1 + amount < 2600) {
        frameHeight1 += amount;
        articleScrollInViewRequested = true;
        setState(() {});
        //_dbprint("bigger 1 now $frameHeight1");
      }
      // get the current actual height of the ListView as measured by WidgetSize
      frameHeight2 = frameSize2.height;
      if (frameHeight2 + amount < 2600) {
        frameHeight2 += amount;
        articleScrollInViewRequested = true;
        setState(() {});
        //_dbprint("bigger 2 now $frameHeight2");
      }
    }

    void makeMuchSmallerWindow() {
      makeSmallerWindow(400);
    }

    void makeMuchBiggerWindow() {
      makeBiggerWindow(400);
    }

    void outerScrollHelper(ScrollController innerController) {
      return;
      /*if (widget.multiColScroll == null || !widget.multiColScroll!.deviceRequiresNestedScrollHelper) {
        return;
      }
      // nested scrolling on Android doesn't propagate to an outer scroll widget properly so we do it explicitly here

      ScrollController myOuterController = widget.multiColScroll!.getMyOuterScrollController(widget.myColNumber!);
      //print("Notiffff  ${innerClientVerticalScrollController.offset}  ${innerClientVerticalScrollController.position.maxScrollExtent}  outer ${myOuterController.offset}");
      if (innerController.offset + 1 >= innerController.position.maxScrollExtent) {
        // scrolling down
        if (myOuterController.offset < myOuterController.position.maxScrollExtent) {
          var v1 = myOuterController.position.maxScrollExtent - myOuterController.offset;
          myOuterController.jumpTo(myOuterController.offset + min(v1,20));
        }
      }
      else if (innerController.offset <= (innerController.position.minScrollExtent + 1)) {
        // scrolling up
        if (myOuterController.offset > myOuterController.position.minScrollExtent) {
          var v1 = myOuterController.offset  - myOuterController.position.minScrollExtent;
          myOuterController.jumpTo(myOuterController.offset - min(v1,20));
        }
      }*/
    }

    BoxConstraints calcClientWidgetSize(double avail) {
      double minWidth = widget.clientTopWidgetConstraints!.minWidth < avail ? widget.clientTopWidgetConstraints!.minWidth : avail;
      double maxWidth = widget.clientTopWidgetConstraints!.maxWidth < avail ? widget.clientTopWidgetConstraints!.maxWidth : avail;
      if (maxWidth < minWidth) maxWidth = minWidth;
      return BoxConstraints(minWidth: minWidth, maxWidth: maxWidth, maxHeight:frameHeight1 );
    }

    final horizontalScrollController = ScrollController();
    final clientVerticalScrollController2 = ScrollController();

    Widget abc = Column(
      key : ValueKey(widget.myKey),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //tryTable(),
        //SizedBox(height:50),
        Container(
          width: frameWidth,
          decoration: BoxDecoration(
            border: const Border(
              top: BorderSide(color: borderColor, width: borderWidth),
              left: BorderSide(color: borderColor, width: borderWidth),
              right: BorderSide(color: borderColor, width: borderWidth),
              bottom: BorderSide(color: borderColor, width:borderWidth),
            ),
            borderRadius: const BorderRadius.only(topLeft:Radius.circular(6), topRight:Radius.circular(6)),
            color: widget.titleBarColor,
          ),
          child: LimitedBox(
            maxHeight: 300,
            maxWidth: frameWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height:1),
                Row(
                  key: const ValueKey(1137682936),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: frameWidth - 240,
                        child: TextField(
                          controller: widget.widgetFrameTitleTextController ?? frameTitleTextController,
                          onTap: () {
                            if (!widget.justFrame) {
                              hideWindow = !hideWindow;
                              articleScrollInViewRequested = true;
                              setState(() {});
                            }
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
                              isDense: true,
                            ),
                          readOnly: true,
                          minLines: 1,
                          maxLines: 8,
                          style: const TextStyle(
                            color: Colors.white, /*fontFamily: 'kkk' ,*/ fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),

                    if (!widget.justFrame) Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 4),
                        if (widget.allowHeightChange) getIconButton(
                          icon: Icons.menu_open,
                          tooltip: (_twoToolbars ? '\nLess options' : '\nMore options'),
                          color : Colors.amber,
                          onPressed: () {
                            _twoToolbars = !_twoToolbars;
                            if (widget.articleFrameStatusCallback != null) {
                              widget.articleFrameStatusCallback!(
                                _twoToolbars ? articleFrameStatus.statusExtToolbarOn : articleFrameStatus.statusExtToolbarOff);
                            }
                            articleScrollInViewRequested = true;
                            setState(() {});
                          }
                        ),
                        getIconButton(icon: Icons.first_page, tooltip: '', /*'\nGo to start',*/ onPressed: _scrollToTop),
                        getIconButton(icon: Icons.last_page, tooltip:'', /*'\nGo to end',*/ onPressed: _scrollToBottom),
                        SizedBox(width: 4),
                        getIconButton(icon: Icons.navigate_before, tooltip:'', /*'\nPrevious page',*/ onPressed: _scrollPageUp),
                        getIconButton(icon: Icons.navigate_next, tooltip:'', /*'\nNext page' ,*/
                                 onPressed: _scrollPageDown),
                      ],
                    ),
                  ],
                ),
                if (_twoToolbars && !widget.justFrame) const SizedBox(height:6),
                if (_twoToolbars && !widget.justFrame) Row(
                  key: const ValueKey(113755762936),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("  1 of 1",
                      style: TextStyle(
                        color: Colors.blueAccent, /*fontFamily: 'kkk' ,*/ fontWeight: FontWeight.bold, fontSize: 16)),
                    const Expanded(child:SizedBox(width:10)),

                    getIconButton(icon: Icons.unfold_less_double, tooltip: tt1, /*color: Colors.orange, */onPressed: makeMuchSmallerWindow),
                    getIconButton(icon: Icons.unfold_more_double, tooltip: tt2, /*color: Colors.orange,*/ onPressed: makeMuchBiggerWindow),
                    SizedBox(width: 8),
                    getIconButton(icon: Icons.unfold_less, tooltip: tt3, /*color: Colors.orange,*/ onPressed: makeSmallerWindow),
                    getIconButton(icon: Icons.unfold_more, tooltip: tt4, /*color: Colors.orange,*/ onPressed: makeBiggerWindow),
                  ],
                ),
                SizedBox(height:1),
              ],
            ),
          ),
        ),

        SizedBox(
          width: frameWidth,
          child: Container(
            constraints: BoxConstraints( maxWidth: frameWidth, /*maxHeight: frameHeightX*/),
            //height: frameHeightX,
            width: frameWidth,
            decoration: const BoxDecoration(
              //color: Colors.white70,
              border: Border(
                top: BorderSide.none,
                left: BorderSide(color: borderColor, width: borderWidth + 2),
                right: BorderSide(color: borderColor, width: borderWidth + 2),
                bottom: BorderSide(color: borderColor, width:borderWidth + 2),
              ),

              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(6), bottomRight:Radius.circular(6)),
            ),
            child: Column(
              children: [
                if (hideWindow) GestureDetector(
                  child: SizedBox(
                    width:frameWidth,
                    height:25,
                    child: const Align(
                      alignment:Alignment.centerLeft,
                      child:Text("   Tap here to show this widget.")
                    )
                  ),
                  onTap: ()  {
                    // if (widget.myKey != null && widget.myKey!.currentContext != null) {
                    //   articleScrollInViewRequested = true;
                    // }
                    hideWindow = false;
                    setState(() {});
                  },
                ),
                // maybe use align
                if (!hideWindow && widget.headerWidget != null) SizedBox(
                  width: frameWidth,
                  child: widget.headerWidget,
                ),
                if (!hideWindow) SizedBox(
                  width: frameWidth,
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

                          //======================================================================================
                          // can have either or both clientWidget and ListView  TODO
                          if (widget.clientTopWidgetFunction != null) WidgetSize(
                            onChange: (Size ns) {
                              // postFrameCallback
                              frameSize1 = ns;
                            },
                            child: Container(
                              constraints: calcClientWidgetSize((frameWidth - 2 - (2*(borderWidth + 2)))),
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  outerScrollHelper((widget.clientListViewItemBuilder == null) ?
                                           innerClientVerticalScrollController : clientVerticalScrollController2);
                                  return false;  // allow further processing of the notification
                                },
                                child: CustomScrollView(
                                  key: PageStorageKey((widget.clientListViewItemBuilder == null) ?
                                         innerClientVerticalScrollController : clientVerticalScrollController2),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  controller: (widget.clientListViewItemBuilder == null) ?
                                          innerClientVerticalScrollController : clientVerticalScrollController2,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: widget.clientTopWidgetFunction!()
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (widget.listViewHeader != null)
                            SizedBox(width: frameWidth - 10, child: widget.listViewHeader!),
                          //======================================================================================
                          if (widget.clientListViewItemBuilder != null) WidgetSize(
                            onChange: (Size ns) {
                              // postFrameCallback
                              frameSize2 = ns;
                            },
                            child: Container(
                              constraints: BoxConstraints(maxHeight: frameHeight2, maxWidth: (frameWidth - 2 - (2*(borderWidth + 2)))   ),
                              child:
                                // MyListView(
                                //   key: myUniqueKey,
                                //   controller: flutterListViewScrollController,
                                //   itemBuilder: widget.clientListViewItemBuilder!, // Assuming clientListViewItemBuilder is not null
                                //   widget.maxItemCountCallback: maxItemCountCallback!, // Assuming maxItemCountCallback is not null
                                // ),
                              FlutterListView(
                                key: myUniqueKey,
                                controller: flutterListViewScrollController,
                                shrinkWrap: true,  // true doesn't work correctly
                                cacheExtent: 20,  // pixels

                                delegate: FlutterListViewDelegate(

                                  (BuildContext context, int index) {
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

                                    _dbprint("xxxxxxxxxxxxxxxxx $index");
                                    return widget.clientListViewItemBuilder!(context, index);
                                    //print("Building index: $index");
                                    //return Text("Item $index");
                                  },
                                  childCount: saveListLength = widget.maxItemCountCallback!(),
                                )
                              ),
                            ),
                          ),
                          SizedBox(height:10),
                          //==========================================================================================
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    );

    return abc;
  }

  void _pageDownHelper(ScrollController scrollController) {
    if (scrollController.hasClients) {
      final viewportHeight = scrollController.position.extentInside;
      final newOffset = (scrollController.offset + viewportHeight - 24)
                            .clamp(0.0, scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _pageUpHelper(ScrollController scrollController) {
    if (scrollController.hasClients) {
      final viewportHeight = scrollController.position.extentInside;
      final newOffset = (scrollController.offset - (viewportHeight - 24))
                       .clamp(0.0, scrollController.position.maxScrollExtent);
      scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  void _scrollPageDown() {
    //_dbprint("%%%%%%  pg dn");
    if (widget.clientListViewItemBuilder == null) {
      _pageDownHelper(innerClientVerticalScrollController);
      return;
    }
    if (saveListLength <= 1) return;
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.pageDown();
    }
  }

  void _scrollPageUp() {
    //_dbprint("%%%%%%  pg up");
    if (widget.clientListViewItemBuilder == null) {
      _pageUpHelper(innerClientVerticalScrollController);
      return;
    }
    if (saveListLength <= 1) return;
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.pageUp();
    }
  }

  void _scrollToTop() {
    //_dbprint("%%%%%%  scroll top");
    if (widget.clientListViewItemBuilder == null) {
      if (innerClientVerticalScrollController.hasClients) {
        final position = innerClientVerticalScrollController.position.minScrollExtent;
        innerClientVerticalScrollController.jumpTo(position);
      }
      return;
    }
    if (saveListLength <= 1) return;
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.animateToIndex(
          0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }

  /* need this code in flutter_sliver_list_controller.dart line 58
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
  */

  void checkForReattach() {
    if (flutterListViewScrollController.hasClients) {
      flutterListViewScrollController.sliverController.checkForReattach();
    }
  }

  void _scrollToBottom() {
    //_dbprint("%%%%%%  scroll bot");
    if (widget.clientListViewItemBuilder == null) {
      if (innerClientVerticalScrollController.hasClients) {
          final position = innerClientVerticalScrollController.position.extentTotal + 200;
          innerClientVerticalScrollController.jumpTo(position);
      }
      return;
    }
    if (saveListLength <= 1) return;
    if (flutterListViewScrollController.hasClients && saveListLength > 0) {
      flutterListViewScrollController.sliverController.animateToIndex(
          saveListLength - 1, duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }
  }



}

class MyListView extends StatelessWidget {
  final Key key;
  final FlutterListViewController controller;
  final Widget Function(BuildContext, int) itemBuilder;
  final int Function() maxItemCountCallback;

  const MyListView({
    required this.key,
    required this.controller,
    required this.itemBuilder,
    required this.maxItemCountCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterListView(
      key: key,
      controller: controller,
      shrinkWrap: true,
      cacheExtent: 20,
      delegate: FlutterListViewDelegate(
        itemBuilder,
        childCount: maxItemCountCallback(),
      ),
    );
  }
}


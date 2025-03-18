import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            fontFamily: "Montserrat"),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>{};

  void toggleFavorite([WordPair? wordPair]) {
    wordPair ??= current;
    if (favorites.contains(wordPair)) {
      favorites.remove(wordPair);
    } else {
      favorites.add(wordPair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair wordPair) {
    favorites.remove(wordPair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError("No widget for $selectedIndex.");
    }

    // The container for the current page, with its background color and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.onSurfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          // Use a more mobile-friendly layout with BottomNavigationBar on narrow screens.
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                  child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite), label: "Favorites"),
                ],
                currentIndex: selectedIndex,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ))
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 720,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text("Favorites"),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    // print('Selected Destination: $value');
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(child: mainArea),
            ],
          );
        }
      }),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var wordPair = appState.current;

    const bPadding = EdgeInsets.all(10.0);
    var bTextStyle = TextStyle(
        fontFamily: "FiraCode", fontWeight: FontWeight.w700, fontSize: 18);

    IconData icon;
    if (appState.favorites.contains(wordPair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('A random AMAZING idea:'),
            Expanded(
              flex: 3,
              child: HistoryListView(),
            ),
            SizedBox(
              height: 10.0,
            ),
            BigCard(wordPair: wordPair),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavorite();
                    },
                    icon: Icon(icon),
                    label: Padding(
                      padding: bPadding,
                      child: Text("Like", style: bTextStyle),
                    )),
                SizedBox(
                  width: 16.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    // print("Button pressed!");
                    appState.getNext();
                  },
                  child: Padding(
                    padding: bPadding,
                    child: Text(
                      "Next",
                      style: bTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.wordPair,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      letterSpacing: 2,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      // fontFamily: "FiraCode",
    );

    return Card(
        elevation: 20.0,
        color: theme.colorScheme.primary,
        surfaceTintColor: Colors.lightGreen,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedSize(
            duration: Duration(milliseconds: 200),
            // Make sure that the compound word wraps correctly when the window
            // is too narrow.
            child: MergeSemantics(
              child: Wrap(
                children: [
                  Text(
                    wordPair.first,
                    style: style.copyWith(fontWeight: FontWeight.w200),
                  ),
                  Text(
                    wordPair.second,
                    style: style.copyWith(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoritesSet = appState.favorites;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: ListView(
        children: [
          FavoritesTitleCard(),
          if (favoritesSet.isNotEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Text(
                  "¡You have ${favoritesSet.length} Favorites!",
                  style: TextStyle(
                      fontFamily: "FiraCode",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            FavoritesDataTable()
          ] else ...[
            Center(
              child: Text(
                "No Favorites Yet.",
                style: TextStyle(
                    fontFamily: "FiraCode",
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FavoritesTitleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.surfaceTint,
      fontSize: 30.0,
      fontWeight: FontWeight.w700,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("My Favorites", style: style),
            SizedBox(width: 10.0),
            Icon(
              Icons.favorite,
              color: Colors.red,
              size: 36.0,
            )
          ],
        ),
      ),
    );
  }
}

class FavoritesDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var favoritesSet = appState.favorites;

    var cTextStyle = TextStyle(fontWeight: FontWeight.w700);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: DataTable(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 10.0,
                spreadRadius: 5.0,
                offset: Offset(5.0, 5.0),
                blurStyle: BlurStyle.solid,
              )
            ],
          ),
          border: TableBorder.all(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(10.0)),
          headingRowColor: WidgetStateColor.resolveWith((states) {
            return Colors.blue.shade100;
          }),
          dataRowColor: WidgetStateColor.resolveWith((states) {
            return Colors.white;
          }),
          columns: <DataColumn>[
            DataColumn(
                label: Expanded(
                    child: Text(
              "N°",
              style: cTextStyle,
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              "Word Pair",
              style: cTextStyle,
              textAlign: TextAlign.center,
            ))),
            DataColumn(
                label: Expanded(
                    child: Text(
              "Actions",
              style: cTextStyle,
              textAlign: TextAlign.center,
            ))),
          ],
          rows: <DataRow>[
            for (var i = 0; i < favoritesSet.length; i++)
              DataRow(cells: <DataCell>[
                DataCell(Center(
                  child: Text(
                    "${i + 1}",
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    favoritesSet.elementAt(i).asPascalCase,
                  ),
                )),
                DataCell(Center(
                  child: IconButton(
                    onPressed: () {
                      appState.removeFavorite(favoritesSet.elementAt(i));
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      semanticLabel: "Delete",
                    ),
                    color: theme.colorScheme.primary,
                  ),
                ))
              ])
          ],
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({super.key});

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  // Needed so that [MyAppState] can tell [AnimatedList] below to animate new items.
  final _key = GlobalKey();

  // Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asPascalCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

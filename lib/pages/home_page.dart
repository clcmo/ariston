import 'package:ariston/model/home_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int actualPage = 0;
  PageController pc;

  List<HomeListModel> homeListModel = [
    HomeListModel(title: "Academias", icon: Icon(Icons.sports_gymnastics))
  ];

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: actualPage);
  }

  setActualPage(page) {
    setState(() {
      actualPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: pc,
          children: [
            //colocar as páginas referentes
          ],
          onPageChanged: setActualPage,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: actualPage,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                //criar lista e laço
                icon: homeListModel[0].icon,
                label: homeListModel[0].title)
          ],
          onTap: (page) {
            pc.animateToPage(
              page,
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
            );
          },
          // backgroundColor: Colors.grey[100],
        ));
  }
}

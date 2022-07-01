/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'dart:convert';

import 'package:blackhole/CustomWidgets/custom_physics.dart';
import 'package:blackhole/CustomWidgets/empty_screen.dart';
import 'package:blackhole/Helpers/countrycodes.dart';
import 'package:blackhole/Screens/Search/search.dart';
import 'package:blackhole/Screens/Settings/setting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

List items = [];
dynamic globalItems = [];
List cachedItems = [];
dynamic cachedGlobalItems = [];
bool fetched = false;
bool emptyRegional = false;
bool emptyGlobal = false;

class TopCharts extends StatefulWidget {
  final PageController pageController;
  const TopCharts({Key? key, required this.pageController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TopPageState();
}

/*ass TopChartsState extends State<TopCharts>
    with AutomaticKeepAliveClientMixin<TopCharts> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext cntxt) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.spotifyTopCharts,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: (rotated && screenWidth < 1050)
            ? null
            : Builder(
                builder: (BuildContext context) {
                  return Transform.rotate(
                    angle: 22 / 7 * 2,
                    child: IconButton(
                      color: Theme.of(context).iconTheme.color,
                      icon: const Icon(
                        Icons.horizontal_split_rounded,
                      ),
                      onPressed: () {
                        Scaffold.of(cntxt).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(cntxt)
                          .openAppDrawerTooltip,
                    ),
                  );
                },
              ),
      ),
      body: NotificationListener(
        onNotification: (overscroll) {
          if (overscroll is OverscrollNotification &&
              overscroll.overscroll != 0 &&
              overscroll.dragDetails != null) {
            widget.pageController.animateToPage(
              overscroll.overscroll < 0 ? 0 : 2,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 150),
            );
          }
          return true;
        },
        child: Column(
         // physics: const CustomPhysics(),
          children: [
            ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(),
              builder: (BuildContext context, Box box, Widget? widget) {
                return TopPage(
                  region: CountryCodes
                      .countryCodes[box.get('region', defaultValue: 'India')]
                      .toString(),
                );
              },
            ),
            const TopPage(
              region: 'global',
            ),
          ],
        ),
      ),
    );
  }
}
*/
Future<dynamic> scrapData() async {
  // print('starting expensive operation');
  List result = [];
  final HtmlUnescape unescape = HtmlUnescape();
  const String authority =
      'https://charts-spotify-com-service.spotify.com/public/v0/charts';
  final Response res = await get(Uri.parse(authority));
  if (res.statusCode != 200) return List.empty();
  dynamic data = jsonDecode(res.body)["chartEntryViewResponses"][0]["entries"];
  for (int i = 0; i < (data as List).length; i++) {
    dynamic m = data[i];
    dynamic meta = m["trackMetadata"];
    result.add({
      'id': "",
      'image': meta["displayImageUri"],
      'position': m["chartEntryData"]["currentRank"],
      'title': meta["trackName"],
      'album': '',
      'artist': meta["artists"][0]["name"],
      'streams': "",
      'region': "",
    });
  }
  // print('finished expensive operation');
  return result;
}

class TopPageState extends State<TopCharts> {
  Future<void> getData() async {
    fetched = true;
    final dynamic temp = await scrapData();
    setState(() {
      bool empty = (globalItems as List).isEmpty;
      globalItems = temp;
      if (!empty) {
        cachedGlobalItems = globalItems;
        emptyGlobal = empty && (cachedGlobalItems as List).isEmpty;
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched) {
      //  getCachedData();
      getData();
    }
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;

    final dynamic showList = globalItems;
    final bool isListEmpty = (cachedGlobalItems as List).isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.spotifyTopCharts,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        // TODO: FIX Leading
        /*leading: (rotated && screenWidth < 1050)
            ? null
            : Builder(
                builder: (BuildContext context) {
                  return Transform.rotate(
                    angle: 22 / 7 * 2,
                    child: IconButton(
                      color: Theme.of(context).iconTheme.color,
                      icon: const Icon(
                        Icons.horizontal_split_rounded,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    ),
                  );
                },
              ),*/
      ),
      body: Column(
        children: [
          if ((showList as List).length == 0)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: showList.length,
                itemExtent: 70.0,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          const Image(
                            image: AssetImage('assets/cover.jpg'),
                          ),
                          if (showList[index]['image'] != '')
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: showList[index]['image'].toString(),
                              errorWidget: (context, _, __) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/cover.jpg'),
                              ),
                              placeholder: (context, url) => const Image(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/cover.jpg'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    title: Text(
                      showList[index]['position'] == null
                          ? '${showList[index]["title"]}'
                          : '${showList[index]['position']}. ${showList[index]["title"]}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${showList[index]['artist']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(
                            query: showList[index]['title'].toString(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

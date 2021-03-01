import 'package:flutter/material.dart';
import 'package:metuhub/menu/clubs/club_detail.dart';
import 'package:metuhub/menu/clubs/clubs_page.dart';

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeData(primaryColor: Colors.white)
        : ThemeData.dark();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.length < 2
        ? randomList
        : clubNames
            .where((p) => p.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            var id;
            clubList.forEach((element) {
              if (element["name"] == suggestionList[index]) {
                id = element["id"];
              }
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(
                          clubId: id,
                        )));
          },
          trailing: Icon(
            Icons.call_made,
            size: 20,
          ),
          title: Text(suggestionList[index]),
          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        ),
        itemCount: suggestionList.length,
      ),
    );
  }
}

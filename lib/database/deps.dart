import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Departments extends StatefulWidget {
  final String current;

  const Departments({Key key, this.current}) : super(key: key);
  @override
  _DepartmentsState createState() => _DepartmentsState();
}

String currentDept;

class _DepartmentsState extends State<Departments> {
  // ignore: non_constant_identifier_names
  final String url_tr = "deps/deps_tr.json";
  // ignore: non_constant_identifier_names
  final String url_en = "deps/deps_en.json";
  List _data = [];
  List _dataForDisplay = [];
  String _selectedDept;

  @override
  void initState() {
    if (widget.current != null) {
      _selectedDept = widget.current;
    } else {}

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      this.getJsonData();
    });
    super.initState();
  }

  getJsonData() async {
    final String url = context.locale == Locale("tr") ? url_tr : url_en;
    var response = await rootBundle.loadString(url);

    setState(() {
      var convertDataToJson = jsonDecode(response);

      _data = convertDataToJson["departments"];
      _dataForDisplay = _data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.6,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              "sel_deps".tr(),
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[300],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 58,
              width: MediaQuery.of(context).size.width / 2,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "cancel".tr(),
                ),
              ),
            ),
            SizedBox(
              height: 58,
              width: MediaQuery.of(context).size.width / 2,
              child: TextButton(
                onPressed: _selectedDept != null
                    ? () {
                        currentDept = _selectedDept;
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  "ok".tr(),
                  style: TextStyle(
                      color:
                          _selectedDept != null ? Colors.black : Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
      body: _data.length == 0
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                child: ListView.builder(
                  itemCount: _dataForDisplay.length + 1,
                  itemBuilder: (context, index) {
                    return index == 0
                        ? _searchBar()
                        : departmentBuilder(index - 1);
                  },
                ),
              ),
            ),
    );
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'search'.tr(), prefixIcon: Icon(Icons.search)),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _dataForDisplay = _data.where((note) {
              var noteTitle = note.toLowerCase();
              return noteTitle.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  departmentBuilder(index) {
    return Column(
      children: <Widget>[
        Ink(
          height: 66,
          decoration: BoxDecoration(
            color: _selectedDept == _dataForDisplay[index]
                ? Colors.grey[300]
                : null,
          ),
          child: ListTileTheme(
            selectedColor: Colors.black,
            child: ListTile(
              selected: _selectedDept == _dataForDisplay[index] ? true : false,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dataForDisplay[index],
                    ),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedDept = _dataForDisplay[index];
                });
              },
            ),
          ),
        )
      ],
    );
  }
}

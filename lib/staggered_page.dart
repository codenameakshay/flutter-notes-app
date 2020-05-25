import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:multi_screen/notes.dart';
import 'package:multi_screen/SqliteHandler.dart';
import 'package:multi_screen/utility.dart';
import 'package:multi_screen/staggered_tile.dart';
import 'package:multi_screen/main_page.dart';

class StaggeredGridPage extends StatefulWidget {
  final notesViewType;
  const StaggeredGridPage({Key key, this.notesViewType}) : super(key: key);
  @override
  _StaggeredGridPageState createState() => _StaggeredGridPageState();
}

class _StaggeredGridPageState extends State<StaggeredGridPage> {

  var  noteDB = NotesDBHandler();
  List<Map<String, dynamic>> _allNotesInQueryResult = [];
  viewType notesViewType ;

@override
  void initState() {
    super.initState();
    this.notesViewType = widget.notesViewType;
  }

@override void setState(fn) {
    super.setState(fn);
    this.notesViewType = widget.notesViewType;
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _stagKey = GlobalKey();
    if(CentralStation.updateNeeded) {  retrieveAllNotesFromDatabase();  }
    return Container(child: Padding(padding:  _paddingForView(context) , child:
      new StaggeredGridView.count(key: _stagKey,
        crossAxisSpacing: 6, mainAxisSpacing: 6,
        crossAxisCount: _colForStaggeredView(context),
        children: List.generate(_allNotesInQueryResult.length, (i){ return _tileGenerator(i); }),
      staggeredTiles: _tilesForView() ,
          ),
        )
      );
  }

  int _colForStaggeredView(BuildContext context) {
      if (widget.notesViewType == viewType.List) { return 1; }
      // for width larger than 600, return 3 irrelevant of the orientation to accommodate more notes horizontally
      return MediaQuery.of(context).size.width > 600 ? 3 : 2 ;
  }

 List<StaggeredTile> _tilesForView() { // Generate staggered tiles for the view based on the current preference.
  return List.generate(_allNotesInQueryResult.length,(index){ return StaggeredTile.fit( 1 ); }
  ) ;
}

EdgeInsets _paddingForView(BuildContext context){
  double width = MediaQuery.of(context).size.width;
  double padding ;
  double top_bottom = 8;
  if (width > 500) {
    padding = ( width ) * 0.05 ; // 5% padding of width on both side
  } else {
    padding = 8;
  }
  return EdgeInsets.only(left: padding, right: padding, top: top_bottom, bottom: top_bottom);
}


 MyStaggeredTile _tileGenerator(int i){
 return MyStaggeredTile(  Note(
      _allNotesInQueryResult[i]["id"],
      _allNotesInQueryResult[i]["title"] == null ? "" : utf8.decode(_allNotesInQueryResult[i]["title"]),
      _allNotesInQueryResult[i]["content"] == null ? "" : utf8.decode(_allNotesInQueryResult[i]["content"]),
     DateTime.fromMillisecondsSinceEpoch(_allNotesInQueryResult[i]["dateCreated"] * 1000),
     DateTime.fromMillisecondsSinceEpoch(_allNotesInQueryResult[i]["dateLastEdited"] * 1000),
      Color(_allNotesInQueryResult[i]["noteColor"] ), _allNotesInQueryResult[i]["labels"], _allNotesInQueryResult[i]["isArchived"])
  );
  }

  void retrieveAllNotesFromDatabase() {
  // queries for all the notes from the database ordered by latest edited note. excludes archived notes.
    var _testData = noteDB.selectAllNotes();
    _testData.then((value){
        setState(() {
          this._allNotesInQueryResult = value;
          CentralStation.updateNeeded = false;
        });
    });
  }
}
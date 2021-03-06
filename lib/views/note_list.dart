import 'package:flutter/material.dart';
import 'package:flutter_rest_api_gornez/models/api_response.dart';
import 'package:get_it/get_it.dart';

import '../models/note_for_listing.dart';
import '../services/notes_service.dart';
import 'note_delete.dart';
import 'note_modify.dart';

class NoteList extends StatefulWidget {

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  NotesService get service => GetIt.instance<NotesService>();

  APIResponse<List<NoteForListing>>? _apiResponse;
  bool _isloading = false;

  String formatDateTime(DateTime dateTime){
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  void initState() {
    // TODO: implement initState
    _fetchNotes();
    super.initState();
  }

  _fetchNotes() async{
    setState(() {
      _isloading = true;
    });

    _apiResponse = await service.getNotesList();

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteModify()))
              .then((_){
                _fetchNotes();
            });
        },
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (_){
          if (_isloading){
            return const Center(child: CircularProgressIndicator());
          }

          if(_apiResponse!.error){
            return Center(child: Text(_apiResponse!.errorMessage!),);
          }
          return ListView.separated(
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.green,),
            itemBuilder: (_, index){
              return Dismissible(
                key: ValueKey(_apiResponse!.data![index].noteID),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction){

                },
                confirmDismiss: (direction) async{
                  final result = await showDialog(
                      context: context,
                      builder: (_)=>NoteDelete());

                  if(result){
                    final deleteResult = await service.deleteNote(_apiResponse!.data![index].noteID!);

                    var message;

                    if (deleteResult != null && deleteResult.data == true) {
                      message = 'The note was deleted successfully';
                    } else {
                      message = deleteResult.errorMessage ?? 'An error occured';
                    }

                    showDialog(
                        context: context, builder: (_) => AlertDialog(
                      title: Text('Done'),
                      content: Text(message),
                      actions: <Widget>[
                        MaterialButton(child: Text('Ok'), onPressed: () {
                          Navigator.of(context).pop();
                        })
                      ],
                    ));

                    return deleteResult.data ?? false;
                  }

                  print(result);
                  return result;
                },
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(left: 16),
                  child: Align(
                    child: Icon(Icons.delete, color: Colors.white,),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    _apiResponse!.data![index].noteTitle!, style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  subtitle: Text('Last edited on ${formatDateTime(_apiResponse!.data![index].latestEditDateTime ??
                      _apiResponse!.data![index].createDateTime!)}'),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteModify(noteID: _apiResponse!.data![index].noteID!))).then((data){
                      _fetchNotes();
                    });
                  },
                ),
              );
            },
            itemCount:  _apiResponse!.data!.length,
          );
        },
      ),
    );
  }
}

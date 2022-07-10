import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/note.dart';
import '../models/note_insert.dart';
import '../services/notes_service.dart';


class NoteModify extends StatefulWidget {

  final String? noteID;
  NoteModify({this.noteID});

  @override
  State<NoteModify> createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID !=null;

  NotesService get noteService => GetIt.I<NotesService>();

  String? errorMessage;
  late Note note;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (isEditing){
      setState(() {
        _isLoading =true;
      });
      noteService.getNote(widget.noteID!)
          .then((response){
        setState(() {
          _isLoading = false;
        });

        if(response.error){
          errorMessage=response.errorMessage ?? 'An error occured';
        }
        note = response.data!;
        _titleController.text = note.noteTitle!;
        _contentController.text = note.noteContent!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editing note' : 'Create note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note Title'
              ),
            ),

            Container(height: 8,),

            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                  hintText: 'Note Content'
              ),
            ),

            Container(height: 16,),

            SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: () async {
                  if(isEditing){
                    //update note
                  }else{

                    setState(() {
                      _isLoading=true;
                    });

                    final note = NoteInsert(
                        noteTitle: _titleController.text,
                        noteContent: _contentController.text
                    );
                    final result = await noteService.createNote(note);

                    setState(() {
                      _isLoading=false;
                    });

                    const title = 'Done';
                    final text = result.error ? (result.errorMessage ?? 'An error occured') : 'Your note was created';

                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text(title),
                          content:Text(text),
                          actions: <Widget>[
                            ElevatedButton(
                                child: const Text('Ok'),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                            ),
                          ],
                        )
                    )
                    .then((data){
                     if(result.data!){
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white
                ) ,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

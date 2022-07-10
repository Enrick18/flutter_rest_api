import 'dart:convert';

import '../models/api_response.dart';
import '../models/note.dart';
import '../models/note_for_listing.dart';
import '../models/note_insert.dart';

import 'package:http/http.dart' as http;



class NotesService{

  static const api ='https://tq-notes-api-jkrgrdggbq-el.a.run.app';
  static const headers = {
    'apiKey':'f8e41aed-c540-4cc1-abbb-a291dc029ad6',
    'Content-Type':'application/json'
  };

  Future<APIResponse<List<NoteForListing>>> getNotesList(){
    return http.get(Uri.parse('$api/notes'), headers: headers)
        .then((data){
       if(data.statusCode == 200){
         final jsonData = json.decode(data.body);
         final notes = <NoteForListing>[];

         for (var item in jsonData){
           notes.add(NoteForListing.fromJson(item));
         }
         return APIResponse<List<NoteForListing>>(data: notes);
       }
       return APIResponse<List<NoteForListing>>(error: true, errorMessage: 'An error occured');
    })
        .catchError((_)=>APIResponse<List<NoteForListing>>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<Note>> getNote(String noteID){
    return http.get(Uri.parse('$api/notes/$noteID'), headers: headers)
        .then((data){
      if(data.statusCode == 200){
        final jsonData = json.decode(data.body);

        return APIResponse<Note>(data: Note.fromJson(jsonData));
      }
      return APIResponse<Note>(error: true, errorMessage: 'An error occured');
    })
        .catchError((_)=>APIResponse<Note>(error: true, errorMessage: 'An error occured'));
  }

  Future<APIResponse<bool>> createNote(NoteInsert item){
    return http.post(Uri.parse('$api/notes/'), headers: headers, body: json.encode(item.toJson()))
        .then((data){
      if(data.statusCode == 201){
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(error: true, errorMessage: 'An error occured');
    })
        .catchError((_)=>APIResponse<bool>(error: true, errorMessage: 'An error occured'));
  }
}


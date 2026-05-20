/*
1. 시작한다
2. ai가 단어를 말한다
3. 사용자가 이에 해당하는 설명을 적는다
4. 설명에 해당하는 단어가 있다면 적는다
7. 만약 단어를 찾지 못했다면 '단어를 찾지 못했습니다' 라고 출력한다.
8. 다시 글자를 지우고 3번으로 돌아간다.
5. 만약 끝말잇기 룰에 맞지 않는다면 단어를 지우고 '끝말잇기 룰에 맞지 않습니다' 라고 출력한다
6. 다시 글자를 지우고 3번으로 돌아간다
9. 먄약 해당하는 단어가 끝말잇기 룰에 맞는다면 가만히 두고 
10. 2번으로 돌아간다.
11. 만일 ai가 단어를 말하지 못하거나 인간이 GG 또는 시간이 초과된다면 게임이 종료된다.

필요한 함수
0. 게임을 시작하는 함수                                      = start_game()
1. ai가 끝말잇기 룰에 맞는 단어를 말하는 함수                 = ai_turn()
2. 글자를 지우는 함수                                        = rm_line()
3. 끝말잇기 룰에 맞는지 확인하는 함수                         = dict_check()
4. 게임이 종료되는 함수 




*/
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:dart_console/dart_console.dart';
import 'package:http/http.dart' as http;

final console = Console();


String? user_name;
Set<String> used_words = {};
String api_key = 'C09336322E6D5FC8D9C74703630D1C6C';

void main() async{
  start_game();
  var result = await during_game();
  if(result == 'human_win')
    human_win();
  if(result == 'ai_win')
    ai_win();
}

void human_win () {
  print('$user_name 승리!');
}

void ai_win (){
  print('defeat');
}


Future<String> during_game() async{
  String input = '테';
  while(true){
    input = await ai_turn(input);
    if(input == 'gg')
      return 'human_win';
    input = await human_turn(input);
    if(input == 'gg')
      return 'ai_win';
  }
}


void rm_line(){
    console.cursorUp();  
    console.eraseLine();
}

void start_game(){
    print('게임을 시작합니다.');
    print('당신의 이름은 무엇입니까');
    user_name = stdin.readLineSync(encoding: utf8);
    user_name ??= '플레이어';
    if(user_name == '')
      user_name = '플레이어';
    rm_line(); //입력 이름 지우기
    rm_line(); // 질문 지우기
    print('무운을 빕니다.');
}


Future<String> ai_turn(String start_word) async{
  var client = http.Client();
  Set<String> word_map = {};
for(int count = 1;count<=41;count += 10){
  try{
    var response = await client.get(
      Uri.https('stdict.korean.go.kr', '/api/search.do',
      {'key': api_key, 
      'q': start_word,
      'req_type': 'json',
      'num': '100',
      'start': count.toString(),
      'advanced': 'y',
      'target':'1',
      'method': 'start',
      'type1': 'word',
      'pos': '1'
      }));
    var map_resp_r = jsonDecode(utf8.decode(response.bodyBytes));
    if(map_resp_r.isEmpty){
      continue;
    }

    if(map_resp_r == null)
      continue;

    var map_resp = map_resp_r;
    map_resp = map_resp['channel'];
    var items = map_resp['item'] as List<dynamic>;
    for(var i in items){
      if(i == null)
        continue;
      var word = i['word'] as String;
      if(word == start_word)
        continue;
      word = word.replaceAll('-','');
      word_map.add(word);
    }
    
  }
  catch(e){
    print('errorholyt: $e');
    return '0';
  }
  finally{
  }
  }
  List<String> word_list = word_map.toList();
  for(var i in used_words){
    word_list.remove(i);
  }
  if (word_list.isEmpty){
    print('상대방: 단어를 못찾음');
    return 'gg';
  }
  var choice = word_list[Random().nextInt(word_list.length)];
  used_words.add(choice);
  print('상대방: $choice');
  return choice;
  client.close();
}

Future<String> human_turn(String start_word) async{
  while(true){
    stdout.write('$user_name: ');
    String? input = stdin.readLineSync(encoding: utf8);
    if(input == null || input == ''){
      rm_line();
      continue;
    } 
    input = input.replaceAll(' ','');
    if (input == 'gg'|| input == 'GG')
      return 'gg';
    if(start_word == input[0]){
      rm_line();
      print('시작 글자는 $start_word 입니다.');
    }
    bool? dup_check = await dict_check(input);
    if(dup_check == null){
      rm_line();
      continue;
    }
    if (!dup_check){
      rm_line();
      print('존재하지 않는 단어입니다. human_check');
      sleep(Duration(seconds:1));
      rm_line();
      continue;
    }
    if (used_words.contains(input)) {
      rm_line();
      print('이미 사용된 단어입니다.');
      continue;
    } else {
      used_words.add(input);
      return input[input.length-1];
    }
  }
}

Future<bool?> dict_check(String search_word) async{
  var client = http.Client();
try{
  var response = await client.get(
    Uri.https('stdict.korean.go.kr', '/api/search.do',
    {'key': api_key, 
     'q': search_word,
     'req_type': 'json',
     'advanced': 'y',
     'target':'1',
     'type1': 'word',
     'pos': '1'
     }));

  var map_resp_r = jsonDecode(utf8.decode(response.bodyBytes));
  if(map_resp_r == null || map_resp_r.isEmpty){
    return false;
  }
  else{
    return true;
  }
}
catch(e){
  print('errorholyd: $e');
  return null;
}
finally{
  client.close();

}
}

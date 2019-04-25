//These are the classes for the questions.
//There is only one bonus question so I hardcoded it instead; takes fewer lines

class MChoice {
  String q;
  String a1;
  String a2;
  String a3;
  String a4;
  String correct;
  MChoice(String tempq, String tempa1, String tempa2, String tempa3, String tempa4, String tempcorrect) {
    q = tempq;
    a1 = tempa1;
    a2 = tempa2;
    a3 = tempa3;
    a4 = tempa4;
    correct = tempcorrect;
  }
}

class ThreeTry {
  String q;
  String a1;
  String a2;
  String a3;
  String a4;
  String a5;
  String correct;
  int tries;
  ThreeTry(String tempq, String tempa1, String tempa2, String tempa3, String tempa4, String tempa5, String tempcorrect) {
    q = tempq;
    a1 = tempa1;
    a2 = tempa2;
    a3 = tempa3;
    a4 = tempa4;
    a5 = tempa5;
    correct = tempcorrect;
    tries = 3;
  }
}

class TF {
  String q;
  String correct;
  TF(String tempq, String tempcorrect) {
    q = tempq;
    correct = tempcorrect;
  }
}

//Fill in the blank can only accept four answers; questions with fewer than four possible answers will have this random extremely obscure word as an answer
String workaroundanswer = "duodenum";

class FBlank {
  String q;
  String[] correct = new String[4];
  FBlank(String tempq, String tempcorrect1, String tempcorrect2, String tempcorrect3, String tempcorrect4) {
    q = tempq;
    correct[0] = tempcorrect1;
    correct[1] = tempcorrect2;
    correct[2] = tempcorrect3;
    correct[3] = tempcorrect4;
  }
}
//Typing
void keyPressed() {
  //Deletes with backspace
  if (key == BACKSPACE && useranswer.length() > 0) {
    useranswer = useranswer.substring(0, useranswer.length() - 1);
    
  //Sets and checks answer with enter.
  } else if (key == ENTER) {
    //Enter can be used to continue if the current screen is not a multiple choice question
    if (mode < 1 || mode == 1.99 || mode == 2.99 || mode == 3.99 || mode == 4.8 || mode >= 5) {
      Progress();
    //Enter can also be used to continue if the current screen is on an answer screen or is on a fill in the blank question
    } else if (showanswer == true || (mode >= 4 && mode < 4.8)) {
      Progress();
    }
  
  //If key is weird, like TAB or SHIFT, it ignores it.
  } else if (key == CODED) {
    
  //Adds key to end of string.
  } else {
    useranswer += key;
  }
}

//Clears answer
void ClearAnswer() {
  useranswer = "";
}

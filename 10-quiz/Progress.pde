//These functions either mode the 'mode' variable forward or check answers (and move from question to answer page).
//In general, they do stuff to make the screens change

//Moves the mode forward as well as other special things to do when going to the next page
void Progress() {
  //In some cases (when moving from question to answer), the mode should not progress forward. True means proceed as normal.
  boolean x = true;
  
  //Saves name
  if (mode == 0.1) {
    name = useranswer;
  }
  
  //Multiple choice questions
  if (mode >= 1 && mode <= 1 + 0.01 * (mchoices.length - 1)) {
    //If on question page
    if (showanswer == false) {
      //Switch to answer page
      showanswer = true;
      //Prevent from skipping straight to next question
      x = false;
      
      //If correct
      if (useranswer.equals(mchoices[answered].correct)) {
        score++;
        lastcorrect = true;
      } 
     
      answered++;
      possiblescore++;
    
    //If on answer page
    } else {
      showanswer = false;
      lastcorrect = false;
    }
  }
  
  //Three try questions
  if (mode >= 2 && mode <= 2 + 0.01 * (threetries.length - 1)) {
    //If on question page
    if (showanswer == false) {
      //Switch to answer page
      showanswer = true;
      //Prevent from skipping straight to next question
      x = false;
      
      //if correct
      if (useranswer.equals(threetries[answered].correct)) {
        score++;
        lastcorrect = true;
      } else {
        threetries[answered].tries--;
      }
      
      answered++;
      possiblescore++;
      
    //If on answer page
    } else {
      showanswer = false;
      
      //If incorrect and not out of tries, go back and reset.
      if (lastcorrect == false && threetries[answered - 1].tries != 0) {
        answered--;
        possiblescore--;
        x = false;
      }
      
      lastcorrect = false;
    }
  }
  
  //True or false questions
  if (mode >= 3 && mode <= 3 + 0.01 * (tfs.length - 1)) {
    //If on question page
    if (showanswer == false) {
      //Switch to answer page
      showanswer = true;
      //Prevent from skipping straight to next question
      x = false;
      
      //If correct
      if (useranswer.equals(tfs[answered].correct)) {
        score++;
        lastcorrect = true;
      } 
     
      answered++;
      possiblescore++;
    
    //If on answer page
    } else {
      showanswer = false;
      lastcorrect = false;
    }
  }
  
  //Fill in the blank questions
  if (mode >= 4 && mode <= 4 + 0.01 * (fblanks.length - 1)) {
    //If on question page
    if (showanswer == false) {
      //Switch to answer page
      showanswer = true;
      //Prevent from skipping straight to next question
      x = false;
      
      //If correct; for some reason a for loop does not work here so I just used a workaround
      if (useranswer.toLowerCase().equals(fblanks[answered].correct[0])) {
        score++;
        lastcorrect = true;
      }
      if (useranswer.toLowerCase().equals(fblanks[answered].correct[1])) {
        score++;
        lastcorrect = true;
      }
      if (useranswer.toLowerCase().equals(fblanks[answered].correct[2])) {
        score++;
        lastcorrect = true;
      }
      if (useranswer.toLowerCase().equals(fblanks[answered].correct[3])) {
        score++;
        lastcorrect = true;
      }
     
      answered++;
      possiblescore++;
    
    //If on answer page
    } else {
      showanswer = false;
      lastcorrect = false;
    }
  }
  
  //Bonus question
  if (mode == 4.9) {
    //If on question page
    if (showanswer == false) {
      //Switch to answer page
      showanswer = true;
      //Prevent from skipping straight to next question
      x = false;
      
      //If correct
      if (useranswer.equals("3")) {
        score += 2;
        lastcorrect = true;
      } 
     
      answered += 2;
      possiblescore += 2;
    
    //If on answer page
    } else {
      showanswer = false;
      lastcorrect = false;
    }
  }
  
  if (x) {
    mode = ChooseProgress();
  }
  ClearAnswer();
  buttondelay = 15;
}

float ChooseProgress() {
  float output = 0;
  if (mode == 0) {
    output = 0.1;
  }
  if (mode == 0.1) {
    output = 0.99;
  }
  
  if (mode == 0.99) {
    output = 1;
  }
  if (mode == 1 + 0.01 * (answered - 1)) {
    if (mode == 1 + 0.01 * (mchoices.length - 1)) {
      output = 1.99;
    } else {
      output = 1 + 0.01 * answered;
    }
  }

  if (mode == 2 + 0.01 * (answered - 1)) {
    if (mode == 2 + 0.01 * (threetries.length - 1)) {
      output = 2.99;
    } else {
      output = 2 + 0.01 * answered;
    }
  }
  
  if (mode == 3 + 0.01 * (answered - 1)) {
    if (mode == 3 + 0.01 * (tfs.length - 1)) {
      output = 3.99;
    } else {
      output = 3 + 0.01 * answered;
    }
  }
  
  if (mode == 4 + 0.01 * (answered - 1)) {
    if (mode == 4 + 0.01 * (fblanks.length - 1)) {
      output = 4.8;
    } else {
      output = 4 + 0.01 * answered;
    }
  }
  
  if (mode == 4.8) {
    output = 4.9;
  }
  
  if (mode == 4.9) {
    output = 5;
    UpdateHighScores(name, score);
  }
  
  if (mode == 5) {
    output = 5.1;
  }
  
  if (mode == 5.1) {
    output = 0;
    Reset();
  }
  
  return output;
}

//Sets answer when an answer button is clicked
void SetAnswer(String x) {
  useranswer = x;
}

//Clears (almost) everything for a restart (intro is not reset)
void Reset() {
  name = "";
  score = 0;
  possiblescore = 0;
  answered = 0;
  lastcorrect = false;
}

//Updates highscores with the newest result
void UpdateHighScores(String name, int score) {
  //Adds new row to table
  TableRow newRow = highscores.addRow();
  newRow.setString("Name", name);
  newRow.setInt("Score", score);
  //Sorts table by score
  highscores.setColumnType("Score", Table.INT);
  highscores.sortReverse("Score");
  //Exports new table back to highscore file (and overwrites the old one)
  saveTable(highscores, "data/scores.csv");
}
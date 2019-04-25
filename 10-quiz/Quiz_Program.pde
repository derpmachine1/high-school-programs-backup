//THE MINIM LIBRARY IS REQUIRED TO RUN THIS

//This is the name of the player
String name = "";

/*Where in the game the player is at.
0.0: Title
0.1: Enter name
0.99: MChoice instructions
1.0-1.09 MChoice questions
1.99: ThreeTry instructions
2.0-2.05 ThreeTry questions
2.99: TF instructions
3.0-3.07 TF questions
3.99: FBlank instructions
4.0-4.09 FBlank questions
4.8: Bonus instructions
4.9: Bonus question
5.0: Results
5.1: High score leaderboard
5.2 End screen
*/
float mode = 0;

//Should the screen be on the questions or on the answers?
//Like a second 'mode' variable
boolean showanswer; 

//Tables with qeustions from files; they are temporary and are used for the question arrays
Table tempmchoices;
Table tempthreetries;
Table temptfs;
Table tempfblanks;

//Question arrays
MChoice[] mchoices = new MChoice[10];
ThreeTry[] threetries = new ThreeTry[6];
TF[] tfs = new TF[8];
FBlank[] fblanks = new FBlank[10];

//Score
int score = 0;
int possiblescore = 0;
//Not the total answered, but the total answered in the section. Reset to zero periodically.
int answered = 0;
boolean lastcorrect = false;
//Highscore board
Table highscores;

//All user answers are saved to this.
//For fill in the blank, when enter is pressed, it is saved to this variable.
String useranswer = "";

//Delay that activates a cooldown so when a button is pressed, the next one can't be clicked accidentally for a while
float buttondelay;

//The next few variables all relate to visual things
//Timer for when the title is revealed
float timer = 570;
//Variable to make the title move up and down
float titlemove = -1;
//Boolean for if the title should be moving up or down
boolean titlemoveup = true;
//Lighting
Spotlight[] spotlights = new Spotlight[10];
//Stars
float starx = 250;
float stary = 250;
float deltastarx = random(-5, 5);
float deltastary = random(-5, 5);
boolean starxright = true;
boolean starydown = true;
float starxamt = random(0.5, 1);
float staryamt = random(0.5, 1);
float starsize = 10;

//Jeopardy colours
color jyellow = color(255, 204, 0);
color jyellow2 = color(255, 234, 30);
color jblue = color(12, 12, 129);
color jblue2 = color(42, 42, 159);

//Fonts
PFont titlefont;
PFont font;

//Music
import ddf.minim.*;
Minim minim;
AudioPlayer titlemusic;
AudioPlayer music;

void setup() {
  size(500, 500);

  //Fonts
  textAlign(CENTER);
  titlefont = createFont("titlefont.ttf", 48);
  font = createFont("font.otf", 48);
  
  //Music
  minim = new Minim(this);
  titlemusic = minim.loadFile("titlemusic.mp3");
  titlemusic.loop();
  music = minim.loadFile("music.mp3");
  music.loop();
  
  //Initializes spotlight objects
  for (int i = 0; i < spotlights.length; i++) {
    if (i == round(i / 2) * 2) {
      spotlights[i] = new Spotlight(true, floor(i / 2) + 1);
    } else {
      spotlights[i] = new Spotlight(false, floor(i / 2) + 1);
    }
  }

  //Initialize question tables from text files
  tempmchoices = loadTable("mchoices.csv", "header");
  tempthreetries = loadTable("threetries.csv", "header");
  temptfs = loadTable("tfs.csv", "header");
  tempfblanks = loadTable("fblanks.csv", "header");

  //Questions
  LoadMChoice();
  LoadThreeTry();
  LoadTF();
  LoadFBlank();
  
  //Highscore board
  highscores = loadTable("scores.csv", "header");
}

void draw() {
  background(jblue);
  Display();
  //Decreases button timer delay
  buttondelay = constrain(buttondelay - 1, 0, 30);
  Intro();  //Reveal the intro
}

//Displays everything; all the screens are here
void Display() {
  //Title screen
  if (mode == 0) {
    //Music
    music.pause();
    
    //Title
    MoveTitle();
    textFont(titlefont);
    fill(jyellow);
    textSize(96);
    text("Geopardy", 250, 100 + titlemove);
    textSize(36);
    text("The World-Famous Geo/CS Quiz", 250, 150 - titlemove);
    
    //Button
    Button(25, 300, 450, 175, jyellow, jyellow2, jblue, 205, "Play");
    
    //Lighting
    Lighting();
  }
  
  //Enter name
  if (mode == 0.1) {
    //Music
    music.loop();
    
    //Title
    MoveTitle();
    textFont(titlefont);
    fill(jyellow);
    textSize(72);
    text("Enter Your Name", 250, 100 + titlemove);
    
    //Name
    fill(255);
    rect(25, 325, 450, 50);
    textFont(font);
    fill(jblue);
    textSize(42);
    text(useranswer, 250, 362);
    
    //Button
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Enter");
    
    //Lighting
    Lighting();
  }
  
  //Multiple choice instructions
  if (mode == 0.99) {
    answered = 0;
    //Music
    titlemusic.pause();
    
    //Instructions
    textFont(titlefont);
    fill(jyellow);
    textSize(36);
    text("Multiple Choice Questions", 250, 75);
    text("Instructions", 250, 125);
    textAlign(LEFT);
    textFont(font);
    textSize(24);
    text("A question or statement will appear with 4 possible answers.", 25, 175, 450, 100);
    text("Click the correct answer to earn 1 point.", 25, 275);
    text("You will only get 1 try!", 25, 375);
    textAlign(CENTER);
    
    //Button
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
  }
  
  //Multiple choice
  if (mode >= 1 && mode <= 1 + 0.01 * (mchoices.length - 1)) {
    if (showanswer == false) {  
      //Questions
      textAlign(LEFT);
      textFont(font);
      fill(jyellow);
      textSize(30);
      text(mchoices[answered].q, 10, 50, 480, 200);
      
      //Answers
      textAlign(CENTER);
      if (answered < mchoices.length) {
        AnswerButton(0, 200, 250, 150, jyellow, jyellow2, jblue, 18, mchoices[answered].a1, "1");
      }
      if (answered < mchoices.length) {
        AnswerButton(250, 200, 250, 150, jyellow, jyellow2, jblue, 18, mchoices[answered].a2, "2");
      }
      if (answered < mchoices.length) {
        AnswerButton(0, 350, 250, 150, jyellow, jyellow2, jblue, 18, mchoices[answered].a3, "3");
      }
      if (answered < mchoices.length) {
        AnswerButton(250, 350, 250, 150, jyellow, jyellow2, jblue, 18, mchoices[answered].a4, "4");
      }
    } else { 
      //Results;
      fill(jyellow);
      textFont(titlefont);
      textSize(96);
      if (lastcorrect) {
        text("Correct!", 250, 100);
      } else {
        text("Incorrect!", 250, 100);
      }
      
      textSize(24);
      rectMode(RADIUS);
      switch(mchoices[answered - 1].correct) {
        case "1": 
          text("Answer: " + mchoices[answered - 1].a1, 250, 225, 200, 100);
          break;
        case "2": 
          text("Answer: " + mchoices[answered - 1].a2, 250, 225, 200, 100);
          break;
        case "3": 
          text("Answer: " + mchoices[answered - 1].a3, 250, 225, 200, 100);
          break;
        case "4": 
          text("Answer: " + mchoices[answered - 1].a4, 250, 225, 200, 100);
          break;
      }
      rectMode(CORNER);
      
      textSize(36);
      text("Current Score:", 250, 250);
      text(score + " / " + str(possiblescore), 250, 300);
      Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
    }
  }
  
  //Three try instructions
  if (mode == 1.99) {
    answered = 0;
    
    //Instructions
    textFont(titlefont);
    fill(jyellow);
    textSize(36);
    text("3 Try Multiple Choice Questions", 250, 75);
    text("Instructions", 250, 125);
    textAlign(LEFT);
    textFont(font);
    textSize(24);
    text("A question or statement will appear with 5 possible answers.", 25, 175, 450, 100);
    text("Click the correct answer to earn 1 point.", 25, 275);
    text("You will get 3 tries!", 25, 375);
    textAlign(CENTER);
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
  }

  //Three try
  if (mode >= 2 && mode <= 2 + 0.01 * (threetries.length - 1)) {
    if (showanswer == false) {
      //Questions
      textAlign(LEFT);
      textFont(font);
      fill(jyellow);
      textSize(30);
      text(threetries[answered].q, 10, 50, 480, 200);
      
      //Answers
      textAlign(CENTER);
      if (answered < threetries.length) {
        AnswerButton(125, 200, 250, 100, jyellow, jyellow2, jblue, 18, threetries[answered].a1, "1");
      }
      if (answered < threetries.length) {
        AnswerButton(0, 300, 250, 100, jyellow, jyellow2, jblue, 18, threetries[answered].a2, "2");
      }
      if (answered < threetries.length) {
        AnswerButton(250, 300, 250, 100, jyellow, jyellow2, jblue, 18, threetries[answered].a3, "3");
      }
      if (answered < threetries.length) {
        AnswerButton(0, 400, 250, 100, jyellow, jyellow2, jblue, 18, threetries[answered].a4, "4");
      }
      if (answered < threetries.length) {
        AnswerButton(250, 400, 250, 100, jyellow, jyellow2, jblue, 18, threetries[answered].a5, "5");
      }
    } else {
      //Results
      fill(jyellow);
      textFont(titlefont);
      textSize(96);
      if (lastcorrect) {
        text("Correct!", 250, 100);
      } else {
        text("Incorrect!", 250, 100);
      }
      
      textSize(36);
      //If correct or out of tries, display
      if (lastcorrect || threetries[answered - 1].tries == 0) {
        textSize(24);
        rectMode(RADIUS);
        switch(threetries[answered - 1].correct) {
          case "1": 
            text("Answer: " + threetries[answered - 1].a1, 250, 225, 200, 100);
            break;
          case "2": 
            text("Answer: " + threetries[answered - 1].a2, 250, 225, 200, 100);
            break;
          case "3": 
            text("Answer: " + threetries[answered - 1].a3, 250, 225, 200, 100);
            break;
          case "4": 
            text("Answer: " + threetries[answered - 1].a4, 250, 225, 200, 100);
            break;
          case "5": 
            text("Answer: " + threetries[answered - 1].a5, 250, 225, 200, 100);
            break;
        }
        rectMode(CORNER);
        
        textSize(36);
        text("Current Score:", 250, 250);
        text(score + " / " + str(possiblescore), 250, 300);
      //Else, display number of tries left
      } else {
        text("You have " + (threetries[answered - 1].tries) + " tries left!", 250, 250);
      }
      Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
    }
  }
  
  //True or false instructions
  if (mode == 2.99) {
    answered = 0;
    
    //Instructions
    textFont(titlefont);
    fill(jyellow);
    textSize(36);
    text("True or False Questions", 250, 75);
    text("Instructions", 250, 125);
    textAlign(LEFT);
    textFont(font);
    textSize(24);
    text("A statement will appear that is either true or false.", 25, 175, 450, 100);
    text("Click the correct answer to earn 1 point.", 25, 275);
    text("You will only get 1 try!", 25, 375);
    textAlign(CENTER);
    
    //Button
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
  }
  
  //True or false
  if (mode >= 3 && mode <= 3 + 0.01 * (tfs.length - 1)) {
    if (showanswer == false) {
      //Questions
      textAlign(LEFT);
      textFont(font);
      fill(jyellow);
      textSize(30);
      text(tfs[answered].q, 10, 50, 480, 200);
      
      //Answers
      textAlign(CENTER);
      if (answered < tfs.length) {
        AnswerButton(0, 300, 250, 200, jyellow, jyellow2, jblue, 30, "\n" + "\n" + "True", "1");
      }
      if (answered < tfs.length) {
        AnswerButton(250, 300, 250, 200, jyellow, jyellow2, jblue, 30, "\n" + "\n" + "False", "0");
      }
    } else { 
      //Results;
      fill(jyellow);
      textFont(titlefont);
      textSize(96);
      if (lastcorrect) {
        text("Correct!", 250, 100);
      } else {
        text("Incorrect!", 250, 100);
      }
      
      textSize(24);
      rectMode(RADIUS);
      if (tfs[answered - 1].correct == "1") {
        text("Answer: True", 250, 225, 200, 100);
      } else {
        text("Answer: False", 250, 225, 200, 100);
      }
      rectMode(CORNER);
      
      textSize(36);
      text("Current Score:", 250, 250);
      text(score + " / " + str(possiblescore), 250, 300);
      Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
    }
  }
  
  //Fill in the blank instructions
  if (mode == 3.99) {
    answered = 0;
    
    //Instructions
    textFont(titlefont);
    fill(jyellow);
    textSize(36);
    text("Fill in the Blank Questions", 250, 75);
    text("Instructions", 250, 125);
    textAlign(LEFT);
    textFont(font);
    textSize(24);
    text("A statement will appear with a missing word.", 25, 175, 450, 100);
    text("Type in the correct word to earn 1 point. Caps do not matter; spaces/symbols do.", 25, 275, 450, 100);
    text("You will only get 1 try!", 25, 375);
    textAlign(CENTER);
    
    //Button
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
  }
  
  //Fill in the blank
  if (mode >= 4 && mode <= 4 + 0.01 * (fblanks.length - 1)) {
    if (showanswer == false) {

      //Questions
      textAlign(LEFT);
      textFont(font);
      fill(jyellow);
      textSize(30);
      text(fblanks[answered].q, 10, 50, 480, 200);
      
      //Answers
      textAlign(CENTER);
      //Name
      fill(255);
      rect(25, 325, 450, 50);
      textFont(font);
      fill(jblue);
      textSize(42);
      text(useranswer, 250, 362);
      
      //Button
      textFont(titlefont);
      Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Enter");

    } else { 
      //Results;
      fill(jyellow);
      textFont(titlefont);
      textSize(96);
      if (lastcorrect) {
        text("Correct!", 250, 100);
      } else {
        text("Incorrect!", 250, 100);
      }
      
      textSize(24);
      rectMode(RADIUS);
      String tempanswers = "";
      for (int i = 0; i < 4; i++) {  //This will display all correct answers, removing the workaround ones
        if (fblanks[answered - 1].correct[i] != workaroundanswer) {
          tempanswers += fblanks[answered - 1].correct[i] + ", ";
        }
      }
      if (tempanswers.charAt(tempanswers.length() - 1) == ' ') {  //Removes last unnecessary comma
        tempanswers = tempanswers.substring(0, tempanswers.length() - 2);
      }
      text("Answer(s): " + tempanswers, 250, 225, 200, 100);
      rectMode(CORNER);
      
      textSize(36);
      text("Current Score:", 250, 250);
      text(score + " / " + str(possiblescore), 250, 300);
      Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
    }
  }
  
  //Bonus instructions
  if (mode == 4.8) {
    answered = 0;
    
    //Instructions
    textFont(titlefont);
    fill(jyellow);
    textSize(36);
    text("BONUS QUESTION", 250, 75);
    text("Instructions", 250, 125);
    textAlign(LEFT);
    textFont(font);
    textSize(24);
    text("A question or statement will appear with 4 possible answers.", 25, 175, 450, 100);
    text("Click the correct answer to earn 2 bonus points.", 25, 275, 450, 100);
    text("You will only get 1 try!", 25, 375);
    textAlign(CENTER);
    
    //Button
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
  }
  
  //Bonus question; this question is the only question not loaded from a text file since there is only one question
  if (mode == 4.9) {
    //Music
    titlemusic.loop();
    
    if (showanswer == false) {
      //Questions
      textAlign(LEFT);
      textFont(font);
      fill(jyellow);
      textSize(30);
      text("What is Mr. Damian's first name?", 10, 50, 480, 100);
      
      //Answers
      textAlign(CENTER);
      if (answered < mchoices.length) {
        AnswerButton(0, 200, 250, 150, jyellow, jyellow2, jblue, 18, "|on", "1");
      }
      if (answered < mchoices.length) {
        AnswerButton(250, 200, 250, 150, jyellow, jyellow2, jblue, 18, "lon", "2");
      }
      if (answered < mchoices.length) {
        AnswerButton(0, 350, 250, 150, jyellow, jyellow2, jblue, 18, "Ion", "3");
      }
      if (answered < mchoices.length) {
        AnswerButton(250, 350, 250, 150, jyellow, jyellow2, jblue, 18, "1on", "4");
      }
    } else { 
      //Results;
      fill(jyellow);
      textFont(titlefont);
      textSize(96);
      if (lastcorrect) {
        text("Correct!", 250, 100);
      } else {
        text("Incorrect!", 250, 100);
      }
      textSize(24);
      text("Answer: Ion", 250, 150);
      textSize(36);
      text("Current Score:", 250, 250);
      text(score + " / " + str(possiblescore), 250, 300);
      Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
    }
  }

  if (mode == 5) {
    //Music
    music.pause();
    
    //Screen
    MoveTitle();
    textFont(titlefont);
    fill(jyellow);
    textSize(72);
    text("Congratulations", 250, 100 + titlemove);
    textSize(24);
    text("Congratulations, " + name + "!", 25, 125, 450, 100);
    textSize(36);
    text("Final Score:", 250, 250);
    text(score + " / " + str(possiblescore), 250, 300);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
    
    //Lighting
    Lighting();
  }
  
  //Highscores
  if (mode == 5.1) {
    //Title
    textFont(titlefont);
    fill(jyellow);
    textSize(36);
    text("Leaderboard", 250, 50);
    
    //Table
    textAlign(LEFT);
    textFont(font);
    textSize(24);
    text("Name", 35, 75);
    text("Score (#/" + possiblescore + ")", 260, 75);
    textSize(18);
    for (int i = 0; i < 13; i++) {
      if (i < highscores.getRowCount()) {
        TableRow row = highscores.getRow(i);
        text(row.getString("Name"), 35, 100 + i * 25);
        text(row.getInt("Score"), 260, 100 + i * 25);
      }
    }
    textAlign(CENTER);

    //Button
    textFont(titlefont);
    Button(190, 425, 120, 50, jyellow, jyellow2, jblue, 48, "Okay");
  }
}
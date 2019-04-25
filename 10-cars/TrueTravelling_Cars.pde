boolean[] keyCode = new boolean[4];

float globalspeed = 1;

//Frog object
Frog frog;

//Increased every time a car is created, and the next car is shifted by this much to prevent overlapping.
int carlocation = 0;

//Declaring arrays of objects
Car[] cars = new Car[20];
Decor[] decors = new Decor[10];

//An array of colours
color[] possiblecolours = 
  {#8E2525,  //Communist Red
   #D38422,  //Orangist Orange
   #D3CE2D,  //Ikea Yellow
   #24C630,  //"Who Would Ever Paint Their Car This Colour" Green
   #65D3E8,  //Chemtrail Light Blue
   #162BB2,  //"Polluted Lake Ontario" Blue
   #D126BD,  //Probably Purple
   #EEEEEE,  //Slightly Dirty White
   #818181,  //Cost Effective Gray
   #222222,  //Almost Black
   #C4BE9C,  //Boring Beige
   #FF03A7}; //Disgusting Pink 

//Frog class

class Frog {
  float x;
  float y;
  float speed;
  float size;
  boolean alive;
  float aliveness;  //Opacity, 0 to 255
  int highscore;
  int score;
  int deaths;
  
  Frog() {
    x = 25;
    y = 250;
    speed = 1.5;
    size = 10;
    alive = true;
    aliveness = 255;
    highscore = 0;
    score = 0;
    deaths = 0;
  }
  
  void MoveFrog() {    //Moves frog
    if (alive) {
      if (keyCode[0]) {
        y -= speed;
      }
      if (keyCode[1]) {
        y += speed;
      }
      if (keyCode[2]) {
        x -= speed;
      }
      if (keyCode[3]) {
        x += speed;
      }
    }
    x = constrain(x, size, 500 - size);
    y = constrain(y, size, 500 - size);
  }
  
  void DrawFrog() {    //Draws frog
    fill(#63892B, aliveness);
    rect(x - size, y - size, size * 2, size * 2);
  }
  
  void FrogDetect() {
    if (x > 475) {  //Score
      score++;
      x = 25;
      y = 250;
    }
    
    if (alive == false) {  //Death
      if (aliveness == 255) {
        deaths++;
        if (highscore < score) {
          highscore = score;
        }
        score = 0;
      }
      if (aliveness > 0) {
        aliveness = constrain(aliveness - 10, 0, 255);
      } else {
        alive = true;
        aliveness = 255;
        x = 25;
        y = 250;
      }
    }
  }
}

//Car class
class Car {
  //Declaring class variables
  float x;
  float y;
  color colour;
  int type;
  float speed;
  
  Car() {
    //Initializing
    type = floor(random(0, 2.99));
    x = 125 + floor(random(0, 5.99)) * 50;    //Chooses random lane
    if (x < 250) {
      carlocation += 2000/cars.length;    //Moves position of next car spawn, so car collision detection is never needed
      y = carlocation;                //Starting location
      speed = globalspeed;
    } else {
      carlocation += 2000/cars.length;    //Moves position of next car spawn, so car collision detection is never needed
      y = carlocation;              //Starting location
      speed = -globalspeed;
    }
  }
  
  void MoveCar() {
    //Cars' speeds, increased by score
    if (x < 250) {
      speed = globalspeed + 0.25 * frog.score;
    } else {
      speed = -globalspeed - 0.25 * frog.score;
    }
    
    //Moves cars
    if (x == 125 || x == 375) {
      y += 0.9 * speed;
    }
    if (x == 175 || x == 325) {
      y += speed;
    }
    if (x == 225 || x == 275) {
      y += 1.1 * speed;
    }
    
    //Moves them back to start
    if (y > 1250) {
      y -= 2000;
    }
    if (y < -750) {
      y += 2000;
    }
  }
  
  /* Sets the colour for each car, running down the colour array so each car has a different colour.
     The colour array only has 12 colours, so adding more than 12 cars will just make the colours repeat,
     which would create identical cars, which is not allowed for the project. */
  void SetCarColour(int tempi) {
    //Code that loops the colours. It won't activate if there are only 12 cars, but I put it here so the code doesn't give an error if there are more than 12.
    int i = tempi;
    while (i > 11) {
      i -= 12;
    }
    
    colour = possiblecolours[i];
  }
  
  void FrogDetection() {
    if (frog.x + frog.size > x - 15 && frog.x - frog.size < x + 15) {    //If frog is within horizontal hitbox
      if (type == 0 && frog.y + frog.size > y && frog.y - frog.size < y + 50) {
        frog.alive = false;
      }
      if (type == 1 && frog.y + frog.size > y && frog.y - frog.size < y + 90) {
        frog.alive = false;
      }
      if (type == 2 && frog.y + frog.size > y && frog.y - frog.size < y + 60) {
        frog.alive = false;
      }
    }
  }
  
  void DrawCar() {
    if (x < 250) {    //Cars on left
      if (type == 0) {    //Sedan
        fill(colour);
        rect(x - 15, y, 30, 50);    //Bottom
        rect(x - 15, y + 12.5, 30, 25);    //Top
        fill(#111111);
        rect(x - 16, y + 5, 1, 10);    //Wheels
        rect(x + 15, y + 5, 1, 10);
        rect(x - 16, y + 35, 1, 10);
        rect(x + 15, y + 35, 1, 10);
        
      } else if (type == 1) {    //Truck
        fill(colour);
        rect(x - 15, y + 65, 30, 25);    //Cab Bottom
        rect(x - 15, y + 65, 30, 12.5);    //Cab  Top
        rect(x - 15, y, 30, 60);    //Trailer
        rect(x - 5, y + 60, 10, 5);    //Connector
        fill(#111111);
        rect(x - 16, y + 5, 1, 10);    //Wheels
        rect(x + 15, y + 5, 1, 10);
        rect(x - 16, y + 20, 1, 10);
        rect(x + 15, y + 20, 1, 10);
        rect(x - 16, y + 75, 1, 10);
        rect(x + 15, y + 75, 1, 10);
        
      } else if (type == 2) {    //Van
        fill(colour);
        rect(x - 15, y, 30, 60);    //Bottom
        rect(x - 15, y + 5, 30, 40);    //Top
        fill(#111111);
        rect(x - 16, y + 5, 1, 10);    //Wheels
        rect(x + 15, y + 5, 1, 10);
        rect(x - 16, y + 45, 1, 10);
        rect(x + 15, y + 45, 1, 10);
      }

    } else {    //Cars on right
      if (type == 0) {    //Sedan
        fill(colour);
        rect(x - 15, y, 30, 50);    //Bottom
        rect(x - 15, y + 12.5, 30, 25);    //Top
        fill(#111111);
        rect(x - 16, y + 5, 1, 10);    //Wheels
        rect(x + 15, y + 5, 1, 10);
        rect(x - 16, y + 35, 1, 10);
        rect(x + 15, y + 35, 1, 10);
        
      } else if (type == 1) {    //Truck
        fill(colour);
        rect(x - 15, y, 30, 25);    //Cab Bottom
        rect(x - 15, y + 12.5, 30, 12.5);    //Cab Top
        rect(x - 15, y + 30, 30, 60);    //Trailer
        rect(x - 5, y + 25, 10, 5);    //Connector
        fill(#111111);
        rect(x - 16, y + 5, 1, 10);    //Wheels
        rect(x + 15, y + 5, 1, 10);
        rect(x - 16, y + 60, 1, 10);
        rect(x + 15, y + 60, 1, 10);
        rect(x - 16, y + 75, 1, 10);
        rect(x + 15, y + 75, 1, 10);
        
      } else if (type == 2) {    //Van
        fill(colour);
        rect(x - 15, y, 30, 60);    //Bottom
        rect(x - 15, y + 15, 30, 40);    //Top
        fill(#111111);
        rect(x - 16, y + 5, 1, 10);    //Wheels
        rect(x + 15, y + 5, 1, 10);
        rect(x - 16, y + 45, 1, 10);
        rect(x + 15, y + 45, 1, 10);
      }
    }
  }
}

//Road side decoration
class Decor {
  //Declaring class variables
  float x;
  float y;
  float size;
  float eccentricity = random(0.9, 1.1);    //makes it so some rocks are ovals
  int type;

  Decor() {
    if(random(0, 1) < 0.5) {    //Random chance to generate left or right of road
      x = random(0, 80);
    } else {
      x = random(420, 500);
    }
    y = random(0, 500);
    size = random(20, 40);
    type = round(random(0, 1));
  }
  
  void DrawDecor() {
    if (type == 0) {    //Rock
      fill(200);
      ellipse(x, y, size * eccentricity, size / eccentricity);
    } else if (type == 1) {    //Tree
      fill(5, 130, 5);
      ellipse(x, y, size * 0.8, size * 0.8);
    }
  }
}

//Function to draw road
void DrawRoad() {
  background(20, 150, 20);
  //Road
  fill(50, 50, 50);
  rect(100, 0, 300, 500);
  
  for(int i = 0; i < 500; i += 50) {
    //Medians
    fill(150);
    rect(98, 0, 4, 500);
    rect(248, 0, 4, 500);
    rect(398, 0, 4, 500);
    
    //Lines
    fill(200, 200, 20);
    rect(148, i, 4, 25);
    rect(198, i, 4, 25);
    rect(298, i, 4, 25);
    rect(348, i, 4, 25);
  }
}

void setup() {
  size(500, 500);
  frameRate(60);
  
  //Initializes frog
  frog = new Frog();
  
  //initializes the arrays of objects
  for(int i = 0; i < cars.length; i++) {
    cars[i] = new Car();
    //Sets colour. Didn't put it in Car() because it requires a counter that goes from one to the number of cars.
    cars[i].SetCarColour(i);
  }
  for(int i = 0; i < decors.length; i++) {
    decors[i] = new Decor();
  }
}

void draw() {
  DrawRoad();
  for(int i = 0; i < cars.length; i++) {
    cars[i].DrawCar();
    cars[i].FrogDetection();
    cars[i].MoveCar();
  }
  for(int i = 0; i < decors.length; i++) {
    decors[i].DrawDecor();
  }
  frog.MoveFrog();
  frog.DrawFrog();
  frog.FrogDetect();
  textSize(12);
  fill(255);
  text("High Score: " + frog.highscore, 4, 12);
  text("Current Score: " + frog.score, 4, 22);
  text("Deaths: " + frog.deaths, 4, 32);
}

void keyPressed() {
  if (key == 'w') {
    keyCode[0] = true;
  }
  if (key == 's') {
    keyCode[1] = true;
  }
  if (key == 'a') {
    keyCode[2] = true;
  }
  if (key == 'd') {
    keyCode[3] = true;
  }
}

void keyReleased() {
  if (key == 'w') {
    keyCode[0] = false;
  }
  if (key == 's') {
    keyCode[1] = false;
  }
  if (key == 'a') {
    keyCode[2] = false;
  }
  if (key == 'd') {
    keyCode[3] = false;
  }
}
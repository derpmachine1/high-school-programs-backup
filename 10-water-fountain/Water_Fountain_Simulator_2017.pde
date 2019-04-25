//For 2018
//Object oriented
//When the water level passes the foutnain, the water particels stop
//Fire alarm falls off
//Water sprinklers for fire

//Cool settings
float watersize = 10;  //Changes water size and affects speed of filling everything
float waterspeedx = -1;
float waterspeedy = -5;
float gravity = 0.5;
float random = 0.02;  //Randomness of x velocity for water
float waterlevelspeed = 500;  //The smaller, the faster

//Variable for water amount in fountain
float lmao = 0;
//variable for water level in room
float xd = 0;

//Water
int water = 0;
float[] waterx = new float[10000]; 
float[] dwaterx = new float[10000];
float[] watery = new float[10000];
float[] dwatery = new float[10000];

//Wateroverflow
int waterof = 0;
float[] waterofx = new float[10000];
float[] dwaterofx = new float[10000];
float[] waterofy = new float[10000];
float[] dwaterofy = new float[10000];

//Fire alarm
float alarmx = 0;
float alarmy = 0;

void setup() {
  size(500, 500);
  noStroke();
}

void draw() {
  background(225);

  //Water
  if (keyPressed) {
    createwater();
  }
  runwater();
  
  //Ground
  fill(175);
  rect(0, 400, 500, 100);
  
  //If sink is full, add to water level and create water overflow
  if (lmao >= 100) {
    createwaterof();
  }
  runwaterof();
  
  
  lmao = constrain(lmao - 0.25, 0, 100);

  //Fountain body
  fill(255);
  rect(200, 350, 100, 75);
  //Bottom pipe
  fill(150);
  rect(240, 425, 20, 35);
  //Mouth thingy
  rect(270, 330, 20, 20);
  
  //Alarm
  fill(200);
  rect(375, 130, 50, 25);
  fill(150);
  //Alarm activation
  if (500 - xd < 400) {
    alarmx += random(-random * 100, random * 100);
    alarmy += random(-random * 100, random * 100);
    alarmx = alarmx * 0.5;
    alarmy = alarmy * 0.5;
    fill(255, 0, 0);
  }
  
  textSize(24);
  text("FIRE", 375, 150);
  fill(150, 0, 0);
  ellipse(400 + alarmx, 100 + alarmy, 50, 50);
  fill(200, 200, 100);
  ellipse(400 + alarmx, 100 + alarmy, 25, 25);
  fill(0);
  ellipse(400 + alarmx, 100 + alarmy, 3, 3);

  //Floodwater
  fill(50, 50, 255, 200);
  rect(0, 500 - xd, 500, xd);

  //Text
  fill(0);
  textSize(24);
  text("Water Fountain Simulator 2017", 10, 30);
  textSize(12);
  text("Water level in fountain: " + floor(lmao) + "%", 10, 50);
  text("Water level in room: " + floor(xd / 5 * 3) + "cm", 10, 70);
}
 
void createwater() {
  waterx[water] = 280;
  dwaterx[water] = waterspeedx;
  watery[water] = 340;
  dwatery[water] = waterspeedy + sin(millis())*watersize*random;
  water++;
}

void runwater() {
  for (int i = 0; i < water; i++) {
    //Changes positions and speeds
    waterx[i] += dwaterx[i];
    watery[i] += dwatery[i];
    dwatery[i] += gravity;
    //Adds to sink level if it lands inside the sink
    if (watery[i] > 360 && watery[i] < 500 && abs(250 - waterx[i]) < 50) {
      lmao += watersize/(waterlevelspeed/5);
    //Adds to water level if it lands outside the sink
    } else if (watery[i] > 360 && watery[i] < 500 && abs(250 - waterx[i]) > 50) {
      xd += watersize/(waterlevelspeed*4);
    }
    //Draws water
    if (watery[i] < 500) {
      fill(50, 50, 255);
      ellipse(waterx[i], watery[i], watersize, watersize);
    }
  }
}

void createwaterof() {
  waterofx[waterof] = 250;
  dwaterofx[waterof] = sin(millis())*watersize*random/10;
  waterofy[waterof] = 350 - watersize/2;
  dwaterofy[waterof] = 0;
  waterof++;
}

void runwaterof() {
  for (int i = 0; i < waterof; i++) {
    //Changes positions and speeds
    waterofx[i] += dwaterofx[i];
    waterofy[i] += dwaterofy[i];
    dwaterofy[i] += gravity;
    //Adds to water level
    if (waterofy[i] > 500 && waterofy[i] < 600) {
      xd += watersize/(waterlevelspeed*2);
    }
    //Draws water
    if (waterofy[i] < 500) {
      fill(50, 50, 255);
      rect(waterofx[i] - 50 - watersize/2, waterofy[i], watersize, watersize * 2);
      rect(waterofx[i] + 50 - watersize/2, waterofy[i], watersize, watersize * 2);
    }
  }
}
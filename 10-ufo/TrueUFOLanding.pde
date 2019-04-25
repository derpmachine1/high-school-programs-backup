PImage sunimg;
PImage moonimg;
PImage laserimg;

//Experimental sound stuff
import ddf.minim.*;
Minim minim;
AudioSample oofsound;
AudioPlayer oWo;

//Sky variables
float faketime = 0;
float deltafaketime = 1;
float sunx = 0;
float suny = 0;
float moonx = 0;
float moony = 0;
float sky = 0;
float imdumb = 0;

//UFO variables
float x = 300;
float y = 600;
boolean keys[] = new boolean[5];
float ufospeed = 1;
float deltax = 0;
float deltay = 0;

//Tree variables
boolean tree = false;
int[] treetype = new int[1000];
float[] treex = new float[1000];
float[] treey = new float[1000];

//Laser variables
int lasernum = 0;
float laserspeed = 10;
float[] laserx = new float[10000];
float[] lasery = new float[10000];

//Draws tree for each entry in treex and treey
void drawtree() {
  for (int i = 0; i < 100; i++) {
    if (treetype[i] == 0) {
      fill(0, 75, 0);
      triangle(treex[i] - 20, treey[i], treex[i] + 20, treey[i], treex[i], treey[i] - 75);
    } else {
      fill(100, 50, 10);
      rect(treex[i] - 10, treey[i] - 20, 20, 40);
      fill(0, 75, 0);
      ellipse(treex[i], treey[i] - 20, 50, 50);
    }
  }
}

//Laser
void laser(int x) {
  for (int i = 0; i < x; i++) {
    fill(255, 255, 0);
    image(laserimg, laserx[i] - 50 - lasery[i] / 10, lasery[i] + 25, 100 + lasery[i] / 5, 100 + lasery[i] / 5);
    if (lasery[i] > 800 && lasery[i] < 900) {
      fill(255);
      text("oof", laserx[i] + 50 + lasery[i] / 10, lasery[i]);
      text("xd", random(0, 900), random(0, 900));
      imdumb += 0.2;
    }
    lasery[i] += laserspeed;
  }
}

void setup() {
  size(900, 900);
  frameRate(30);
  minim = new Minim(this);
  oofsound = minim.loadSample("oof.mp3");
  oWo = minim.loadFile("russia.mp3");
  oWo.loop();
  oofsound.setGain(5);
  oWo.setGain(-20);
  sunimg = loadImage("elongated_muskrat.jpg");
  moonimg = loadImage("help.png");
  laserimg = loadImage("pizza.jpg");
}

void draw() {
  //faketime += deltafaketime;                                  //Time
  faketime += sqrt(sq(deltax) + sq(deltay)) / 10;
  if (faketime >= 24) {
    faketime = 0;
  }

  sky = 255 * sin(2 * PI * (faketime - 6) / 24) + 45;           //Sky colour
  
  background(0.5 * sky, 0.5 * sky, sky);
  strokeWeight(0);
  textSize(30); 

  sunx = 450 - 500 * cos(2 * PI * (faketime - 6) / 24);
  suny = 700 - 500 * sin(2 * PI * (faketime - 6) / 24);

  moonx = 450 - 500 * cos(2 * PI * (faketime + 6) / 24);
  moony = 700 - 500 * sin(2 * PI * (faketime + 6) / 24);

  fill(150);
  image(moonimg, moonx - 25 - 0.5 * imdumb, moony - 25 - 0.5 * imdumb, 50 + imdumb, 50 + imdumb);

  fill(200, 200, 0);
  image(sunimg, sunx - 25 - 0.5 * imdumb, suny - 25 - 0.5 * imdumb, 50 + imdumb, 50 + imdumb);

  fill(0, 50, 0);
  rect(0, 800, 900, 100);                                       //Ground

  if (tree == false) {                                          //Generates random positions for trees once
    for (int i = 1; i < 100; i++) {
      treex[i] = treex[i - 1] + random(10, 25);
      treey[i] = random(820, 880);
      treetype[i] = round(random(0, 1));
    }
    tree = true;
  }

  fill(75);                                                     //Random building
  beginShape();
    vertex(100, 850);
    vertex(100, 650);
    vertex(150, 650);
    vertex(150, 750);
    vertex(175, 850);
  endShape();

  drawtree();                                                   //Draws trees
  if (keys[4] == true) {                                        //New laser
    laserx[lasernum] = x;
    lasery[lasernum] = y;
    lasernum++;
    oofsound.trigger();
  }

  laser(lasernum);                                              //Laser

  if (keys[0] == true) {                                        //Up
    deltay -= ufospeed;
  }
  if (keys[1] == true) {                                        //Down
    deltay += ufospeed;
  }
  if (keys[2] == true) {                                        //Left
    deltax -= ufospeed;
  }
  if (keys[3] == true) {                                        //Right
    deltax += ufospeed;
  }

  x = x + deltax;                                               //UFO change
  y = y + deltay;

  if (x > 900) {                                                //Keeps within box
    x = 900;
    deltax = 0;
  }
  if (x < 0) {
    x = 0;
    deltax = 0;
  }
  if (y > 900) {
    y = 900;
    deltay = 0;
  }
  if (y < 0) {
    y = 0;
    deltay = 0;
  }


  deltax = 0.9 * deltax;                                        //UFO Slowing
  deltay = 0.9 * deltay;

  fill(150);
  arc(x, y + 20, 50, 25, 0, PI);
  fill(75);
  ellipse(x, y, 150, 50);                                       //UFO body
  fill(150);
  ellipse(x, y - 15, 60, 40);                                   //UFO Cockpit
  fill(150, 150, 150, 50);
  ellipse(200, 200, 250, 100);                                  //Clouds
  ellipse(450, 300, 200, 75);
  ellipse(700, 150, 225, 125); 
}

void keyPressed() {                                             //Keys
  if(key == 'w')
    keys[0]=true;
  if(key == 's')
    keys[1]=true;
  if(key == 'a')
    keys[2]=true;
  if(key == 'd')
    keys[3]=true;
  if(key == ' ')
    keys[4]=true;
}

void keyReleased() {
  if(key == 'w')
    keys[0]=false;
  if(key == 's')
    keys[1]=false;
  if(key == 'a')
    keys[2]=false;
  if(key == 'd')
    keys[3]=false;
  if(key == ' ')
    keys[4]=false;
}
//these functions/classes amke the intro animations

//Animates the intro reveal thing, takes 8.5 seconds
void Intro() {
  timer = constrain(timer - 1, 0, 570);
  fill(0);
  if (mode == 0) {
    if (timer > 180) {
      rect(0, 0, 500, 250 + (timer - 180) / 410 * 250);
    } else {
      rect(0, 0, 500, timer / 180 * 250);
    }
  }
}

//Moves title up and down
void MoveTitle() {
  if (titlemoveup == true) {
    titlemove -= 0.3705;    //For the unused title music, change to 0.2555
  }
  if (titlemoveup == false) {
    titlemove += 0.3705;    //For the unused title music, change to 0.2555
  }
  if (titlemove <= -5) {
    titlemove = -5;
    titlemoveup = false;
  }
  if (titlemove >= 5) {
    titlemove = 5;
    titlemoveup = true;
  }
}

void Lighting() {
  //Spotlights
  for (int i = 0; i < spotlights.length; i++) {
    spotlights[i].Move();
    spotlights[i].Draw();
  }
  
  //Stars
  //Changes star acceleration
  if (deltastarx > 10 * starxamt) {
    starxright = false;
    starxamt = random(0.5, 1);
  }
  if (deltastarx < -10 * starxamt) {
    starxright = true;
    starxamt = random(0.5, 1);
  }
  if (deltastary > 10 * staryamt) {
    starydown = false;
    staryamt = random(0.5, 1);
  }
  if (deltastary < -10 * staryamt) {
    starydown = true;
    staryamt = random(0.5, 1);
  }
  //Changes star speed
  if (starxright) {
    deltastarx += 0.1;
  } else {
    deltastarx -= 0.1;
  }
  if (starydown) {
    deltastary += 0.1;
  } else {
    deltastary -= 0.1;
  }
  //Changes star location
  starx += deltastarx;
  stary += deltastary;
  if (starx > 50) {
    starx -= 50;
  }
  if (starx < -50) {
    starx += 50;
  }
  if (stary > 50) {
    stary -= 50;
  }
  if (stary < -50) {
    stary += 50;
  }
  
  //Draws stars
  for (float x = starx - 500; x <= starx + 500; x += 50) {
    for (float y = stary - 500; y <= stary + 500; y += 50) {
      noStroke();
      fill(255, 255, 255, constrain((180 - timer) / 180 * 25, 0, 255));
      beginShape();
      vertex(x, y - starsize);
      vertex(x + starsize / 4, y - starsize / 4);
      vertex(x + starsize, y);
      vertex(x + starsize / 4, y + starsize / 4);
      vertex(x, y + starsize);
      vertex(x - starsize / 4, y - starsize / 4);
      vertex(x - starsize, y);
      vertex(x - starsize / 4, y + starsize / 4);
      endShape();
      stroke(0);
    }
  }
}

class Spotlight {
  float rotated;
  boolean phase;
  float speed;
  float size;
  boolean left;
  
  Spotlight(boolean templeft, float i) {
    rotated = 0 + i * ((PI / 2) / floor(spotlights.length / 2));
    speed = 0.01 * random(1, 2);
    size = PI / 16;
    left = templeft;
  }
  
  void Move() {
    if (phase) {
      rotated += speed;
    } else {
      rotated -= speed;
    }
    if (rotated > PI / 2 - size) {
      rotated = PI / 2 - size;
      phase = false;
    }
    if (rotated < 0) {
      rotated = 0;
      phase = true;
    }
  }
  
  void Draw() {
    noStroke();
    pushMatrix();
    if (abs(titlemove) > 2.5) {
      fill(255, 255, 255, constrain((180 - timer) / 180 * (25 + 10 * (abs(titlemove) - 2.5)), 0, 255));
    } else {
      fill(255, 255, 255, constrain((180 - timer) / 180 * 25, 0, 255));
    }
    if (left) {
      rotate(rotated);
      arc(0, 0, 1500, 1500, 0, size, PIE);
    } else {
      translate(500, 0);
      rotate(PI - rotated - size);
      arc(0, 0, 1500, 1500, 0, size, PIE);
    }
    popMatrix();
    stroke(0);
  }
}

void SetName() {
  name = useranswer;
}
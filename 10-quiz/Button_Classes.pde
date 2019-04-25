//These are functions that create buttons

//Function to draw a button
void Button(float x, float y, float w, float h, color colour1, color colour1light, color colour2, float textsize, String text) {
  //Lighten when hovered over
  if(mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
    fill(colour1light);
    cursor(HAND);
    //If clicked, do the designated action
    if (mousePressed && buttondelay == 0) {
      Progress();
    }
  } else {
    fill(colour1);
    cursor(ARROW);
  }
  rect(x, y, w, h);
  fill(colour2);
  textSize(textsize);
  text(text, x + w / 2, y + (h - textsize) / 2 + textsize * 0.9);
}

void AnswerButton(float x, float y, float w, float h, color colour1, color colour1light, color colour2, float textsize, String text, String answer) {
  //Lighten when hovered over
  if(mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
    fill(colour1light);
    cursor(HAND);
    //If clicked, do the designated action
    if (mousePressed && buttondelay == 0) {
      SetAnswer(answer);
      Progress();
    }
  } else {
    fill(colour1);
    cursor(ARROW);
  }
  rect(x, y, w, h);
  fill(colour2);
  textSize(textsize);
  rectMode(RADIUS);
  text(text, x + w / 2, y + h * 0.6, w / 2, h / 2);
  rectMode(CORNER);
}
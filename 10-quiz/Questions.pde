//Initializes the question arrays with data from the tables (which in turn are from the text files)

void LoadMChoice() {
  for (int i = 0; i < mchoices.length; i++) {
    TableRow row = tempmchoices.getRow(i);
    mchoices[i] = new MChoice(
      row.getString("tempq"),
      row.getString("tempa1"),
      row.getString("tempa2"),
      row.getString("tempa3"),
      row.getString("tempa4"),
      row.getString("tempcorrect")
    );
  }
}

void LoadThreeTry() {
  for (int i = 0; i < threetries.length; i++) {
    TableRow row = tempthreetries.getRow(i);
    threetries[i] = new ThreeTry(
      row.getString("tempq"),
      row.getString("tempa1"),
      row.getString("tempa2"),
      row.getString("tempa3"),
      row.getString("tempa4"),
      row.getString("tempa5"),
      row.getString("tempcorrect")
    );
  }
}

void LoadTF() {
  for (int i = 0; i < tfs.length; i++) {
    TableRow row = temptfs.getRow(i);
    tfs[i] = new TF(
      row.getString("tempq"),
      row.getString("tempcorrect")
    );
  }
}

void LoadFBlank() {
  for (int i = 0; i < fblanks.length; i++) {
    TableRow row = tempfblanks.getRow(i);
    fblanks[i] = new FBlank(
      row.getString("tempq"),
      row.getString("tempcorrect1"),
      row.getString("tempcorrect2"),
      row.getString("tempcorrect3"),
      row.getString("tempcorrect4")
    );
    for (int j = 0; j < 4; j++) {
      if (fblanks[i].correct[j].equals("x")) {
        fblanks[i].correct[j] = workaroundanswer;
    }
    }
  }
}
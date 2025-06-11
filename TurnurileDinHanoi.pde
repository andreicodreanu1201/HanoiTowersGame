// Clasa Disc - reprezintă un disc din turnurile Hanoi
class Disc {
  float diametru, inaltime;
  color culoare;
  float yOffset; // Offset vertical pentru poziționarea pe tijă
  
  Disc(float diametru, float inaltime, color culoare, float yOffset) {
    this.diametru = diametru;
    this.inaltime = inaltime;
    this.culoare = culoare;
    this.yOffset = yOffset;
  }
  
  // Afișează discul pe ecran
  void afiseaza(float x, boolean esteSelectat) {
    pushMatrix();
    translate(x, 370 - yOffset, 0); // Ajustare poziție verticală
    
    // Evidențiere disc selectat
    if (esteSelectat) {
      stroke(255, 255, 0);
      strokeWeight(3);
    } else {
      noStroke();
    }
    
    fill(culoare);
    // Desenează un cilindru pentru disc
    drawCylinder(inaltime, diametru/2, diametru/2, 32);
    popMatrix();
  }
  
  // Funcție helper pentru desenarea unui cilindru
  void drawCylinder(float h, float r1, float r2, int sides) {
    float angle = 0;
    float angleIncrement = TWO_PI / sides;
    beginShape(QUAD_STRIP);
    for (int i = 0; i <= sides; i++) {
      vertex(r1 * cos(angle), -h/2, r1 * sin(angle));
      vertex(r2 * cos(angle), h/2, r2 * sin(angle));
      angle += angleIncrement;
    }
    endShape();
    
    // Desenează partea de sus și de jos
    beginShape(TRIANGLE_FAN);
    vertex(0, h/2, 0);
    angle = 0;
    for (int i = 0; i <= sides; i++) {
      vertex(r2 * cos(angle), h/2, r2 * sin(angle));
      angle += angleIncrement;
    }
    endShape();
    
    beginShape(TRIANGLE_FAN);
    vertex(0, -h/2, 0);
    angle = 0;
    for (int i = 0; i <= sides; i++) {
      vertex(r1 * cos(angle), -h/2, r1 * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }
}

// Variabile globale
ArrayList<Disc>[] tije = new ArrayList[3];       // Cele 3 tije ale jocului
ArrayList<Disc>[] backupTije = new ArrayList[3];  // Backup pentru starea tijelor
int backupMutari;                                // Backup pentru numărul de mutări
Disc discSelectat = null;                        // Disc selectat curent
int tijaSelectata = -1;                          // Indexul tijei selectate
int mutari;                                      // Numărul total de mutări
int numarDiscuri = 4;                            // Numărul de discuri

// Variabile pentru animație
float animX, animY, animZ;                       // Poziția discului în animație
float startX, startY, midX, midY, endX, endY;    // Punctele de tranzitie în animație
int etapaAnimatie = 0;                           // Etapa curentă a animației
float progressAnimatie = 0;                      // Progresul animației
float vitezaAnimatie = 0.05;                     // Viteza animației
Disc discInMiscare = null;                       // Discul în mișcare

// Variabile pentru animație de mutare invalidă
boolean animatieInvalidMove = false;             // Flag pentru mutare invalidă
float invalidMoveStartX, invalidMoveStartY;      // Poziții de start pentru animație invalidă
float invalidMoveEndX, invalidMoveEndY;          // Poziții finale pentru animație invalidă
float invalidMoveProgress = 0;                   // Progres animație invalidă

// Variabile pentru final de joc
boolean jocTerminat = false;                     // Flag pentru joc terminat
boolean castigat = false;                        // Flag pentru victorie
boolean instructionsFromGame = false;             // Flag pentru afișare instrucțiuni din joc

// Variabile pentru interfață
boolean showDiscSelection = true;                // Afișează ecranul de selecție discuri
boolean showInstructions = false;                // Afișează ecranul de instrucțiuni
Button startButton, resetButton, instructionsButton, mainMenuButton; // Butoane interfață

// Clasa Button - pentru butoanele interfeței
class Button {
  float x, y, w, h;
  String text;
  color bgColor, textColor;
  
  Button(float x, float y, float w, float h, String text) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.text = text;
    this.bgColor = color(100, 150, 255);
    this.textColor = color(255);
  }
  
  // Desenează butonul
  void display() {
    fill(bgColor);
    rect(x, y, w, h, 5);
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(18);
    text(text, x + w/2, y + h/2);
  }
  
  // Verifică dacă mouse-ul este peste buton
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }
}

// Funcția de inițializare
void setup() {
  fullScreen(P3D);
  surface.setTitle("Turnurile din Hanoi");
  
  // Inițializare butoane
  startButton = new Button(width/2 - 100, height/2 + 50, 200, 50, "START JOC");
  resetButton = new Button(width - 280, 30, 120, 40, "RESET");
  mainMenuButton = new Button(width - 150, 30, 120, 40, "MENIU");
  instructionsButton = new Button(width/2 - 100, height/2 + 120, 200, 50, "INSTRUCTIUNI");
  
  initializeGame();
}

// Inițializează jocul
void initializeGame() {
  mutari = 0;
  for (int i = 0; i < 3; i++) {
    tije[i] = new ArrayList<Disc>();
  }
  
  // Adaugă discuri pe prima tijă dacă nu suntem în meniu
  if (!showDiscSelection && !showInstructions) {
    float baseDiameter = 180;
    float heightStep = 20;
    float yOffsetStep = 25;
    
    for (int i = 0; i < numarDiscuri; i++) {
      float currentDiameter = baseDiameter - i * (baseDiameter/numarDiscuri);
      color discColor = color(
        (i * 255/numarDiscuri) % 255, 
        (i * 150/numarDiscuri + 100) % 255, 
        (i * 75/numarDiscuri + 180) % 255
      );
      tije[0].add(new Disc(currentDiameter, heightStep, discColor, i * yOffsetStep));
    }
  }
}

// Funcția principală de desenare
void draw() {
  background(230);
  lights();
  
  // Afișează ecranul de selecție discuri dacă e cazul
  if (showDiscSelection) {
    drawDiscSelectionScreen();
    return;
  }
  
  // Afișează ecranul de instrucțiuni dacă e cazul
  if (showInstructions) {
    drawInstructionsScreen();
    return;
  }
  
  // Centrare viewport joc
  translate(width/2, height/2, 0);
  
  // Desenează suportul
  fill(150);
  noStroke();
  pushMatrix();
  translate(0, 400, 0);
  box(600, 20, 100);
  popMatrix();
  
  // Desenează tijele
  for (int i = -1; i <= 1; i++) {
    pushMatrix();
    translate(i * 200, 250, 0);
    fill(100);
    noStroke();
    box(10, 300, 10); 
    popMatrix();
  }
  
  // Actualizează animația
  updateAnimatie();
  
  // Desenează discurile
  for (int t = 0; t < 3; t++) {
    for (int i = 0; i < tije[t].size(); i++) {
      Disc d = tije[t].get(i);
      if (d == discInMiscare) continue;
      boolean esteSelectat = (d == discSelectat && discInMiscare == null && !animatieInvalidMove);
      d.afiseaza(t * 200 - 200, esteSelectat);
    }
  }
  
  // Desenează discul în mișcare
  if (discInMiscare != null) {
    pushMatrix();
    translate(animX, animY, 0);
    fill(discInMiscare.culoare);
    stroke(255, 255, 0);
    strokeWeight(3);
    discInMiscare.drawCylinder(discInMiscare.inaltime, discInMiscare.diametru/2, discInMiscare.diametru/2, 32);
    popMatrix();
  }
  
  // Desenează interfața utilizator
  drawUI();
  
  // Afișează ecranul de final de joc dacă e cazul
  if (jocTerminat) {
    drawGameOverScreen();
  }
}

// Desenează ecranul de selecție a numărului de discuri
void drawDiscSelectionScreen() {
  background(200);
  fill(0);
  textSize(48);
  textAlign(CENTER, CENTER);
  text("TURNURILE DIN HANOI", width/2, 150);
  
  textSize(32);
  text("Alege numărul de discuri:", width/2, 250);
  
  // Butoane pentru selectarea numărului de discuri
  for (int i = 3; i <= 10; i++) {
    float x = width/2 - 250 + (i-3) * 60;
    float y = 300;
    boolean isSelected = (i == numarDiscuri);
    
    fill(isSelected ? color(100, 150, 255) : color(180));
    rect(x, y, 50, 50, 10);
    fill(0);
    textSize(24);
    text(str(i), x + 25, y + 25);
  }
  
  // Butoane principale
  startButton = new Button(width/2 - 150, 400, 300, 70, "START JOC");
  instructionsButton = new Button(width/2 - 150, 500, 300, 70, "INSTRUCTIUNI");
  
  startButton.display();
  instructionsButton.display();
}

// Desenează ecranul de instrucțiuni
void drawInstructionsScreen() {
  background(200);
  fill(0);
  textSize(48);
  textAlign(CENTER, CENTER);
  text("INSTRUCTIUNI JOC", width/2, 100);
  
  textSize(20);
  textAlign(LEFT);
  String instructions = 
    "Scopul jocului este să muți toate discurile de pe prima tijă pe ultima tijă, respectând următoarele reguli:\n\n" +
    "1. Poți muta un singur disc odată.\n" +
    "2. Poți pune un disc peste un disc mai mare sau pe o tijă goală.\n" +
    "3. Nu poți pune un disc mai mare peste unul mai mic.\n\n" +
    "Cum se joacă:\n" +
    "- Click pe o tijă pentru a selecta discul de sus\n" +
    "- Click pe o altă tijă pentru a încerca să muți discul acolo\n" +
    "- Dacă mutarea este invalidă, discul se va întoarce automat\n\n" +
    "Indicator:\n" +
    "- Discul selectat este evidențiat cu contur galben";
    
  // Afișează instrucțiunile pe rânduri
  float y = 180;
  for (String line : instructions.split("\n")) {
    text(line, width/2 - 350, y, 700, 100);
    y += 35;
  }
  
  // Butoane pentru navigare
  Button backButton = new Button(width/2 - 350, height - 150, 300, 70, "MENIU PRINCIPAL");
  String continueButtonText = instructionsFromGame ? "REVENIRE LA JOC" : "START JOC";
  Button continueButton = new Button(width/2 + 50, height - 150, 300, 70, continueButtonText);
  
  backButton.display();
  continueButton.display();
  
  // Gestionează click-urile pe butoane
  if (mousePressed) {
    if (mouseX >= width/2 - 350 && mouseX <= width/2 - 50 && mouseY >= height - 150 && mouseY <= height - 80) {
      showInstructions = false;
      showDiscSelection = true;
      instructionsFromGame = false;
    }
    else if (mouseX >= width/2 + 50 && mouseX <= width/2 + 350 && mouseY >= height - 150 && mouseY <= height - 80) {
      showInstructions = false;
      if (instructionsFromGame) {
        restoreGameState();
      } else {
        initializeGame();
      }
      instructionsFromGame = false;
    }
  }
}

// Desenează interfața utilizator în timpul jocului
void drawUI() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  noStroke();
  // Informații joc
  fill(0);
  textSize(24);
  textAlign(LEFT);
  text("Mutări efectuate: " + mutari, 30, 40);
  text("Discuri: " + numarDiscuri, 30, 80);
  
  // Indicator ajutor
  fill(100, 150, 255);
  textAlign(RIGHT);
  textSize(24);
  text("Apasă H pentru ajutor", width - 30, 40);
  
  // Butoane acțiuni
  resetButton.x = width - 280;
  resetButton.y = 70;
  resetButton.display();
  
  mainMenuButton.x = width - 150;
  mainMenuButton.y = 70;
  mainMenuButton.display();
  
  hint(ENABLE_DEPTH_TEST);
}

// Desenează ecranul de final de joc
void drawGameOverScreen() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  fill(0, 150);
  rect(0, 0, width, height);
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  
  if (castigat) {
    text("Felicitări! Ai câștigat!", width/2, height/2 - 30);
    text("Mutări totale: " + mutari, width/2, height/2 + 30);
  }
  
  // Butoane pentru restart și meniu
  Button restartButton = new Button(width/2 - 150, height/2 + 80, 140, 50, "RESTART");
  Button menuButton = new Button(width/2 + 10, height/2 + 80, 140, 50, "MENIU");
  
  restartButton.display();
  menuButton.display();
  
  // Gestionează click-urile pe butoane
  if (mousePressed) {
    if (restartButton.isMouseOver()) {
      restartGame();
    } else if (menuButton.isMouseOver()) {
      showDiscSelection = true;
      jocTerminat = false;
    }
  }
  
  hint(ENABLE_DEPTH_TEST);
}

// Actualizează animația curentă
void updateAnimatie() {
  if (etapaAnimatie == 0) return;
  
  progressAnimatie += vitezaAnimatie;
  
  // Gestionează diferitele etape ale animației
  if (etapaAnimatie == 1) { // Ridicare
    animX = startX;
    animY = lerp(startY, midY, progressAnimatie);
    if (progressAnimatie >= 1) {
      etapaAnimatie = animatieInvalidMove ? 4 : 2;
      progressAnimatie = 0;
    }
  } 
  else if (etapaAnimatie == 2) { // Mutare orizontală validă
    animX = lerp(startX, endX, progressAnimatie);
    animY = midY;
    if (progressAnimatie >= 1) {
      etapaAnimatie = 3;
      progressAnimatie = 0;
    }
  }
  else if (etapaAnimatie == 3) { // Coborâre validă
    animX = endX;
    animY = lerp(midY, endY, progressAnimatie);
    if (progressAnimatie >= 1) {
      etapaAnimatie = 0;
      finalizeazaMutare();
    }
  }
  else if (etapaAnimatie == 4) { // Mutare orizontală invalidă (dus)
    animX = lerp(startX, endX, progressAnimatie);
    animY = midY;
    if (progressAnimatie >= 1) {
      etapaAnimatie = 5;
      progressAnimatie = 0;
    }
  }
  else if (etapaAnimatie == 5) { // Coborâre invalidă (dus)
    animX = endX;
    animY = lerp(midY, endY, progressAnimatie);
    if (progressAnimatie >= 1) {
      etapaAnimatie = 6;
      progressAnimatie = 0;
    }
  }
  else if (etapaAnimatie == 6) { // Ridicare invalidă (întors)
    animX = endX;
    animY = lerp(endY, midY, progressAnimatie);
    if (progressAnimatie >= 1) {
      etapaAnimatie = 7;
      progressAnimatie = 0;
    }
  }
  else if (etapaAnimatie == 7) { // Mutare orizontală invalidă (întors)
    animX = lerp(endX, startX, progressAnimatie);
    animY = midY;
    if (progressAnimatie >= 1) {
      etapaAnimatie = 8;
      progressAnimatie = 0;
    }
  }
  else if (etapaAnimatie == 8) { // Coborâre invalidă (întors)
    animX = startX;
    animY = lerp(midY, startY, progressAnimatie);
    if (progressAnimatie >= 1) {
      etapaAnimatie = 0;
      finalizeazaMutare();
    }
  }
}

// Finalizează mutarea curentă
void finalizeazaMutare() {
  discInMiscare = null;
  discSelectat = null;
  tijaSelectata = -1;
  if (!animatieInvalidMove) {
    verificaFinalJoc();
  }
  animatieInvalidMove = false;
}

// Inițializează animația pentru o mutare validă
void incepeAnimatie(int tijaDestinatie) {
  discInMiscare = discSelectat;
  
  // Poziția inițială
  startX = tijaSelectata * 200 - 200;
  startY = 350 - discSelectat.yOffset;
  
  // Poziția ridicată
  midX = startX;
  midY = 80;
  
  // Poziția finală
  endX = tijaDestinatie * 200 - 200;
  
  if (tije[tijaDestinatie].isEmpty()) {
    endY = 350;
  } else {
    Disc topDisc = tije[tijaDestinatie].get(tije[tijaDestinatie].size() - 1);
    endY = 350 - topDisc.yOffset - 25;
  }
  
  // Actualizează offset-ul vertical
  discSelectat.yOffset = 350 - endY;
  
  // Inițializează animația
  animX = startX;
  animY = startY;
  etapaAnimatie = 1;
  progressAnimatie = 0;
  
  // Actualizează structurile de date
  tije[tijaSelectata].remove(discSelectat);
  tije[tijaDestinatie].add(discSelectat);
  mutari++;
}

// Inițializează animația pentru o mutare invalidă
void incepeAnimatieInvalidMove(int tijaDestinatie) {
  discInMiscare = discSelectat;
  
  // Poziția inițială
  startX = tijaSelectata * 200 - 200;
  startY = 350 - discSelectat.yOffset;
  
  // Poziția ridicată
  midX = startX;
  midY = 80;
  
  // Poziția finală
  endX = tijaDestinatie * 200 - 200;
  
  if (tije[tijaDestinatie].isEmpty()) {
    endY = 350;
  } else {
    Disc topDisc = tije[tijaDestinatie].get(tije[tijaDestinatie].size() - 1);
    endY = 350 - topDisc.yOffset - 25;
  }
  
  // Marchează ca animație invalidă
  animatieInvalidMove = true;
  
  // Inițializează animația
  animX = startX;
  animY = startY;
  etapaAnimatie = 1;
  progressAnimatie = 0;
}

// Gestionează click-urile mouse-ului
void mousePressed() {
  if (showDiscSelection) {
    handleDiscSelectionClick();
    return;
  }
  
  if (resetButton.isMouseOver()) {
    restartGame();
    return;
  }
  
  if (mainMenuButton.isMouseOver()) {
    showDiscSelection = true;
    return;
  }
  
  if (jocTerminat) {
    return;
  }
  
  if (discInMiscare != null || animatieInvalidMove) return;
  
  // Calculează poziția tijelor
  float mx = mouseX - width / 2;
  float my = mouseY - height / 2;

  // Verifică dacă click-ul e în zona tijelor
  if (my < 100 || my > 400) {
    return;
  }

  // Detectează tija apăsată
  int tijaClick = -1;
  float tolerance = 30;

  if (abs(mx + 200) < tolerance) {
    tijaClick = 0;
  } else if (abs(mx) < tolerance) {
    tijaClick = 1;
  } else if (abs(mx - 200) < tolerance) {
    tijaClick = 2;
  } else {
    return;
  }
  
  // Gestionează selecția și mutarea discurilor
  if (discSelectat == null) {
    if (!tije[tijaClick].isEmpty()) {
      discSelectat = tije[tijaClick].get(tije[tijaClick].size() - 1);
      tijaSelectata = tijaClick;
    }
  } else {
    if (tijaClick == tijaSelectata) {
      // Deselectează dacă s-a apăsat pe aceeași tijă
      discSelectat = null;
      tijaSelectata = -1;
    } else {
      if (poateFiMutatPe(tijaClick, discSelectat)) {
        incepeAnimatie(tijaClick);
      } else {
        incepeAnimatieInvalidMove(tijaClick);
      }
    }
  }
}

// Gestionează apăsarea tastelor
void keyPressed() {
  if (key == 'h' || key == 'H') {
    if (!showDiscSelection && !showInstructions) {
      instructionsFromGame = true;
      backupGameState();
      showInstructions = true;
    }
  }
}

// Salvează starea curentă a jocului
void backupGameState() {
  backupMutari = mutari;
  
  for (int i = 0; i < 3; i++) {
    backupTije[i] = new ArrayList<Disc>();
    for (Disc d : tije[i]) {
      backupTije[i].add(new Disc(d.diametru, d.inaltime, d.culoare, d.yOffset));
    }
  }
}

// Restabilește starea salvată a jocului
void restoreGameState() {
  mutari = backupMutari;
  
  for (int i = 0; i < 3; i++) {
    tije[i] = new ArrayList<Disc>();
    for (Disc d : backupTije[i]) {
      tije[i].add(new Disc(d.diametru, d.inaltime, d.culoare, d.yOffset));
    }
  }
  
  // Resetează selecțiile și animațiile
  discSelectat = null;
  tijaSelectata = -1;
  discInMiscare = null;
  animatieInvalidMove = false;
  etapaAnimatie = 0;
  jocTerminat = false;
  castigat = false;
}

// Gestionează click-urile pe ecranul de selecție discuri
void handleDiscSelectionClick() {
  // Verifică selecția numărului de discuri
  for (int i = 3; i <= 10; i++) {
    float x = width/2 - 250 + (i-3) * 60;
    float y = 300;
    if (mouseX >= x && mouseX <= x + 50 && mouseY >= y && mouseY <= y + 50) {
      numarDiscuri = i;
      return;
    }
  }
  
  // Verifică butonul de start
  if (startButton.isMouseOver()) {
    showDiscSelection = false;
    showInstructions = false;
    initializeGame();
    return;
  }
  
  // Verifică butonul de instrucțiuni
  if (instructionsButton.isMouseOver()) {
    instructionsFromGame = false;
    showInstructions = true;
    showDiscSelection = false;
  }
}

// Verifică dacă un disc poate fi mutat pe o tijă
boolean poateFiMutatPe(int tijaDest, Disc d) {
  if (tije[tijaDest].isEmpty()) return true;
  Disc top = tije[tijaDest].get(tije[tijaDest].size() - 1);
  return d.diametru < top.diametru;
}

// Verifică dacă jocul s-a terminat
void verificaFinalJoc() {
    if (tije[2].size() == numarDiscuri) {
      jocTerminat = true;
      castigat = true;
    }
}

// Restartează jocul
void restartGame() {
  jocTerminat = false;
  castigat = false;
  mutari = 0;
  discSelectat = null;
  tijaSelectata = -1;
  discInMiscare = null;
  initializeGame();
}

// Resetează jocul complet
void resetJoc() {
  showDiscSelection = true;
  showInstructions = false;
  jocTerminat = false;
  castigat = false;
  mutari = 0;
  discSelectat = null;
  tijaSelectata = -1;
  discInMiscare = null;
  initializeGame();
}

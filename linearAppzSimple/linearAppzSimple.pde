
//immagini
PImage img;
PImage filt;

//linea che scanna
int direction = 1;
float signal;

//istogramma
int[] hist;

//colori
Tuple[] captureColors;
Tuple[] whichColor;
int[] bright;
color[] filtColors;

void setup() {
  size(640, 360);
  stroke(255);
  
  //immagine originale
  img = loadImage("sea.jpg");
  
  //immagine filtrata
  filt = loadImage("sea.jpg");
  filt.filter(BLUR, 10);
  filt.filter(POSTERIZE, 4);
  filt.loadPixels();
  filtColors = new color[filt.width];

  image(img, 0, 0);

  int count = img.width;
  //lunimosità per ogni riga
  bright = new int[count];
  //colori per ogni riga
  captureColors = new Tuple[count];

  for (int i = 0; i < count; i++) {
    captureColors[i] = new Tuple();
  }
}

void draw() {
  background(0);

  //la linea che scanna
  if (signal > img.height-1 || signal < 0) { 
    direction = direction * -1;
  }
  if (mousePressed) {
    signal = abs(mouseY % img.height);
  } 
  else {
    signal += (0.3*direction);
  }
  
  //vedere img originale o img filtrata
  int index = 0;
  if (keyPressed) {
    set(0, 0, img);
    if (key == 'f') {
     set(0, 0, filt);
     //println(whichColor);
    }
  }
  else {

    int signalOffset = int(signal)*img.width;
    
    //un nuovo array a seconda della posizione della linea
    arrayCopy(filt.pixels, signalOffset, filtColors, 0, img.width);

    hist = new int[255];
    whichColor = new Tuple[255];
    
    for (int x = 0; x < img.width; x++) { 
      
      int pixelColor = filtColors[x];
      int r = (pixelColor >> 16) & 0xff;
      int g = (pixelColor >> 8) & 0xff;
      int b = pixelColor & 0xff;
      
      //array con luminosità
      bright[index] = int(map(int(sqrt(r*r + g*g + b*b)), 0, 442, 0, 255));
     
      //array con colori 
      captureColors[index].set(r, g, b);
      
      //istogramma
      hist[bright[index]]++;
      
      index++;
    }
  }

  //ordino l'array captureColors secondo i valori di bright
  //(serve solo a livello grafico, ma così capisco meglio)
  sort(index, bright, captureColors);

  noStroke();
  beginShape(QUAD_STRIP);

  for (int i = 0; i < index; i++) {
    
    ////DISEGNA
    captureColors[i].phil();
    vertex(i, 0);
    vertex(i, height);
    
    //CAPISCI COSA C'è
    if(hist[bright[i]] > 0){
      whichColor[bright[i]] = captureColors[i];
    }
  }
  endShape();
  
  for(int i= 0; i < 255; i++){
    if(hist[i] > 40){
      //println(hist[i] + " pix of " + whichColor[i].x + " "+ whichColor[i].y + " " + whichColor[i].z);
      //se ha senso lo butto dentro ad un array list di tuple così so anche quali colori ho!!
      if(whichColor[i].x > 80 && whichColor[i].y < 10 && whichColor[i].z < 10){
        println(hist[i] + " pix of RED!");
      }
    }
  }

  stroke(255);
  line(0, signal, img.width, signal);
  
}

// Functions to handle sorting the color data

void sort(int length, int[] a, Tuple[] stuff) {
  sortSub(a, stuff, 0, length - 1);

  //una bella ricorsiva che ovviamente non capisco, ma meglio così!
}


void sortSwap(int[] a, Tuple[] stuff, int i, int j) {
  int T = a[i];
  a[i] = a[j];
  a[j] = T;

  Tuple v = stuff[i];
  stuff[i] = stuff[j];
  stuff[j] = v;
}


void sortSub(int[] a, Tuple[] stuff, int lo0, int hi0) {
  int lo = lo0;
  int hi = hi0;
  int mid;

  if (hi0 > lo0) {
    mid = a[(lo0 + hi0) / 2];

    while (lo <= hi) {
      while ( (lo < hi0) && (a[lo] < mid)) {
        ++lo;
      }
      while ( (hi > lo0) && (a[hi] > mid)) {
        --hi;
      }
      if (lo <= hi) {
        sortSwap(a, stuff, lo, hi);
        ++lo;
        --hi;
      }
    }

    if (lo0 < hi)
      sortSub(a, stuff, lo0, hi);

    if (lo < hi0)
      sortSub(a, stuff, lo, hi0);
  }
}


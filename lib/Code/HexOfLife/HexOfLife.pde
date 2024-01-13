final int GRIDSIZE = 100;

final int WINDOWSIZE = 1300;

boolean[][] colourGrid = new boolean[GRIDSIZE][GRIDSIZE];
boolean[][] newGrid = new boolean[GRIDSIZE][GRIDSIZE];

int cellSize = WINDOWSIZE / GRIDSIZE;
int half = cellSize / 2;
int quarter = cellSize / 4;

int optionSet = 1;

int refreshCounter = 60;

final color ALIVE = color(255, 255, 255);
final color DEAD = color(18, 18, 18);

boolean pause = false;
boolean doLoop = true;
boolean spacePressed = false;

boolean DEBUGMODE = false;

int[] getCenterCoord(int x, int y) {
    int[] r = new int[2];
    r[0] =  x * cellSize + (half * (y % 2 == 0 ? 1 : 2));
    r[1] = y * cellSize + (half) - (y * quarter) - y * 2;
    return r;
}

void lineTo(int[] start, int[] end) {
    if(!DEBUGMODE) {
        return;
    }
    pushMatrix();
    stroke(0, 0, 255, 64);
    strokeWeight(5);
    line(start[0], start[1], end[0], end[1]);
    popMatrix();
}

void textAt(int[] coord, int count) {
    pushMatrix();
    fill(255, 0, 0, 255);
    strokeWeight(5);
    textSize(30);
    textAlign(CENTER, CENTER);
    text(count, coord[0], coord[1]);
    popMatrix();
}

boolean checkAlive(int x, int y) {
    int aliveNeighbours = 0;
    /*
    x - 1 y x>0
    x + 1 y x<GRIDSIZE
    x y - 1 y>0
    x y + 1 y<GRIDSIZE
    x + 1 y - 1 x<GRIDSIZE y>0
    x + 1 y + 1 x<GRIDSIZE y<GRIDSIZE

    */
    int[] centerPos = getCenterCoord(x, y);
    if (x > 0) {
        if (colourGrid[x - 1][y]) {
            aliveNeighbours++;
            lineTo(centerPos, getCenterCoord(x - 1, y));
        }
    }
    if (x < GRIDSIZE - 1) {
        if (colourGrid[x + 1][y]) {
            aliveNeighbours++;
            lineTo(centerPos, getCenterCoord(x + 1, y));
        }
    }
    if (y > 0) {
        if (colourGrid[x][y - 1]) {
            aliveNeighbours++;
            lineTo(centerPos, getCenterCoord(x, y - 1));
        }
    }
    if (y < GRIDSIZE - 1) {
        if (colourGrid[x][y + 1]) {
            aliveNeighbours++;
            lineTo(centerPos, getCenterCoord(x, y + 1));
        }
    }
    if (y % 2 == 0) {
        if (x > 0 && y > 0) {
            if (colourGrid[x - 1][y - 1]) {
                aliveNeighbours++;
                lineTo(centerPos, getCenterCoord(x - 1, y - 1));
            }
        }
        if (x > 0 && y < GRIDSIZE - 1) {
            if (colourGrid[x - 1][y + 1]) {
                aliveNeighbours++;
                lineTo(centerPos, getCenterCoord(x - 1, y + 1));
            }
        }
    }
    else {
        if (x < GRIDSIZE - 1 && y > 0) {
            if (colourGrid[x + 1][y - 1]) {
                aliveNeighbours++;
                lineTo(centerPos, getCenterCoord(x + 1, y - 1));
            }
        }
        if (x < GRIDSIZE - 1 && y < GRIDSIZE - 1) {
            if (colourGrid[x + 1][y + 1]) {
                aliveNeighbours++;
                lineTo(centerPos, getCenterCoord(x + 1, y + 1));
            }
        }
    }
    if(DEBUGMODE) {
        textAt(centerPos, aliveNeighbours);
    }
    if (colourGrid[x][y]) {
        if (aliveNeighbours == 2 || aliveNeighbours == 3) {
            return true;
        }
        return false;
    }
    if (aliveNeighbours == 3) {
        return true;
    }
    return false;
}

void setColours() {
    for (int i = 0; i < GRIDSIZE; i++) {
        for (int j = 0; j < GRIDSIZE; j++) {
            colourGrid[i][j] = !colourGrid[i][j];
        }
    }
}

void buildStartingCells() {
    for (int i = 0; i < GRIDSIZE; i++) {
        for (int j = 0; j < GRIDSIZE; j++) {
            if ((int)random(100) % 6 == 0) {
                colourGrid[i][j] = true;
            }
            else {
                colourGrid[i][j] = false;
            }
        }
    }
}


void setup() {
    size(1300, 825);
    frameRate(60);
    buildStartingCells();
}

void draw() {
    background(18);
    noStroke();
    for (int i = 0; i < GRIDSIZE; i++) {
        for (int j = 0; j < GRIDSIZE; j++) {

            int[] center = getCenterCoord(i, j);
            int x = center[0];
            int y = center[1];
            if (colourGrid[i][j]) {
                fill(ALIVE);
            }
            else {
                fill(DEAD);
            }
            beginShape();
            vertex(x, y - half);
            vertex(x + half, y - quarter);
            vertex(x + half, y + quarter);
            vertex(x, y + half);
            vertex(x - half, y + quarter);
            vertex(x - half, y - quarter);
            endShape();
            // square(i * cellSize, j * cellSize, cellSize);

        }
    }
    if (!pause && doLoop)
        refreshCounter--;
    if (refreshCounter == 0) {
        if(DEBUGMODE) {
            refreshCounter = 1;
        }
        else {
            refreshCounter = 10;
        }
        for (int i = 0; i < GRIDSIZE; i++) {
            for (int j = 0; j < GRIDSIZE; j++) {
                newGrid[i][j] = checkAlive(i, j);
            }
        }
        colourGrid = newGrid;
    }
}


void keyPressed() {
    if (key == 'r') {
        refreshCounter = 60;
        buildStartingCells();
    }
    if (key == ' ' && !spacePressed) {
        pause = !pause;
        if (!doLoop) {
            spacePressed = true;
            for (int i = 0; i < GRIDSIZE; i++) {
                for (int j = 0; j < GRIDSIZE; j++) {
                    newGrid[i][j] = checkAlive(i, j);
                }
            }
            colourGrid = newGrid;
        }
    }
    if (key == 'l') {
        doLoop = !doLoop;
    }

    if (key == 'D') {
        DEBUGMODE = !DEBUGMODE;
    }
}

void keyReleased() {
    spacePressed = false;
}

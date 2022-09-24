int NumWalls = 20;

Wall[] walls = new Wall[NumWalls + 4];
Ray r;
Emitter e;

boolean drawWalls = false;
int delay = 0;

void setup() {
    size(1200,1200);
    for (int i = 0; i < walls.length; i++) {
        walls[i] = new Wall((int)random(0, width),(int)random(0, height),(int)random(0, width),(int)random(0, width));
    }
    // walls[0] = new Wall(100,100, 400,400);
    // walls[1] = new Wall(100,400, 400,700);
    // walls[2] = new Wall(400,700, 700,400);
    walls[NumWalls] = new Wall(0, 0, width-1, 0);
    walls[NumWalls + 1] = new Wall(0,0, 0, height-1);
    walls[NumWalls + 2] = new Wall(0, height-1, width-1, height-1);
    walls[NumWalls + 3] = new Wall(width-1, 0, width-1, height-1);
    e = new Emitter(100,700, 2);
}

void draw()
{
    background(0);
    if (keyPressed) {
        if (key == 'b' && delay == 0) {
            drawWalls = !drawWalls;
            delay = 30;
        }
        if (key == 'p') {
            exit();
        }
        if (key == 'v' && delay == 0) {
            e.drawLines();
            delay = 30;
        }
    }
    if (drawWalls) {
        for (int i = 0; i < walls.length; i++) {
            walls[i].draw();
        }
    }

    e.move(mouseX, mouseY);
    stroke(255);
    strokeWeight(5);
    point(mouseX, mouseY);
    e.draw();
    e.test(walls);
    if (delay > 0) {
        delay--;
    }
}


class Wall{

    public PVector a = new PVector();
    public PVector b = new PVector();

    Wall(int x1, int y1, int x2, int y2) {
        a.x = x1;
        a.y = y1;
        b.x = x2;
        b.y = y2;
    }

    void draw()
    {
        stroke(255);
        strokeWeight(1);
        line(a.x, a.y,b.x, b.y);
    }
}


class Ray{

    PVector pos = new PVector();
    PVector dir = new PVector();
    float angle;
    int depth;

    Ray(float x, float y, float angle, int depth) {
        this.depth = depth;
        while(angle > TWO_PI) {
            angle -= TWO_PI;
        }
        this.angle = angle;
        pos.x = x;
        pos.y = y;
        dir = PVector.fromAngle(angle);
    }

    void draw() {
        if (depth == 0) {
            strokeWeight(1);
            translate(pos.x, pos.y);
            line(0,0,dir.x * 10, dir.y * 10);
            translate( -pos.x, -pos.y);
        }
    }

    void move(int x, int y)
    {
        pos.x = x;
        pos.y = y;
    }

    PVector test(Wall wall) {
        float x3 = pos.x;
        float y3 = pos.y;
        float x4 = pos.x + dir.x;
        float y4 = pos.y + dir.y;
        float x1 = wall.a.x;
        float y1 = wall.a.y;
        float x2 = wall.b.x;
        float y2 = wall.b.y;
        float denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
        if (denominator == 0) {
            return null;
        }
        float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator;
        float u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) / denominator;
        if (t > 0 && t < 1 && u > 0) {
            PVector point = new PVector();
            point.x = x1 + t * (x2 - x1);
            point.y = y1 + t * (y2 - y1);
            return point;
        }
        return null;
    }
}


class Emitter{

    int MAXDEPTH = 3;

    PVector pos = new PVector();
    Ray[][] rays;
    int density;

    boolean drawLines = false;
    Emitter(int x, int y, int density) {
        this.density = density;
        rays = new Ray[90 * density][MAXDEPTH];
        // rays = new Ray[1][MAXDEPTH];
        // rays = new Ray[8][MAXDEPTH];
        pos.x = x;
        pos.y = y;
        createRays();
    }

    void createRays() { // map(i,0,rays.length,0,360)
        float angle = -QUARTER_PI;
        for (int i = 0; i < rays.length; i++) {
            rays[i][0] = new Ray(pos.x,pos.y, angle,0);
            angle =  - QUARTER_PI + (HALF_PI * ((float)i / (float)rays.length));
        }
    }

    void move(int x, int y)
    {
        pos.x = x;
        pos.y = y;
        for (int i = 0; i < rays.length; i++) {
            rays[i][0].move(x, y);
        }
    }

    void draw()
    {
        for (int i = 0; i < rays.length; i++) {
            for (int depth = 0; depth < MAXDEPTH; depth++) {
                if (rays[i][depth] != null) {
                    rays[i][depth].draw();
                }
            }
        }
    }

    void test(Wall[] walls)
    {

        for (int i = 0; i < rays.length; i++) {
            for (int depth = 0; depth < MAXDEPTH; depth++) {
                if (rays[i][depth] != null) {
                    float closestDist = 20000000;
                    PVector closestHit = null;
                    int wallIndex = -1;
                    for (int j = 0; j < walls.length; j++) {
                        PVector hit = rays[i][depth].test(walls[j]);
                        if (hit!= null) {
                            float dist = pos.dist(hit);
                            if (dist < closestDist)
                            {
                                closestHit = hit;
                                closestDist = dist;
                                wallIndex = j;
                            }

                        }
                    }

                    if (closestHit != null)
                    {
                        float intensity = map(closestDist, 0, 1000, 255, 0);
                        if (depth == 0) {
                            stroke(intensity,0,0);
                            strokeWeight(1);
                        } else if (depth == 1) {
                            stroke(0,intensity,0);
                            strokeWeight(2);
                        } else if (depth == 2) {
                            stroke(0,0,intensity);
                            strokeWeight(3);
                        }
                        else if (depth == 3) {
                            stroke(0,intensity,intensity);
                            strokeWeight(4);
                        }
                        // stroke(intensity);
                        if (drawLines) {
                            line(rays[i][depth].pos.x, rays[i][depth].pos.y, closestHit.x, closestHit.y);
                        }
                        strokeWeight(map(closestDist, 0, width * 2, 5, 0));
                        point(closestHit.x, closestHit.y);
                        Wall w = walls[wallIndex];
                        float lineAngle = atan2(w.b.y - w.a.y, w.b.x - w.a.x);
                        float rayAngle = rays[i][depth].angle;
                        while(lineAngle < 0)
                        {
                            lineAngle += TWO_PI;
                        }
                        while(rayAngle > TWO_PI) {
                            rayAngle -= TWO_PI;
                        }
                        while(rayAngle < 0) {
                            rayAngle += TWO_PI;
                        }
                        if (depth < MAXDEPTH - 1) {
                            float newAngle = 2 * lineAngle - rays[i][depth].angle;
                            while(newAngle < 0) {
                                newAngle += TWO_PI;
                            }
                            if (round(sin(lineAngle + HALF_PI) * 1000.0) / 1000.0 != round(sin(newAngle) * 1000.0) / 1000.0) {
                                rays[i][depth + 1] = new Ray(closestHit.x - rays[i][depth].dir.x,closestHit.y - rays[i][depth].dir.y, newAngle, depth + 1);
                            }
                            else{
                                for (int t = depth + 1; t < MAXDEPTH; t++) {
                                    rays[i][t] = null;
                                }
                            }
                        }
                    }
                    else{
                        for (int t = depth + 1; t < MAXDEPTH; t++) {
                            rays[i][t] = null;
                        }
                    }
                }
            }
        }

    }

    void drawLines() {
        this.drawLines = !this.drawLines;
    }
}

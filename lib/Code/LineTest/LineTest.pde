int NumWalls = 0;

Wall[] walls = new Wall[NumWalls + 4];
Ray r;
Emitter e;

boolean drawWalls = false;
int delay = 0;

void setup() {
    size(1200,1200);
    for (int i = 0; i < NumWalls; i++) {
        walls[i] = new Wall((int)random(0, width),(int)random(0, height),(int)random(0, width),(int)random(0, width));
    }
    walls[NumWalls] = new Wall(0, 0, width, 0);
    walls[NumWalls + 1] = new Wall(0,0, 0, height);
    walls[NumWalls + 2] = new Wall(0, height, width, height);
    walls[NumWalls + 3] = new Wall(width, 0, width, height);
    e = new Emitter(100,700, 1);
}

void draw()
{
    background(0);
    if (keyPressed) {
        if (key == 'b' && delay == 0) {
            drawWalls = !drawWalls;
            delay = 60;
        }
        if (key == 'p') {
            exit();
        }
    }
    if (drawWalls) {
        for (int i = 0; i < NumWalls + 4; i++) {
            walls[i].draw();
        }
    }
    e.move(mouseX, mouseY);
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
        strokeWeight(10);
        line(a.x, a.y,b.x, b.y);
    }
}


class Ray{

    PVector pos = new PVector();
    PVector dir = new PVector();
    float angle;
    Ray nextBounce;
    int depth;
    int maxBrightness;

    Ray(int x, int y, float angle, int maxBrightness, int depth) {
        this.angle = angle;
        this.depth = depth;
        this.maxBrightness = maxBrightness;
        pos.x = x;
        pos.y = y;
        dir = PVector.fromAngle(angle);
    }

    void draw() {
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

    Emitter(int x, int y, int density) {
        this.density = density;
        // rays = new Ray[360 * density][MAXDEPTH];
        // rays = new Ray[1][MAXDEPTH];
        rays = new Ray[8][MAXDEPTH];
        pos.x = x;
        pos.y = y;
        createRays();
    }

    void createRays() {
        for (int i = 0; i < rays.length; i++) {
            rays[i][0] = new Ray((int)pos.x,(int)pos.y, radians(map(i,0,rays.length,0,360)),255,0);
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
            for (int depth = 0; depth < 3; depth++) {
                if (rays[i][depth] != null) {
                    rays[i][depth].draw();
                }
            }
        }
    }

    void test(Wall[] walls)
    {

        for (int i = 0; i < rays.length; i++) {
            for (int depth = 0; depth < 3; depth++) {
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
                        float intensity = 255;
                        strokeWeight(1);
                        if (depth == 0) {
                            stroke(intensity,0,0);
                        } else if (depth == 1) {
                            stroke(0,intensity,0);
                        } else if (depth == 2) {
                            stroke(0,0,intensity);
                        }

                        point(closestHit.x, closestHit.y);
                        line(rays[i][depth].pos.x, rays[i][depth].pos.y, closestHit.x, closestHit.y);
                        if (depth!= 2) {
                            Wall w = walls[wallIndex];
                            float lineAngle = atan2(w.b.y - w.a.y, w.b.x - w.a.x);
                            float newAngle = 2 * lineAngle - rays[i][depth].angle;
                            rays[i][depth + 1] = new Ray((int)closestHit.x,(int)closestHit.y, newAngle, 255, depth + 1);
                        }

                    }
                }
            }
        }

    }

}

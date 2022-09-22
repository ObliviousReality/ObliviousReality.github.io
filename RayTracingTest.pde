int NumWalls = 10;

Wall[] walls = new Wall[NumWalls];
Ray r;
Emitter e;

boolean drawWalls = false;
int delay = 0;

void setup() {
    size(800,800);
    for (int i = 0; i < NumWalls; i++) {
        walls[i] = new Wall((int)random(0, width),(int)random(0, height),(int)random(0, width),(int)random(0, width));
    }

    // r = new Ray(200,200, radians(90));
    e = new Emitter(100,700, 2);
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
        for (int i = 0; i < NumWalls; i++) {
            walls[i].draw();
        }
    }
    e.move(mouseX, mouseY);
    e.draw();
    e.test(walls);
    if(delay > 0){
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

    Ray(int x, int y, float angle) {
        pos.x = x;
        pos.y = y;
        dir = PVector.fromAngle(angle);
    }

    void draw() {

        stroke(255,0,0);
        push();
        translate(pos.x, pos.y);
        line(0,0,dir.x * 10, dir.y * 10);
        pop();
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

    PVector pos = new PVector();
    Ray[] rays;
    int density;
    Emitter(int x, int y, int density) {
        this.density = density;
        rays = new Ray[360 * density];
        println(rays.length);
        pos.x = x;
        pos.y = y;
        createRays();
    }

    void createRays() {
        for (int i = 0; i < rays.length; i++) {
            rays[i] = new Ray((int)pos.x,(int)pos.y, radians(map(i,0,rays.length,0,360)));
        }
    }

    void move(int x, int y)
    {
        pos.x = x;
        pos.y = y;
        for (int i = 0; i < rays.length; i++) {
            rays[i].move(x, y);
        }
    }

    void draw()
    {
        for (int i = 0; i < rays.length; i++) {
            rays[i].draw();
        }
    }

    void test(Wall[] walls)
    {

        for (int i = 0; i < rays.length; i++) {
            float closestDist = Integer.MAX_VALUE;
            PVector closestHit = null;
            for (int j = 0; j < walls.length; j++) {
                PVector hit = rays[i].test(walls[j]);
                if (hit!= null) {
                    float dist = pos.dist(hit);
                    if (dist < closestDist)
                    {
                        closestHit = hit;
                        closestDist = dist;
                    }

                }
            }

            if (closestHit != null)
            {
                // stroke(0,0,255);
                stroke(255,0,255);
                strokeWeight(1);
                point(closestHit.x, closestHit.y);
                // line(pos.x, pos.y, closestHit.x, closestHit.y);
            }
        }

    }
}

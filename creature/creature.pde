// http://www.openprocessing.org/visuals/?visualID=12684
// By Loren Schmidt


/*
This is a creature with legs. It is not physically simulated
at all. It simply stores an absolute position for each foot,
and as the creature's position shifts it checks to see if the
feet have fallen outside of an acceptable radius. When a foot
hits the edge of this circle, it takes a step forward.
*/
class Creature {
  float x;
  float y;
  float z;
  float currentX;
  float currentY;
  float currentZ;
  PVector wobbleVelocity = new PVector();
  private float heading = 0;
  PVector destination;
  private float velocityAdjust; // Walk slower while turning;
  private Leg leg[]; // Array of Leg objects
  int legsUp;
  private static final float VELOCITY = 0.8;
  private static final float TURN_RATE = 0.01;
   
   
  Creature(float x, float y) {
    this.x = x;
    this.y = y;
    z = 24;
    heading = -PI / 2 * int(random(3));
    this.x = 256 * cos(PI + heading);
    this.y = 256 * sin(PI + heading);
    this.currentX = this.x;
    this.currentY = this.y;
    destination = new PVector();
    leg = new Leg[6];
    float legLength = 32;
    float baseWidth = 8;
    leg[0] = new Leg(this, baseWidth, 8, 20, 40);
    leg[1] = new Leg(this, -baseWidth, 8, -20, 40);
    leg[2] = new Leg(this, baseWidth, 0, legLength, 0);
    leg[3] = new Leg(this, -baseWidth, 0, -legLength, 0);
    leg[4] = new Leg(this, baseWidth, -8, 20, -40);
    leg[5] = new Leg(this, -baseWidth, -8, -20, -40);
    /*
        leg = new Leg[8];
    float legLength = 32;
    float baseWidth = 8;
    leg[0] = new Leg(this, baseWidth, 8, 20, 40);
    leg[1] = new Leg(this, -baseWidth, 8, -20, 40);
    leg[2] = new Leg(this, baseWidth, 8 / 3, legLength, 20);
    leg[3] = new Leg(this, -baseWidth, 8 / 3, -legLength, 20);
    leg[4] = new Leg(this, baseWidth, -8 / 3, legLength, -20);
    leg[5] = new Leg(this, -baseWidth, -8 / 3, -legLength, -20);
    leg[6] = new Leg(this, baseWidth, -8, 20, -40);
    leg[7] = new Leg(this, -baseWidth, -8, -20, -40);
    */
  }
   
   
  void Update() {
    // Update heading
    float targetHeading = atan2(
      destination.y - y, destination.x - x);
    float dHeading = (targetHeading - heading + 8 * TWO_PI)
      % TWO_PI;
    if (dHeading > PI) {
      dHeading -= TWO_PI;
    }
    if (dHeading < -TURN_RATE) {
      heading -= TURN_RATE;
    }
    else if (dHeading > TURN_RATE) {
      heading += TURN_RATE;
    }
    velocityAdjust = max(0, -3.0 + 4.0 * (1 - abs(dHeading) / PI));
    //print("Velocity adjustment is " + velocityAdjust + "\n");
    heading = (heading + TWO_PI) % TWO_PI;
    float distance = sqrt(
      pow(destination.x - x, 2) +
      pow(destination.y - y, 2));
    if (distance < 16) {
      destination.x = 128 * (-1 + random(2));
      destination.y = 128 * (-1 + random(2));
    }
     
    // Walk forward
    float dX = cos(heading);
    float dY = sin(heading);
    x += dX * velocityAdjust * VELOCITY;
    y += dY * velocityAdjust * VELOCITY;
     
    // Check if legs are within radius
    float turnDirection = 0;
    if (abs(dHeading) > PI / 4) {
      turnDirection = dHeading / abs(dHeading);
    }
    //print("Turn direction is " + int(turnDirection) + "\n");
    for (int i = 0; i < leg.length; i ++) {
      leg[i].Update(int(turnDirection));
    }
     
    // Body wobble
    /*
    The center point (which the feet use to position themselves)
    moves quite regularly, but the body wobbles around as it
    tries to follow the center point
    */
    PVector acceleration = new PVector(
      x - currentX, y - currentY, z - currentZ);
    acceleration.normalize();
    acceleration.mult(0.03);
    wobbleVelocity.add(acceleration);
    wobbleVelocity.mult(0.99);
    currentX += wobbleVelocity.x;
    currentY += wobbleVelocity.y;
    currentZ += wobbleVelocity.z;
  }
   
   
  void Puppeteer(float turnAmount, float forward, float lateral) {
    // Walk forward
    float dX = forward * cos(heading) + lateral * sin(heading);
    float dY = forward * sin(heading) + lateral * cos(heading);;
    x += dX * VELOCITY;
    y += dY * VELOCITY;
    heading += turnAmount * TURN_RATE;
    print("Velocity = " + dX + ", " + dY + "\n");
    // Check if legs are within radius
    /*
    if (abs(dHeading) > PI / 4) {
      turnDirection = dHeading / abs(dHeading);
    }
    */
    //print("Turn direction is " + int(turnDirection) + "\n");
    if (forward > 0) {
      turnAmount = 0; // Don't use turn-appropriate goal points if we're walking while turning
    }
    for (int i = 0; i < leg.length; i ++) {
      leg[i].Update(int(turnAmount));
    }
     
    // Body wobble
    /*
    The center point (which the feet use to position themselves)
    moves quite regularly, but the body wobbles around as it
    tries to follow the center point
    */
    PVector acceleration = new PVector(
      x - currentX, y - currentY, z - currentZ);
    acceleration.normalize();
    acceleration.mult(0.03);
    wobbleVelocity.add(acceleration);
    wobbleVelocity.mult(0.99);
    currentX += wobbleVelocity.x;
    currentY += wobbleVelocity.y;
    currentZ += wobbleVelocity.z;
  }
   
   
  void Render() {
    //fill(255);
    pushMatrix();
    translate(currentX, currentY, currentZ + 4);
    rotateZ(heading);
    stroke(255);
    //strokeWeight(2);
    //box(18, 20, 9);
    box(16, 16, 8);
    /*
    translate(0, -4, 0);
    stroke(127, 0, 0);
    box(16, 8, 8);
    translate(0, 8, 0);
    stroke(0);
    box(16, 8, 8);
    */
    popMatrix();
     
    // Render legs
    for (int i = 0; i < leg.length; i ++) {
      leg[i].Render();
    }
     
    // Line to destination
    strokeWeight(1);
    stroke(255, 128);
    //line(destination.x, destination.y, 0.05, x, y, 0.05);
     
    // Target point
    float markSize = 8;
    pushMatrix();
    translate(destination.x, destination.y, 0.05);
     
    line(
      - markSize,
      - markSize,
      markSize,
      markSize);
    line(
      markSize,
      - markSize,
      - markSize,
      markSize);
     
    popMatrix();
  }
}

Creature creature;
boolean autonomous = false;
int autonomousTimer = 0;
boolean keyState[] = new boolean[200];
int foregroundColor = 255;
int backgroundColor = 0;
 
void setup() {
  size(512, 512, P3D);
  smooth();
  noFill();
  creature = new Creature(0, 0);
}
 
 
void draw() {
  background(0);
   
  // Keyboard controls
  float forward = 0;
  float lateral = 0;
  float dHeading = 0;
  boolean keyPressed = false;
  if (keyState[39]) {
    keyPressed = true;
    dHeading = 1;
  }
  if (keyState[38]) {
    keyPressed = true;
    forward = 1;
  }
  if (keyState[37]) {
    keyPressed = true;
    dHeading = -1;
  }
  if (keyState[40]) {
    keyPressed = true;
    forward = -1;
  }
  if (keyState[65]) {
    keyPressed = true;
    lateral = -1;
  }
  if (keyState[68]) {
    keyPressed = true;
    lateral = 1;
  }
  if (keyPressed) {
    autonomous = false;
    autonomousTimer = 240;
    print("Switching off autonomous control.\n");
  }
   
   
  if (!autonomous) {
    creature.Puppeteer(dHeading, forward, lateral);
    autonomousTimer --;
    if (autonomousTimer <= 0) {
      autonomous = true;
    }
  }
   
  if (autonomous) {
    creature.Update();
  }
   
  // Draw
  camera(0, 176, 272, 0, 32, 0, 0, 1, 0);
  DrawGrid();
  creature.Render();
   
  if (mousePressed) {
    creature.destination = new PVector(mouseX - width / 2, mouseY - width / 2);
  }
}
 
 
void keyPressed() {
  if (key == 'r') {
    setup();
  }
  keyState[keyCode] = true;
  print("Key code = " + keyCode + "\n");
}
 
 
void keyReleased() {
  keyState[keyCode] = false;
}
 
 
void DrawGrid() {
  float gridSize = 8;
  for (int x = -16; x < 17; x ++) {
    stroke(foregroundColor, 32);
    if (x % 4 == 0) {
      stroke(foregroundColor, 64);
    }
    line(x * gridSize, -16 * gridSize, x * gridSize, 16 * gridSize);
  }
   
  for (int y = -16; y < 17; y ++) {
    stroke(foregroundColor, 32);
    if (y % 4 == 0) {
      stroke(foregroundColor, 64);
    }
    line(-16 * gridSize, y * gridSize, 16 * gridSize, y * gridSize);
  }
}

class Leg {
  Creature parent;
  PVector foot;
  float footVelocity = 0;
  PVector footCenterRelative; // center of foot radius
  PVector footCenter; // center of foot radius (absolute)
  PVector root; // Point where we are attached to creature
  PVector rootRelative;
  PVector goalPoint;
  // Add in an attachment point, optionally
  boolean walking;
  int facing; // for step direction while turning- 1 for counterclockwise
  private static final float MAX_RADIUS = 20;
  float baseAngle;
   
 
  Leg(Creature parent, float startX, float startY,
  float dX, float dY) {
    this.parent = parent;
    foot = new PVector(parent.x + dX, parent.y + dY);
    footCenterRelative = new PVector(dX, dY);
    footCenter = new PVector();
    rootRelative = new PVector(startX, startY);
    goalPoint = new PVector(footCenter.x, footCenter.y);
    root = new PVector();
    facing = int(dX / abs(dX));
    baseAngle = atan2(dY - startY, dX - startX) - PI / 2;
    Update(0);
    // This sets the absolute foot position and root position
    // correctly
  }
 
 
  void Update(int turnDirection) {
    foot.z = min(5, foot.z + footVelocity);
    if (foot.z < 0) {
      foot.z = 0;
      footVelocity = 0;
    }
    // Update the attachment point to the body as we move
    root.x = parent.currentX + rootRelative.x * cos(parent.heading + PI / 2)
      + rootRelative.y * sin(parent.heading + PI / 2);
    root.y = parent.currentY + rootRelative.x * sin(parent.heading + PI / 2)
      - rootRelative.y * cos(parent.heading + PI / 2);
    root.z = parent.currentZ;
    // Update the absolute center of the foot's radius
    footCenter.x = parent.x + footCenterRelative.x * cos(parent.heading + PI / 2)
      + footCenterRelative.y * sin(parent.heading + PI / 2);
    footCenter.y = parent.y + footCenterRelative.x * sin(parent.heading + PI / 2)
      - footCenterRelative.y * cos(parent.heading + PI / 2);
 
    if (!walking) {
      //parent.wobbleVelocity.z += 0.001; // Lift body slightly
      // Check if we are outside our radius
      float distance = sqrt(
      pow(foot.x - footCenter.x, 2) +
        pow(foot.y - footCenter.y, 2));
      footVelocity -= 0.5;
      if (distance > MAX_RADIUS) {
      //&& (parent.legsUp < 3)) {
        walking = true;
        parent.legsUp ++;
        // Start walking motion- timers, etc.- here
      }
    }
    float stepOffset = MAX_RADIUS;
    float stepHeading = parent.heading;
    if (turnDirection != 0) {
      stepOffset *= turnDirection; // Flip ccw legs if ccw, vice versa
      stepHeading = parent.heading - baseAngle + PI / 2;
    }
    goalPoint.x = footCenter.x + stepOffset * cos(stepHeading);
    goalPoint.y = footCenter.y + stepOffset * sin(stepHeading);
    if (walking) {
      parent.wobbleVelocity.z -= 0.001; // Cause body to dip when up
      footVelocity = min(0.5, footVelocity + 0.1);
       
      // Move toward the front of the target circle
      PVector offset = new PVector(
        goalPoint.x - foot.x,
        goalPoint.y - foot.y);
      float distance = offset.mag();
      if (distance < 3) {
        foot.add(offset);
        walking = false;
        parent.legsUp --;
      }
      else {
        offset.normalize();
        offset.mult(3);
        foot.add(offset);
      }
    }
  }
 
 
  void Render() {
    // Leg
    //strokeWeight(2);
    stroke(255);
    PVector offset = new PVector(
    foot.x - root.x, foot.y - root.y, foot.z - root.z);
    // Knee height- simply offset middle upward now
    //float k = 96 * (1 - offset.mag() / 96);
    float k = 48 * sin(acos(offset.mag() / 96));
    line(root.x, root.y, root.z,
    root.x + offset.x / 2, root.y + offset.y / 2,
    root.z + offset.z / 2 + k);
    line(root.x + offset.x / 2, root.y + offset.y / 2,
    root.z + offset.z / 2 + k, foot.x, foot.y, foot.z);
     
    /*
    // Outer limit circle
    stroke(255, 32);
    float radius = MAX_RADIUS;
    float angle = 0;
    for (int i = 0; i < 15; i ++) {
      angle = i * TWO_PI / 15;
      line(
      footCenter.x + radius * cos(angle),
      footCenter.y + radius * sin(angle),
      footCenter.x + radius * cos(angle + TWO_PI / 15),
      footCenter.y + radius * sin(angle + TWO_PI / 15));
    }
    // Goal point
    angle = 0;
    radius = 3;
    for (int i = 0; i < 10; i ++) {
      angle = i * TWO_PI / 10;
      line(
      goalPoint.x + radius * cos(angle),
      goalPoint.y + radius * sin(angle),
      goalPoint.x + radius * cos(angle + TWO_PI / 10),
      goalPoint.y + radius * sin(angle + TWO_PI / 10));
    }
    */
  }
}


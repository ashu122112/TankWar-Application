class Barrier {
  float x, y, w, h;

  Barrier(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    fill(80);
    rect(x, y, w, h);
  }
}

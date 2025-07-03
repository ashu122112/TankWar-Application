class Timer {
  int startTime;
  int duration;
  Runnable callback; // Using Runnable for the callback function
  boolean done = false;

  Timer(int duration, Runnable callback) {
    this.startTime = millis();
    this.duration = duration;
    this.callback = callback;
  }

  void update() {
    if (!done && millis() - startTime > duration) {
      callback.run();
      done = true;
    }
  }

  boolean isDone() {
    return done;
  }
}

// Timer.pde - Class definition

class Timer {
  int startTime;    // The time (in milliseconds) when this timer was created or started
  int duration;     // The total duration (in milliseconds) for which this timer should run
  Runnable callback; // A functional interface (like a lambda in Java) to be executed when the timer finishes
  boolean done = false; // Flag to indicate if the timer has completed its duration and executed its callback

  // Constructor to create a new Timer
  // 'duration' is how long the timer should run (in milliseconds)
  // 'callback' is the function to execute when the timer is done
  Timer(int duration, Runnable callback) {
    this.startTime = millis(); // Record the current time when the timer is initialized
    this.duration = duration;
    this.callback = callback;
  }

  // Update method to be called repeatedly (e.g., in draw() loop)
  // It checks if the timer has elapsed and, if so, executes the callback
  void update() {
    // Only proceed if the timer is not already done
    if (!done) {
      // Check if the current time minus the start time exceeds the specified duration
      if (millis() - startTime > duration) {
        callback.run(); // Execute the callback function
        done = true;    // Mark the timer as done to prevent re-execution
      }
    }
  }

  // Helper method to check if the timer has completed
  boolean isDone() {
    return done;
  }
}

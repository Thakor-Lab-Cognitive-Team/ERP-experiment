#define NUM_PARAMETERS 4
#define BUFFER_SIZE 17

int stimulatorPin = 12; //pin used to stimulate the subject
int triggerPin = 5;

float start = 0;
float duration;
float frequency;
float pulse_width;
int pw_floor;
int pw_ceil;
int pw_digit;
int rev_pw_digit = 0;
int period_floor;
int period_ceil;
int period_digit;
float period;
float needTrigger = 0;
byte serialBuffer[BUFFER_SIZE];
float t0;

void setup() {
  Serial.begin(9600);
  pinMode(stimulatorPin, OUTPUT);
  pinMode(triggerPin, OUTPUT);
}

void loop() {
  // check if there is input from matlab
  if (Serial.available()) {
    Serial.readBytes(serialBuffer, BUFFER_SIZE);

    memcpy(&start, &serialBuffer[0], 4);              // stimulation flag
    memcpy(&duration, &serialBuffer[4], 4);           // duration of stimulation in sec
    memcpy(&frequency, &serialBuffer[8], 4);          // frequency of the pulse in Hz
    memcpy(&pulse_width, &serialBuffer[12], 4);       // pulse width of stimulation in ms
    period = 1000.0 / frequency;                        // period of the pulse in ms
    duration = duration * 1000;                       // duration of stimulation in ms
    pw_floor = floor(pulse_width);
    pw_ceil = ceil(pulse_width);
    pw_digit = (pulse_width - pw_floor) * 1000;
    if (pw_digit != 0) {
      rev_pw_digit = 1000 - pw_digit;
    }
    period_floor = floor(period);
    period_digit = (period - period_floor) * 1000;
    if (start == 1.0f) {
      t0 = millis();
    }
    needTrigger = 1;
  }

  // make sure trigger pin is LOW
  digitalWrite(triggerPin, LOW);

  // check if we are stimulating
  if (start == 1.0f) {
    if (millis() - t0 > duration) {
      start = 0;
      digitalWrite(stimulatorPin, LOW);
    }
    else {
      digitalWrite(stimulatorPin, HIGH);
      delay(pw_floor);
      delayMicroseconds(pw_digit);
      // busyDelayMicroseconds(pulse_width * 1000);
      digitalWrite(stimulatorPin, LOW);
      delayMicroseconds(rev_pw_digit);
      delay(period_floor - pw_ceil);
      delayMicroseconds(period_digit);
      // busyDelayMicroseconds((period - pulse_width) * 1000);
    }
  }
  else {
    digitalWrite(stimulatorPin, LOW);
  }

  if (needTrigger == 1.0f) {
    digitalWrite(triggerPin, HIGH);
    needTrigger = 0;
  }
}

void busyDelayMicroseconds( unsigned int wait ) {
    unsigned long t0 = micros();
    while ( micros() - t0 < wait ) {}
}

#define BUFFER_SIZE 16

int stimulatorPin = 12; //pin used to stimulate the subject
int triggerPins[3] = {8, 9, 10};

float start = 0;
float duration;
float frequency;
float pulse_width;
float trigger_mode;
int pw_floor;
int pw_ceil;
int pw_digit;
int rev_pw_digit = 0;
int period_floor;
int period_ceil;
int period_digit;
float period;
bool needTrigger = false;
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
    memcpy(&trigger_mode, &serialBuffer[16], 4);      // trigger mode
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
    needTrigger = true;
  }

  // make sure trigger pin is LOW
  for (int i = 0; i < 3; i++) {
    digitalWrite(triggerPins[i], LOW);
  }

  if (needTrigger == true) {
    switch(int(trigger_mode)) {
      case 1:
        digitalWrite(triggerPins[0], HIGH);
        delayMicroseconds(10);
        digitalWrite(triggerPins[0], LOW
        needTrigger = false;
        break;
      case 2:
        digitalWrite(triggerPins[1], HIGH);
        delayMicroseconds(10);
        digitalWrite(triggerPins[1], LOW
        needTrigger = false;
        break;
      case 3:
        digitalWrite(triggerPins[2], HIGH);
        delayMicroseconds(10);
        digitalWrite(triggerPins[2], LOW
        needTrigger = false;
        break;
      case 4:
        digitalWrite(triggerPins[0], HIGH);
        digitalWrite(triggerPins[1], HIGH);
        delayMicroseconds(10);
        digitalWrite(triggerPins[0], LOW
        digitalWrite(triggerPins[1], LOW
        needTrigger = false;
        break;
      case 5:
        digitalWrite(triggerPins[0], HIGH);
        digitalWrite(triggerPins[2], HIGH);
        delayMicroseconds(10);
        digitalWrite(triggerPins[0], LOW
        digitalWrite(triggerPins[2], LOW
        needTrigger = false;
        break;
      case 6:
        digitalWrite(triggerPins[1], HIGH);
        digitalWrite(triggerPins[2], HIGH);
        delayMicroseconds(10);
        digitalWrite(triggerPins[1], LOW
        digitalWrite(triggerPins[2], LOW
        needTrigger = false;
        break;
    }
  }

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
    }
  }
  else {
    digitalWrite(stimulatorPin, LOW);
  }

}

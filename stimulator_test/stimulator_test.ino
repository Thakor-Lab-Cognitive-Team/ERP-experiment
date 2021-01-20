int stimulatorPin = 12; //pin used to stimulate the subject

int start = 0;
int duration = 2000;
int frequency = 20;
float pulse_width = 1.5;
int pw_floor;
int pw_ceil;
int pw_digit;
int rev_pw_digit = 0;
int period_floor;
int period_ceil;
int period_digit;
float period;
byte serialBuffer[2];
float t0;

void setup() {
  Serial.begin(9600);
  pinMode(stimulatorPin, OUTPUT);
}

void loop() {
  if (Serial.available()) {
    Serial.readBytes(serialBuffer, 2);
    memcpy(&start, &serialBuffer[0], 1);
    Serial.println(start);
    start = start - 48;
    Serial.println(start);
    period = 1000 / float(frequency);                        // period of the pulse in ms
    pw_floor = floor(pulse_width);
    Serial.print("pw_floor: ");
    Serial.println(pw_floor);
    pw_ceil = ceil(pulse_width);
    Serial.print("pw_ceil: ");
    Serial.println(pw_ceil);
    pw_digit = (pulse_width - pw_floor) * 1000;
    Serial.print("pw_digit: ");
    Serial.println(pw_digit);
    if (pw_digit != 0) {
      rev_pw_digit = 1000 - pw_digit;
    }
    Serial.print("period: ");
    Serial.println(period);
    period_floor = floor(period);
    Serial.print("period_floor: ");
    Serial.println(period_floor);
    period_ceil = ceil(period);
    period_digit = (period - period_floor) * 1000;
    Serial.print("period_digit: ");
    Serial.println(period_digit);
    if (start == 1) {
      t0 = millis();
    }
    Serial.println(t0);
    Serial.println(duration);
  }

  if (start == 1) {
    Serial.println("start");
    Serial.println(millis() - t0);
    if (millis() - t0 > duration) {
      start = 0;
      digitalWrite(stimulatorPin, LOW);
      Serial.println("end");
    }
    else {
      Serial.println("stimulating");
      digitalWrite(stimulatorPin, HIGH);
      // Serial.println("stimulating high");
      //delay(pw_floor);
      // Serial.println("delay integer");
      //delayMicroseconds(pw_digit);
      // Serial.println("delay digit");
      busyDelayMicroseconds(pulse_width * 1000);
      digitalWrite(stimulatorPin, LOW);
      // Serial.println("stimulating low");
      // delayMicroseconds(rev_pw_digit);
      // Serial.println("delay first half digit");
      // delay(period_floor - pw_ceil);
      // Serial.println("delay integer");
      // delayMicroseconds(period_digit);
      // Serial.println("delay second half digit");
      busyDelayMicroseconds((period - pulse_width) * 1000 - 200);
    }
  }
  else {
    digitalWrite(stimulatorPin, LOW);
  }
}

void busyDelayMicroseconds( unsigned int wait ) {
    unsigned long t0 = micros();
    while ( micros() - t0 < wait ) {}
}

#include "VernierLib.h"
#define NUM_PARAMETERS 3
#define BUFFER_SIZE 6

int start = 0;
int duration;
int sampling_rate;
float period;
VernierLib Vernier;
float sensorReading;
byte serialBuffer[BUFFER_SIZE];
float t0;

void setup() {
  Serial.begin(9600);
  Vernier.autoID();
}

void loop() {
  if (Serial.available()) {
    Serial.readBytes(serialBuffer, BUFFER_SIZE);
    
    memcpy(&start, &serialBuffer[0], 2);
    memcpy(&duration, &serialBuffer[2], 2);
    memcpy(&sampling_rate, &serialBuffer[4], 2);
    period = 1000.0 / float(sampling_rate);
    
    if (start == 1) {
      t0 = millis();
    }
  }
  
  if (start == 1) {
    if (millis() - t0 > duration) {
      start = 0;
    }
    else {
      sensorReading = Vernier.readSensor();
      Serial.print(sensorReading);
      Serial.write(10);
      delay(period);
    }
  }
}

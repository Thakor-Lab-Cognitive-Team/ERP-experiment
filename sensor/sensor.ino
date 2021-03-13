#include "VernierLib.h"
#define BUFFER_SIZE 7

int triggerPin = 13;

int start = 0;
int duration;
int sampling_rate;
float period;
VernierLib Vernier;
float sensorReading;
bool needTrigger = false;
byte serialBuffer[BUFFER_SIZE];
float t0;

void setup() {
  Serial.begin(9600);
  Vernier.autoID();
  pinMode(triggerPin, OUTPUT);
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
    needTrigger = true;
  }

  // make sure trigger pin is LOW
  digitalWrite(triggerPin, LOW);
  
  if (start == 1) {
    if (millis() - t0 > duration) {
      start = 0;
      needTrigger = false;
    }
    else {
      sensorReading = Vernier.readSensor();
      if (needTrigger == true && sensorReading > 5){
        digitalWrite(triggerPin, HIGH);
        delay(10);
        digitalWrite(triggerPin, LOW);
        needTrigger = false;
      }
      Serial.print(sensorReading);
      Serial.write(10);
      delay(period);
    }
  }
}

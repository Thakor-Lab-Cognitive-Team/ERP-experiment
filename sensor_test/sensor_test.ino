#include "VernierLib.h"
#define NUM_PARAMETERS 3
#define BUFFER_SIZE 7

int triggerPin = 13;

int start = 0;
int duration = 1000;
int sampling_rate = 10;
float period;
VernierLib Vernier;
float sensorReading;
bool needTrigger = false;
byte serialBuffer[2];
float t0;

void setup() {
  Serial.begin(9600);
  Vernier.autoID();
  pinMode(triggerPin, OUTPUT);
}

void loop() {
  if (Serial.available()) {
    Serial.readBytes(serialBuffer, 2);
    
    memcpy(&start, &serialBuffer[0], 1);
    start = start - 48;
    period = 1000.0 / float(sampling_rate);
    
    if (start == 1) {
      t0 = millis();
    }
    needTrigger = true;
    Serial.println("start");
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
      if (needTrigger == true && sensorReading > 20){
        Serial.println("threshold hit");
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

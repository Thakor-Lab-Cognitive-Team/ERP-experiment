#include “VernierLib.h”
VernierLib Vernier;

int interval; //defines the interval of each read from the sensor in minutes
float threshold; //equates to the ideal threshold value
float sensorReading;
unsigned long minutes = 1000;

void setup() {
  Serial.begin(9600);
  Vernier.autoID();
}

void loop() {
  sensorReading=Vernier.readSensor();
  Serial.print(threshold);
  Serial.print("\t");
  Serial.print(sensorReading);
  delay(interval*minutes);
}
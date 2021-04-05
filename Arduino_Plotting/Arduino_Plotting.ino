#include "VernierLib.h"
VernierLib Vernier;

int interval = 100; //defines the interval of each read from the sensor in ms
float threshold = 5; //equates to the ideal threshold value
float sensorReading;

void setup() {
  Serial.begin(9600);
  Vernier.autoID();
}

void loop() {
  sensorReading=Vernier.readSensor();
  Serial.print("Threshold:");
  Serial.print(threshold);
  Serial.print(",");
  Serial.print("Read_out:");
  Serial.println(sensorReading);
  delay(interval);
}

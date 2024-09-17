#include "EmonLib.h"  // Include EmonLib for voltage monitoring
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "KFL01";
const char* password = "Ide@#kfl01";
const char* mqtt_server = "172.16.74.162";
WiFiClient espClient;
PubSubClient client(espClient);
EnergyMonitor emon;

#define VOLTAGE_CALIBRATION 127
#define RESISTOR_VALUE 100  // 100-ohm resistor

void setup_wifi() {
  delay(10);
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void setup() {
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  emon.voltage(34, VOLTAGE_CALIBRATION, 1.7);  // Calibrate the voltage sensor

  while (!client.connected()) {
    if (client.connect("ESP32Client1")) {
      Serial.println("Connected to MQTT");
    } else {
      delay(2000);
    }
  }
}

void loop() {
  emon.calcVI(20, 2000);  // Calculate voltage and current
  float Vrms = (emon.Vrms);

  // Limit the voltage value to be greater than 0 and less than or equal to 13.5
  Vrms = constrain(Vrms, 12.5, 13.5);

  // Calculate leakage reactance and earth resistance
  float leakageReactance = Vrms / RESISTOR_VALUE;  // Ohm's Law: I = V / R
  float earthResistance = Vrms / RESISTOR_VALUE * 10;  // Example calculation
  float vrms1=Vrms*17.6;
  // Publish voltage, leakage reactance, and earth resistance data
  String voltageStr = String(constrain(vrms1, 230, 250), 2);
  String reactanceStr = String(leakageReactance, 2);
  String resistanceStr = String(earthResistance, 2);
  
  client.publish("earthingSystem/voltage", voltageStr.c_str());
  client.publish("earthingSystem/reactance", reactanceStr.c_str());
  client.publish("earthingSystem/resistance", resistanceStr.c_str());

  delay(1000);
}


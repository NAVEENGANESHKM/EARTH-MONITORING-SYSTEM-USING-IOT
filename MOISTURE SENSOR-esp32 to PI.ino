#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "KFL01";
const char* password = "Ide@#kfl01";
const char* mqtt_server = "172.16.74.162";
WiFiClient espClient;
PubSubClient client(espClient);

#define MOISTURE_SENSOR_PIN 32  // Define the analog pin connected to the moisture sensor

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

  while (!client.connected()) {
    if (client.connect("ESP32ClientMoisture")) {
      Serial.println("Connected to MQTT");
    } else {
      delay(2000);
    }
  }
}

void loop() {
  int sensorValue = analogRead(MOISTURE_SENSOR_PIN);  // Read the moisture sensor value (0-4095)
  float voltage = sensorValue * (3.3 / 4095.0);  // Convert the sensor value to voltage (0-3.3V)

  // Optionally, map the sensor value to a percentage for easier interpretation
  int moisturePercentage = map(sensorValue, 4095, 0, 100, 0);

  // Print the moisture percentage and voltage to the serial monitor
  Serial.print("Moisture Level: ");
  Serial.print(moisturePercentage);
  Serial.print("%, Voltage: ");
  Serial.print(voltage);
  Serial.println("V");

  // Publish the moisture percentage and voltage data
  String moistureStr = String(moisturePercentage);
  String voltageStr = String(voltage, 2);
  
  client.publish("moistureSensor/percentage", moistureStr.c_str());
  

  delay(2000);
}

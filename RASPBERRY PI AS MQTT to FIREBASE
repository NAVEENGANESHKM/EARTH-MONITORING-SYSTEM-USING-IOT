import paho.mqtt.client as mqtt
import firebase_admin
from firebase_admin import credentials, db

# Firebase setup
cred = credentials.Certificate("path_to_firebase_admin_sdk.json")
firebase_admin.initialize_app(cred, {'databaseURL': 'your_firebase_database_url'})

# MQTT setup
def on_connect(client, userdata, flags, rc):
    client.subscribe("earth_system/#")

def on_message(client, userdata, msg):
    topic = msg.topic
    payload = float(msg.payload.decode())

    if topic == "earth_system/leakage":
        db.reference("leakage_current").set(payload)
    elif topic == "earth_system/resistance":
        db.reference("earth_resistance").set(payload)

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("localhost", 1883, 60)
client.loop_forever()

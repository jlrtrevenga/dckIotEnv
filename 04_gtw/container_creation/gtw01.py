#python3 read_parms.py -f init.json

from operator import truediv
#import paho.mqtt.client as mqtt
#import psycopg2
#import datetime
import time
import argparse
import json
import gateway_mqtt


#Procesar argumentos de entrada
parser = argparse.ArgumentParser()
parser.add_argument("-f", "--file", required=True, help="init parameters file, key-value")
args = parser.parse_args()
#print("file: " + args.file)

#Initialize parameters from .ini file
f1 = open(args.file)
jsIni = json.load(f1)

gtwMqtt01 = gateway_mqtt.gtw(jsIni)

time.sleep(5)


#gtwMqtt01.write_parameters()
gtwMqtt01.start()






from operator import truediv
import paho.mqtt.client as mqtt
import psycopg2
import datetime
import time


#topics
device1 = "/home5001/#"
device2 = "/home5002/#"

#topic01 = "/home5001/room1/temp/value"
#topic02 = "/home5001/temp/spvalue"
#topic03 = "/home5001/heater/command"
#topic04 = "/home5001/heater/status"


class gtw:
    """ Gateway: Lee de broker MQTT y escribe en BBDD """

    CONNECTION_RETRY_LIMIT = 30
    CONNECTION_RETRY_TIMEOUT_SECONDS = 10
  
    LOG_NO = 0
    LOG_ERROR = 1
    LOG_INFO = 2 
 

    #topics
    device = "/home5001/#"
    
    #gateway parameters
    gateway = {
        'log':0
        }
   
    #mqtt broker parameters
    mqtt_broker = {
        'address':'mqtt.eclipseprojects.io',
        'port':1883
        }

    #mqtt connection data
    mqtt_connection = {
        'ID':'Cliente1',
        'data':'test01',
        'timeout':60
        }

    #mqtt user
    mqtt_user = {
        'name':'test03',
        'pwd':'test03'
        }

    #postgres db parameters
    db = {
        'host':'dbsrv01',
        'port':5432,
        'name':'test01'
        }

    db_user = {
        'name':'usertest01',
        'pwd': 'test01'
        }


    def __init__(self, js):
        """ js: json con los parametros de acceso a MQTT y BB.DD. pgsql """

        if "gateway" in js:
            if 'log' in js['gateway']:
                self.gateway['log'] = js['gateway']['log']
            else: 
                self.gateway['log'] = 0

        if "mqtt_broker" in js:
            if 'address' in js['mqtt_broker']:
                self.mqtt_broker['address'] = js['mqtt_broker']['address']
            else:
                raise ValueError("mqtt_broker.address not set")

            if 'port' in js['mqtt_broker']:
                self.mqtt_broker['port'] = js['mqtt_broker']['port']
            else:
                self.mqtt_broker['port'] = 1883
        else:
                raise ValueError("mqtt_broker not set")

        if "mqtt_connection" in js:
            if 'ID' in js['mqtt_connection']:
                self.mqtt_connection['ID'] = js['mqtt_connection']['ID']
            else:
                self.mqtt_connection['ID'] = ""

            if 'data' in js['mqtt_connection']:
                self.mqtt_connection['data'] = js['mqtt_connection']['data']
            else:
                self.mqtt_connection['data'] = ""

            if 'timeout' in js['mqtt_connection']:
                self.mqtt_connection['timeout'] = js['mqtt_connection']['timeout']
            else:
                self.mqtt_connection['timeout'] = 60

        if "mqtt_user" in js:
            if 'name' in js['mqtt_user']:
                self.mqtt_user['name'] = js['mqtt_user']['name']
            else:
                raise ValueError("mqtt_user not set")

            if 'pwd' in js['mqtt_user']:
                self.mqtt_user['pwd'] = js['mqtt_user']['pwd']
            else:
                raise ValueError("mqtt_pwd not set")
        else:
                raise ValueError("mqtt_user not set")

        if "db" in js:
            if 'host' in js['db']:
                self.db['host'] = js['db']['host']
            else:
                raise ValueError("db.host not set")

            if 'port' in js['db']:
                self.db['port'] = js['db']['port']
            else:
                raise ValueError("db.port not set")

            if 'name' in js['db']:
                self.db['name'] = js['db']['name']
            else:
                raise ValueError("db.name not set")

        else:
                raise ValueError("db not set")

        if "db_user" in js:
            if 'name' in js['db_user']:
                self.db_user['name'] = js['db_user']['name']
            else:
                raise ValueError("db_user.name not set")

            if 'pwd' in js['db_user']:
                self.db_user['pwd'] = js['db_user']['pwd']
            else:
                raise ValueError("db_user.pwd not set")
        else:
                raise ValueError("db_user not set")

        #MQTT Client initialization
        self.client = mqtt.Client(client_id= "", clean_session = True, userdata = None) 


    def log(self, log_message, log_level):       
        #LOG_ERROR(1)        
        if self.gateway['log'] == self.LOG_ERROR:
            if log_level == self.LOG_ERROR:            
                now = time.strftime("%Y.%m.%d %H:%M:%S", time.localtime())
                print( now + " ****** ERROR ****** : " + log_message)
        elif self.gateway['log'] == self.LOG_INFO:
            if log_level == self.LOG_ERROR:
                now = time.strftime("%Y.%m.%d %H:%M:%S", time.localtime())
                print( now + " ****** ERROR ****** : " + log_message)
            elif log_level == self.LOG_INFO:
                now = time.strftime("%Y.%m.%d %H:%M:%S", time.localtime())
                print( now + " INFO: " + log_message)


    def write_parameters(self):
        print("gateway.log: " + str(self.gateway['log']))
        print("mqtt_broker.address: " + str(self.mqtt_broker['address']))
        print("mqtt_broker.port: " + str(self.mqtt_broker['port']))
        print("mqtt_connection.ID: " + str(self.mqtt_connection['ID']))
        print("mqtt_connection.data: " + str(self.mqtt_connection['data']))
        print("mqtt_connection.timeout: " + str(self.mqtt_connection['timeout']))
        print("mqtt_user.name: " + str(self.mqtt_user['name']))
        print("mqtt_user.pwd: " + str(self.mqtt_user['pwd']))
        print("db.host: " + str(self.db['host']))
        print("db.port: " + str(self.db['port']))
        print("db.name: " + str(self.db['name']))
        print("db_user.name: " + str(self.db_user['name']))
        print("db_user.pwd" + str(self.db_user['pwd']))


    def record_measure(self, topic, value):
        dt1 = datetime.datetime.now(tz=None)
        SQL= "INSERT INTO MEASURES (device, value, timestamp_local) VALUES (%s, %s, %s);"
        data = (topic, value, dt1)

        try:
            dbconnection = psycopg2.connect(dbname = self.db['name'], host = self.db['host'], port = self.db['port'],
                                    user = self.db_user['name'], password = self.db_user['pwd']) 
            dbcursor = dbconnection.cursor()
            dbcursor.execute(SQL, data)
            dbconnection.commit()         
            dbcursor.close
            dbconnection.close

        except(Exception, Error) as error:
            if (dbconection):
                dbcursor.close()
                dbconnection.close()
            self.log("PostgreSQL DB, Connection error: " + error, self.LOG_ERROR)  
            raise NameError('PostgreSQL DB Connection error')          


    # TODO: Usar la BBDD para pasar todos los datos:
    #       Broker y puerto con el que conectar
    #       Topics a los que suscribirse
    def on_connect(self, client, userdata, flags, rc):
        if (rc == 0):
            Status_connected = True
            client.subscribe(device1,1)
            self.log("device subscription: " + device1, self.LOG_INFO)
            client.subscribe(device2,1)
            self.log("device subscription: " + device1, self.LOG_INFO)
            self.log("MQTT: Connected. ", self.LOG_INFO)
        else:
            self.log("MQTT: Connection error, result code: " + str(rc), self.LOG_ERROR)


    def on_message(self, client, userdata, message):
        self.log(message.topic + " -> " + str(message.payload.decode("utf-8")), self.LOG_INFO)
        try:
            self.record_measure(message.topic, message.payload.decode("utf-8"))
        except:
            self.log(message.topic + " -> " + str(message.payload.decode("utf-8")), self.LOG_ERROR)



    def subscribe(self, device):
        self.client.subscribe(device,1)
        self.log("device subscription: " + device, self.LOG_INFO)







    def start(self):
        #Cliente de MQTT. 
        # Elimino la inicializacion, la muevo a __init__
        #client = mqtt.Client(client_id= "", clean_session = True, userdata = None) 
        self.client.username_pw_set(username = self.mqtt_user['name'], password = self.mqtt_user['pwd'])
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        conn_Retry_Count = 0 
        Status_Connected = False

        self.client.connect(self.mqtt_broker['address'], self.mqtt_broker['port'], self.mqtt_connection['timeout'])
        self.client.loop_forever()
        self.log("Loop forever started", self.LOG_INFO)



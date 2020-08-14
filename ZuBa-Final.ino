/********ZUBA SOLUTIONS*********/
/**This code controls ZUBA bins**/
#include <Servo.h> 
#include <Q2HX711.h>
#include <ModuleSerialCore.h>
#include <ModuleSerialGprs.h>
#include <ModuleSerialGps.h>


#define PIN_NUMBER ""
#define APN "wap"
#define APN_USERNAME ""
#define APN_PASSWORD ""
#define LOCAL_PHONE ""
#define REMOTE_PHONE ""

ModuleSerialCore core(&Serial1);    // Begin a SoftwareSerial connection on rx and tx pins.
ModuleSerialGprs gprs(&core);   // Pass a reference to the core.
ModuleSerialGps gps(&core);

// Declare the Servo pin 
int servoPin =  7; 
// Create a servo object 
Servo Servo1;

//pins for loadcell
const byte hx711_data_pin = 3;
const byte hx711_clock_pin = 4;
float y1 = 173.0; // calibrated mass to be added
long x1 = 8679898L;
long x0 = 8607003L;
float avg_size = 10.0; // amount of averages for each mass measurement
double weight;

Q2HX711 hx711(hx711_data_pin, hx711_clock_pin); // prep hx711

//Pins for buzzer and smokeDetector
int buzzer = 2;
int smokeA1 = A1;
// Your threshold value
int sensorThres = 400;
bool smokeDetected;

/**********************ultrasonic init********************/

// defines pins numbers for ultrasonic(for opening lid) 
const int lidOpenTrigPin = 8;
const int lidOpenEchoPin = 9;
//define pins nubers for ultrasonic(for checking height)
const int wasteHeightTrigPin = 10;
const int wasteHeightEchoPin = 11;

const int led = 13; // variable which stores pin number

// defines variables
long duration;
int distance;
long durationWasteUtrasonic;
int heightOfWaste;

//convert float to string
String ftos(float num){
  char charVal[10];               //temporarily holds data from vals 
  String stringVal = "";     //data on buff is copied to this string
  dtostrf(num, 4, 4, charVal);  //4 is mininum width, 4 is precision; float value is copied onto buff
  //convert chararray to string
  for(int i=0;i<sizeof(charVal);i++)
  {
    stringVal+=charVal[i];
  }
  return stringVal;
}
  double pweight;
  
  double measureWeight(){
      // averaging reading
      long reading = 0;
      for (int jj=0;jj<int(avg_size);jj++){
        reading+=hx711.read();
      }
      reading/=long(avg_size);
      // calculating mass based on calibration and linear fit
      float ratio_1 = (float) (reading-x0);
      float ratio_2 = (float) (x1-x0);
      float ratio = ratio_1/ratio_2;
      float mass = y1*ratio;
      Serial.println("Raw: ");
      Serial.print(reading);
      Serial.print(", ");
      Serial.print(mass);

      return (mass - 1080.0);
    }
    int proximity(){
        // Clears the lidOpenTrigPin
    digitalWrite(lidOpenTrigPin, LOW);
    delayMicroseconds(2);
    
    // Sets the lidOpenTrigPin on HIGH state for 10 micro seconds
    digitalWrite(lidOpenTrigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(lidOpenTrigPin, LOW);
    
    // Reads the lidOpenEchoPin, returns the sound wave travel time in microseconds
    duration = pulseIn(lidOpenEchoPin, HIGH);
    
    // Calculating the distance
    distance= duration*0.034/2;
    Serial.print("Distance: ");
    Serial.println(distance);

    return distance;
      }

      int binHeight(){
        // Clears the wasteHeightTrigPin  
          digitalWrite(wasteHeightTrigPin , LOW);
          delayMicroseconds(2);
          
          // Sets the wasteHeightTrigPin on HIGH state for 10 micro seconds
          digitalWrite(wasteHeightTrigPin, HIGH);
          delayMicroseconds(10);
          digitalWrite(wasteHeightTrigPin, LOW);
          
          // Reads the wasteHeightEchoPin, returns the sound wave travel time in microseconds
          durationWasteUtrasonic = pulseIn(wasteHeightEchoPin, HIGH);
          
          // Calculating the height of the bin.
          heightOfWaste= durationWasteUtrasonic*0.034/2;
          Serial.print("Height of waste is: ");
          Serial.println(heightOfWaste);
        return heightOfWaste;
        }
void setup() {    
   Serial.begin(9600); // Starts the serial communication 
   // We need to attach the servo to the used pin number 
   Servo1.attach(servoPin);
   pinMode(lidOpenTrigPin, OUTPUT); // Sets the lidOpenTrigPin as an Output
   pinMode(lidOpenEchoPin, INPUT); // Sets the lidOpenEchoPin as an Input
   pinMode(wasteHeightTrigPin, OUTPUT); // Sets the wasteHeightTrigPin as an Output
   pinMode(wasteHeightEchoPin, INPUT); // Sets the wasteHeightEchoPin as an Input
   pinMode(led, OUTPUT);  //configures pin 7 as OUTPUT
   


  //Initiate Buzzer and Smoke detector
  pinMode(buzzer, OUTPUT);
  pinMode(smokeA1, INPUT);

   // Make servo go to 0 degrees 
   Servo1.write(0); 

   //store value for previous mass;
   pweight = measureWeight();

   while (!Serial);

    Serial.println(F("Initializing..."));

    bool notConnected = true;

    while (notConnected)
    {
        core.debug(&Serial);    // Pass a reference to HardwareSerial if you want debugging printed to the Serial Monitor.

        if (core.begin(9600) == MODULE_READY &&
            gprs.enable(APN, APN_USERNAME, APN_PASSWORD) == GPRS_ENABLED &&
            gps.enable() == GPS_ENABLED)
        {
            notConnected = false;
        }
        else 
        {
            Serial.println(F("Failed to connect."));
            delay(1000);
        }
    }

//      delay(1000);
//   
//   Serial.begin(9600); // Starts the serial communication 
}

  String request(const char* url, bool *success){
    gprs.openHttpConnection(); 
    
    ModuleSerialGprs::HttpResponse httpResponse = 
        gprs.sendHttpRequest(HTTP_GET, url, 6000);    // Method, url and timeout in milliseconds.

    
    if (httpResponse.statusCode == 200)
    {
        Serial.println(F("Request success!"));

        char response[500] = "";
        int length = httpResponse.contentLength + 50 > 500 ? 
            450 : httpResponse.contentLength;   // Read the first 450 characters of the response.

        gprs.readHttpResponse(length, response, 500);
  
        Serial.println(response);
        String ret = response;
        *success = false;
        gprs.closeHttpConnection();
        return ret;
    }
    else
    {
        Serial.println(F("Request failed."));
        *success = true;
        gprs.closeHttpConnection();
        return "";
    }

    
}
bool post = true;
void loop(){ 
    int sensor_value = analogRead(A0);
   Serial.println(sensor_value);
  if (sensor_value > 600)// the point at which the state of LEDs change 
    { 
      digitalWrite(led, HIGH);  //sets LEDs ON
    }
  else
    {
      digitalWrite(led,LOW);  //Sets LEDs OFF
    }

          //smoke and buzzer
      int analogSensor = analogRead(smokeA1);
      smokeDetected = false;

      Serial.println("Pin A0: ");
      Serial.print(analogSensor);
      // Checks if it has reached the threshold value
      if (analogSensor > sensorThres)
      {
        smokeDetected = true;
        tone(buzzer, 1000, 12000);
      }
      else
      {
        noTone(buzzer);
      }
      delay(100);

        proximity();
    if (proximity() < 15){
         if(binHeight()<19){
         tone(buzzer, 2000, 6000);          
          }
          else{
               while(proximity()<15){
               // Make servo go to 180 degrees 
               Servo1.write(180); 
               Serial.println("OPENED");
               tone(buzzer, 1500, 6000); 
               delay(6000);
                }
               // Make servo go to 0 degrees 
               Servo1.write(0);
               delay(1000); 
               Serial.println("CLOSED-FP");
          }
      }
     else{
          binHeight();
          //measuring the weight
          weight = measureWeight();
          Serial.println(weight);


          
        
      Serial.println("BIN CLOSED");

      /*******Preparing to send data to api**********/
    ModuleSerialGps::GpsData gpsData = gps.currentGpsData(); 

    int binId = 1;
    

    float LNG = gpsData.lng;
    float LAT = gpsData.lat;
          
    char buf[121];
    String id = String(binId);
    String c_level = String(heightOfWaste);
    String c_weight = String(weight);
    String s_noti = String(smokeDetected);// Not sure if this will work ..boolean...
    String loc_long = ftos(LNG);
    String loc_lat = ftos(LAT);
    
    if(heightOfWaste < 15 ){
          //Api End point when bin is full
          snprintf(buf,120,"http://zuba-app.herokuapp.com/api/v1/b?i=%s&cl=%s&cw=%s&sn=%s&lg=%s&lt=%s",id.c_str(),c_level.c_str(),c_weight.c_str(),s_noti.c_str(),loc_long.c_str(),loc_lat.c_str());
  
          Serial.print("RAW URL = ");
          Serial.println(buf);
          
          bool success = false; 
          Serial.print("URL = ");
          Serial.println(buf);
          request(buf,&success);
      }else{
          //send data to the end point when there is 100gram change in weight;
          double diff = weight - pweight;
          if (diff >= 100 || diff <= -100 ){
              pweight = weight;
              Serial.println("there was a change in weight");
              //send to endpoint
             snprintf(buf,120,"http://zuba-app.herokuapp.com/api/v1/b/u?i=%s&cl=%s&cw=%s&sn=%s&lg=%s&lt=%s",id.c_str(),c_level.c_str(),c_weight.c_str(),s_noti.c_str(),loc_long.c_str(),loc_lat.c_str());
           Serial.print("RAW URL = ");
          Serial.println(buf);
          
          bool success = false; 
          Serial.print("URL = ");
          Serial.println(buf);
          request(buf,&success);           
            }
        }
     }
    
      
}

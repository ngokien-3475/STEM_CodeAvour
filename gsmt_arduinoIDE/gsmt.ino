#include <Arduino.h>
#include <string.h>
#include "PMS.h"
#include <Wire.h>
#include <Nokia_5110.h>
#include <Bonezegei_DHT11.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// Khai báo chân cảm biến bụi
#define PMSA003_RX 16
#define PMSA003_TX 17
//Khái báo chân màn Nokia
#define LCD_RST 4
#define LCD_CE 32
#define LCD_DC 21
#define LCD_DIN 18
#define LCD_CLK 19
//Khai báo chân DHT11
#define DHT11_PIN 23
//Khai báo chân MQ7
#define MQ7_PIN 35
//Khai báo chân truyền tin UART1
#define UART1_TX 1
#define UART2_RX 3
// Thêm các hằng số hiệu chuẩn
#define RL 10.0    // Điện trở tải (kΩ)
float R0 = 3.5 ;    // Giá trị R0 trong không khí sạch (cần hiệu chuẩn thực tế)
#define VCC 3.3    // Điện áp nguồn (V)
//Setup wifi
const char* ssid[] = {"TVS", "iphone", "Audiophile", "Nguyen Duy Tan", "Kem Que"};
const char* password[] = {"12345678", "12345678", "0904079907", "0903441727", "hoangminh"};
const int Wifi_Number = 5;
//setup Firebase
#define API_KEY "AIzaSyApE5SkRt8Mk_B6I1vqIVwt53PutmLYK88"
#define DATABASE_URL "https://datn-chinh-default-rtdb.firebaseio.com/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool firebaseReady = false;
// Khởi tạo phần cứng
Nokia_5110 lcd = Nokia_5110(LCD_RST, LCD_CE, LCD_DC, LCD_DIN, LCD_CLK);
HardwareSerial SerialPMS(2);
PMS pms(SerialPMS);
PMS::DATA pmsData;
Bonezegei_DHT11 dht(DHT11_PIN);
// Biến khởi tạo
float value_MQ7;
float ppm_CO = 0;
float hum = 0;
float tempDeg = 0;
int currentAQI = 0;
const unsigned long SENSOR_READ_INTERVAL = 5000; 
const unsigned long FIREBASE_SEND_INTERVAL = 15000;
unsigned long lastSensorReadTime = 0;
unsigned long lastFirebaseSendTime = 0;
// Cấu trúc cho bảng AQI
struct AQILevel {
  int I_low;
  int I_high;
  int C_low;
  int C_high;
};

// Bảng tham chiếu AQI cho PM2.5 (theo EPA)
const AQILevel pm25Levels[] = {
  {0, 50, 0, 12},
  {51, 100, 12, 35},
  {101, 150, 35, 55},
  {151, 200, 55, 150},
  {201, 300, 150, 250},
  {301, 500, 250, 500}
};

// Bảng tham chiếu AQI cho PM10 (theo EPA)
const AQILevel pm10Levels[] = {
  {0, 50, 0, 54},
  {51, 100, 55, 154},
  {101, 150, 155, 254},
  {151, 200, 255, 354},
  {201, 300, 355, 424},
  {301, 500, 425, 604}
};

// Bảng tham chiếu AQI cho CO (theo EPA)
const AQILevel coLevels[] = {
  {0, 50, 0, 4},
  {51, 100, 5, 9},
  {101, 150, 10, 12},
  {151, 200, 13, 15},
  {201, 300, 16, 30},
  {301, 500, 31, 50}
};

int calculateAQI(int concentration, const AQILevel* levels, size_t count) {
  for (size_t i = 0; i < count; i++) {
    if (concentration >= levels[i].C_low && concentration <= levels[i].C_high) {
      return map(concentration, 
                levels[i].C_low, levels[i].C_high,
                levels[i].I_low, levels[i].I_high);
    }
  }
  return concentration > levels[count-1].C_high ? 500 : 0;
}

int getFinalAQI() {
  int aqiPM25 = calculateAQI(pmsData.PM_AE_UG_2_5, pm25Levels, sizeof(pm25Levels)/sizeof(pm25Levels[0]));
  int aqiPM10 = calculateAQI(pmsData.PM_AE_UG_10_0, pm10Levels, sizeof(pm10Levels)/sizeof(pm10Levels[0]));
  int aqiCO = calculateAQI(ppm_CO, coLevels, sizeof(coLevels)/sizeof(coLevels[0]));

  return max(aqiPM25, max(aqiPM10, aqiCO));
}


void readCO() {
  // 1. Đọc giá trị ADC và chuyển sang điện áp
  int rawADC = analogRead(MQ7_PIN);
  float voltage = rawADC * (VCC / 4095.0);

  // 2. Tính điện trở Rs của cảm biến
  float Rs = (VCC - voltage) / (voltage / RL);

  // 3. Tính tỉ số Rs/R0
  float ratio = Rs / R0;

  // 4. Tính ppm CO dùng công thức từ datasheet
  float ppm = 0.0;
  if (ratio > 1.0) {
    // Dải 10-1000 ppm: log10(ppm) = (log10(Rs/R0) - 0.6) / (-0.8)
    ppm = pow(10, (log10(ratio) - 0.6) / (-0.8));
  } else {
    // Dải dưới 10 ppm (nếu cần)
    ppm = pow(10, (log10(ratio) - 0.2) / (-0.4));
  }

  // 5. Lọc nhiễu và giới hạn giá trị
  ppm_CO = constrain(ppm, 1.0, 1000.0); // Giới hạn trong 1-1000ppm

  Serial.print("CO (ppm): ");
  Serial.println(ppm_CO);
}
void calibrateMQ7() {
  Serial.println("Calibrating MQ-7...");
  
  float avg = 0.0;
  for(int i = 0; i < 100; i++) {
    int rawADC = analogRead(MQ7_PIN);
    avg += rawADC * (VCC / 4095.0);
    delay(50);
  }
  
  float Vout = avg / 100.0;
  float Rs = (VCC - Vout) / (Vout / RL);
  R0 = Rs / 9.8; // 9.8 là tỉ lệ Rs/R0 trong không khí sạch theo datasheet
  
  Serial.print("Calibration complete. R0 = ");
  Serial.println(R0);
}
void setup(){}
void loop() {}





































void readPMSA003() {
  pms.wakeUp();
  pms.requestRead();
  if (pms.readUntil(pmsData)) {
    int finalAQI = getFinalAQI();

    Serial.print("AQI: ");
    Serial.println(finalAQI);

    String uartMessage = "";
    if (finalAQI < 50) uartMessage = "1";
    else if (finalAQI < 100) uartMessage = "12";
    else if (finalAQI < 150) uartMessage = "123";
    else if (finalAQI < 200) uartMessage = "1234";
    else if (finalAQI < 300) uartMessage = "12345";
    else uartMessage = "123456";

    Serial1.println(uartMessage);

     Serial.print("PM1.0 (ug/m3): ");
     Serial.println(pmsData.PM_AE_UG_1_0);
     Serial.print("PM2.5 (ug/m3): ");
     Serial.println(pmsData.PM_AE_UG_2_5);
     Serial.print("PM10 (ug/m3): ");
     Serial.println(pmsData.PM_AE_UG_10_0);
  }
  pms.sleep();
}


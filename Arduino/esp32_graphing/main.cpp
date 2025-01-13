#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <map>
#include <TFT_eSPI.h>

const int screen_width = 480;
const int screen_height = 320;
#define HISTORY_SIZE screen_width/4

const char* wifi_ssid = "esp-ecially";
const char* wifi_password = "coolgraphs";
const char* router_address = "http://192.168.88.1";
const char* router_login = "admin";
const char* router_password = "123";

const int graph_interface = 1; // The interface id for graphing

typedef struct mt_data_t {
    uint64_t rx;
    uint64_t tx;
    uint64_t time;
    int pos;
    uint64_t hist_rx[HISTORY_SIZE];
    uint64_t hist_tx[HISTORY_SIZE];
} mt_data_t;

std::map<int, mt_data_t*> ifaces;
TFT_eSPI tft = TFT_eSPI();

int id2int(const char* str) {
    str++; // drop *
    return strtol(str, 0, 16);
}

void setup() {
    Serial.begin(115200);
   
    // initiate screen 
    pinMode(TFT_BL, OUTPUT);
    digitalWrite(TFT_BL, HIGH);
    tft.begin();
    tft.setRotation(1);
    tft.fillScreen(TFT_BLACK);

    // initiate WiFi
    WiFi.mode(WIFI_STA);
    WiFi.begin(wifi_ssid, wifi_password);
    while (WiFi.status() != WL_CONNECTED) {
        Serial.print(".\n");
        delay(500);
    }
    Serial.println();
}

void loop() {
  // Make an API request
  String url = String(router_address) + "/rest/interface/ethernet/print";
  String query = "{\".proplist\": \".id,name,rx-bytes,tx-bytes,running\"}";
  HTTPClient http;
  http.begin(url.c_str());
  http.addHeader("Content-Type", "application/json");
  http.setAuthorization(router_login, router_password);
  int httpResponseCode = http.POST(query);

  if (httpResponseCode >= 400) {
    Serial.printf("Failed (%u)\n", httpResponseCode);
  } else {
    Serial.printf("Success (%u)\n", httpResponseCode);
  }
  
  long time = millis();
  JsonDocument doc;
  deserializeJson(doc, http.getStream());

  for (JsonObject obj : doc.as<JsonArray>()) {
    String strid = obj[".id"];
    uint64_t rx = obj["rx-bytes"];
    uint64_t tx = obj["tx-bytes"];
    String name = obj["name"];

    Serial.println("[" + strid + "] " + name);
    Serial.printf("     rx-bytes: %lu\n", rx);
    Serial.printf("     tx-bytes: %lu\n", tx);
    
    int id = id2int(strid.c_str());
    mt_data_t* iface;
    if (ifaces.find(id) == ifaces.end()) {
      Serial.println("CREATE IFACE");
      // add a new interface to map
      iface = (mt_data_t*) malloc(sizeof(mt_data_t));
      memset(iface, 0, sizeof(mt_data_t));
      iface->rx = rx;
      iface->tx = tx;
      iface->time = time;
      iface->pos = 0;
      ifaces[id] = iface;
    } else {
      // or get existing interface
      iface = ifaces[id];
    }

    float timed = (time - iface->time) / 1000.0;
    if (timed == 0) timed = 1; // can't divide by 0

    uint64_t rxd = (rx - iface->rx) / timed;
    uint64_t txd = (tx - iface->tx) / timed;

    iface->rx = rx;
    iface->tx = tx;
    iface->time = time;

    Serial.printf("     tx-rate: %lu bps\n", txd * 8);
    Serial.printf("     tx-rate: %lu bps\n", rxd * 8);

    iface->hist_rx[iface->pos] = rxd;
    iface->hist_tx[iface->pos] = txd;

    if (++iface->pos >= HISTORY_SIZE) {
      iface->pos = 0;
    }
  }

  if (ifaces.find(graph_interface) != ifaces.end()) {
    mt_data_t* iface = ifaces[graph_interface];
    // determine max value that has to fit in the screen
    uint64_t max_rate = 1024;
    for (int i=0;i<HISTORY_SIZE;i++) {
      max_rate = max(max_rate, iface->hist_rx[i]);
      max_rate = max(max_rate, iface->hist_tx[i]);
    }

    // draw
    int p = iface->pos;
    for (int x=0;x<screen_width;x+=4) {
      p++;
      if (p > HISTORY_SIZE) {p = 0;}

      int32_t rx_y = map(iface->hist_rx[p], 0, max_rate, screen_height - 1, 45);
      int32_t tx_y = map(iface->hist_tx[p], 0, max_rate, screen_height - 1, 45);

      tft.fillRect(x, 45, 2, screen_height-45, TFT_BLACK);
      tft.fillRect(x, tx_y, 2, screen_height-tx_y, TFT_SKYBLUE);
      tft.fillRect(x+2, 45, 2, screen_height-45, TFT_BLACK);
      tft.fillRect(x+1, rx_y, 2, screen_height-rx_y, TFT_GREENYELLOW);
    }
    
    float rx_rate = iface->hist_rx[iface->pos -1] * 8.0 / 1024 / 1024; // Bps to Mbps
    float tx_rate = iface->hist_tx[iface->pos -1] * 8.0 / 1024 / 1024;

    tft.setTextColor(TFT_WHITE);
    tft.setTextSize(2);
    tft.setCursor(0,0);
    tft.fillRect(0, 0, 480, 30, TFT_BLACK);
    tft.printf("TX: %.2f Mbps\nRX: %.2f Mbps", 
        rx_rate,
        tx_rate
    );
  }
  delay(1000);
}

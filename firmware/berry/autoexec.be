#- ================================================
   CO2 Sensor - autoexec.be
   Hardware: ESP32-D0WD-V3 + SCD41 + SSD1306 + DS3231 + SDCard
   Firmware: Tasmota 15.3.0.4 (custom build com USE_ALWAYS_AP)
   Repositório: https://github.com/mfdomp/co2-sensor-tasmota
   ================================================ -#

# ── Configurações ─────────────────────────────────
var SSD = 0x3C          # Endereço I2C do display SSD1306
var RTC = 0x68          # Endereço I2C do RTC DS3231
var LOG_INTERVAL = 10   # Intervalo de gravação no SDCard em segundos
var log_counter  = 0
var loop_count   = 0
var last_count   = 0

import json

# ── Fonte 5x7 ASCII 32-126 ────────────────────────
var FONT = bytes(
  "0000000000" + "00005F0000" + "0007000700" + "147F147F14" +
  "242A7F2A12" + "2313086462" + "3649552250" + "0005030000" +
  "001C224100" + "0041221C00" + "14083E0814" + "08083E0808" +
  "0050300000" + "0808080808" + "0060600000" + "2010080402" +
  "3E5149453E" + "00427F4000" + "4261514946" + "2141454B31" +
  "1814127F10" + "2745454539" + "3C4A494930" + "0171090503" +
  "3649494936" + "064949291E" + "0036360000" + "0056360000" +
  "0814224100" + "1414141414" + "0041221408" + "0201510906" +
  "3249494924" + "7E1111117E" + "7F49494936" + "3E41414122" +
  "7F4141221C" + "7F49494941" + "7F09090901" + "3E4149497A" +
  "7F0808087F" + "00417F4100" + "2040413F01" + "7F08142241" +
  "7F40404040" + "7F0204027F" + "7F0408107F" + "3E4141413E" +
  "7F09090906" + "3E4151215E" + "7F09192946" + "4649494931" +
  "01017F0101" + "3F4040403F" + "1F2040201F" + "3F4038403F" +
  "6314081463" + "0708700807" + "6151494543" + "007F414100" +
  "0204081020" + "0041417F00" + "0402010204" + "4040404040" +
  "0001020400" + "2054545478" + "7F48444438" + "3844444420" +
  "384444487F" + "3854545418" + "087E090102" + "0C5252523E" +
  "7F08040478" + "00447D4000" + "2040443D00" + "7F10284400" +
  "00417F4000" + "7C04180478" + "7C08040478" + "3844444438" +
  "7C14141408" + "081414187C" + "7C08040408" + "4854545420" +
  "043F444020" + "3C4040407C" + "1C2040201C" + "3C4030403C" +
  "4428102844" + "0C5050503C" + "4464544C44" + "0008364100" +
  "00007F0000" + "0041360800" + "1008081008"
)

# ── Referência ASCII ──────────────────────────────
var REF = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

# ── Funções auxiliares ────────────────────────────

def ascii(c)
  for i: 0..size(REF)-1
    if REF[i] == c  return i + 32  end
  end
  return 32
end

def bcd(b)
  return (b >> 4) * 10 + (b & 0x0F)
end

def zpad(n)
  if n < 10  return '0' + str(n)  else  return str(n)  end
end

# ── Driver SSD1306 ────────────────────────────────

def ssd_cmd(c)   wire1.write(SSD, 0x00, c, 1)  end
def ssd_byte(b)  wire1.write(SSD, 0x40, b, 1)  end

def ssd_init()
  for c: [0xAE, 0xD5, 0x80, 0xA8, 0x3F, 0xD3, 0x00, 0x40,
          0x8D, 0x14, 0x20, 0x02, 0xA1, 0xC8, 0xDA, 0x12,
          0x81, 0xCF, 0xD9, 0xF1, 0xDB, 0x40, 0xA4, 0xA6, 0xAF]
    ssd_cmd(c)
  end
end

def ssd_goto(col, page)
  ssd_cmd(0xB0 | page)
  ssd_cmd(col & 0x0F)
  ssd_cmd(0x10 | (col >> 4))
end

def ssd_clear()
  for page: 0..7
    ssd_goto(0, page)
    for i: 0..127  ssd_byte(0)  end
    tasmota.yield()
  end
end

def ssd_print_fixed(s, col, page, maxchars)
  var x = col
  for i: 0..maxchars-1
    var ch = 32
    if i < size(s)  ch = ascii(s[i])  end
    if ch < 32 || ch > 126  ch = 32  end
    var idx = (ch - 32) * 5
    ssd_goto(x, page)
    for k: idx..idx+4  ssd_byte(FONT[k])  end
    ssd_byte(0)
    x += 6
  end
end

# ── Driver DS3231 ─────────────────────────────────

def read_rtc()
  var sec  = bcd(wire1.read(RTC, 0x00, 1) & 0x7F)
  var min  = bcd(wire1.read(RTC, 0x01, 1))
  var hour = bcd(wire1.read(RTC, 0x02, 1) & 0x3F)
  var date = bcd(wire1.read(RTC, 0x04, 1))
  var mon  = bcd(wire1.read(RTC, 0x05, 1) & 0x1F)
  var year = bcd(wire1.read(RTC, 0x06, 1)) + 2000
  return [hour, min, sec, date, mon, year]
end

def sync_rtc()
  # Só sincroniza se NTP estiver disponível (utc > ano 2001)
  var now = tasmota.rtc()
  var utc = now['utc']
  if utc < 1000000000
    print('NTP nao sincronizado, RTC preservado')
    return
  end
  var ts   = utc - 10800   # UTC-3
  var sec  = ts % 60   ts = ts / 60
  var min  = ts % 60   ts = ts / 60
  var hour = ts % 24   ts = ts / 24
  ts = ts + 719468
  var era = ts / 146097
  var doe = ts - era * 146097
  var yoe = (doe - doe/1460 + doe/36524 - doe/146096) / 365
  var y   = yoe + era * 400
  var doy = doe - (365*yoe + yoe/4 - yoe/100)
  var mp  = (5*doy + 2) / 153
  var day = doy - (153*mp + 2)/5 + 1
  var mon = mp + (mp < 10 ? 3 : -9)
  if mon <= 2  y += 1  end
  var year = y - 2000
  def tobcd(n)  return ((n/10) << 4) | (n%10)  end
  wire1.write(RTC, 0x00, tobcd(sec),  1)
  wire1.write(RTC, 0x01, tobcd(min),  1)
  wire1.write(RTC, 0x02, tobcd(hour), 1)
  wire1.write(RTC, 0x04, tobcd(day),  1)
  wire1.write(RTC, 0x05, tobcd(mon),  1)
  wire1.write(RTC, 0x06, tobcd(year), 1)
  print('RTC sincronizado: ' + str(day) + '/' + str(mon) + '/' + str(year+2000) + ' ' + str(hour) + ':' + str(min) + ':' + str(sec))
end

# ── Calibração SCD41 ──────────────────────────────
# Uso: calibrar_scd41(900)  # valor em ppm do ambiente de referência

def calibrar_scd41(ppm)
  wire1.write(0x62, 0x36, 0x03, 1)
  tasmota.set_timer(3000, def()
    var msb = (ppm + 32768) >> 8
    var lsb = (ppm + 32768) & 0xFF
    var crc = 0xFF
    crc = crc ^ msb
    for i: 0..7
      if crc & 0x80  crc = (crc << 1) ^ 0x31  else  crc = crc << 1  end
      crc = crc & 0xFF
    end
    crc = crc ^ lsb
    for i: 0..7
      if crc & 0x80  crc = (crc << 1) ^ 0x31  else  crc = crc << 1  end
      crc = crc & 0xFF
    end
    wire1.write(0x62, 0x36, 0x27, 1)
    tasmota.yield()
    wire1.write(0x62, msb, lsb, 1)
    wire1.write(0x62, crc, 0x00, 1)
    print('Calibracao enviada: ' + str(ppm) + ' ppm')
  end)
end

# ── SDCard Log ────────────────────────────────────

var LOGFILE   = ''
var LOGHANDLE = nil

def init_logfile(t)
  try
    LOGFILE = '/sd/co2_' + str(t[5]) + zpad(t[4]) + zpad(t[3]) + '_' + zpad(t[0]) + zpad(t[1]) + '.csv'
    LOGHANDLE = open(LOGFILE, 'w')
    LOGHANDLE.write('datetime,co2,temperature,humidity\n')
    LOGHANDLE.flush()
    print('Log: ' + LOGFILE)
  except .. as e, m
    print('ERR init_logfile: ' + str(e) + ' ' + str(m))
    LOGHANDLE = nil
    tasmota.set_timer(10000, def()  init_logfile(read_rtc())  end)
  end
end

def log_sd(co2, temp, humi, t)
  if LOGHANDLE == nil  return  end
  var dt = zpad(t[3]) + '/' + zpad(t[4]) + '/' + str(t[5]) + ' ' + zpad(t[0]) + ':' + zpad(t[1]) + ':' + zpad(t[2])
  LOGHANDLE.write(dt + ',' + co2 + ',' + temp + ',' + humi + '\n')
  LOGHANDLE.flush()
end

# ── Configuração de GPIOs ─────────────────────────
# Roda apenas uma vez — detecta se já está configurado

def setup_gpio()
  try
    var r = tasmota.cmd('GPIO21')
    if r != nil
      var cur = r.find('GPIO21')
      if cur == 640  return  end
      if type(cur) == 'string' && cur.find('I2C SDA1') != nil  return  end
    end
  except .. as e, m
    print('GPIO check: ' + str(e))
  end
  tasmota.cmd('GPIO21 640')   # I2C SDA1
  tasmota.cmd('GPIO22 608')   # I2C SCL1
  tasmota.cmd('GPIO18 736')   # SPI CLK
  tasmota.cmd('GPIO19 672')   # SPI MISO
  tasmota.cmd('GPIO23 704')   # SPI MOSI
  tasmota.cmd('GPIO5 6720')   # SDCard CS
  print('GPIOs configurados - reiniciando...')
  tasmota.cmd('Restart 1')
end

# ── Identidade do dispositivo ─────────────────────
# Nome: Sensor-XXXXXX (6 últimos dígitos do MAC)

def setup_identity()
  var wf  = tasmota.wifi()
  var mac = wf.find('mac', '')
  if size(mac) < 12
    print('MAC nao disponivel ainda')
    return
  end
  var clean = ''
  for i: 0..size(mac)-1
    if mac[i] != ':'  clean += mac[i]  end
  end
  var nome = 'Sensor-' + clean[6..11]
  var cur  = tasmota.cmd('Hostname')
  if cur['Hostname'] == nome
    print('Identidade ok: ' + nome)
    return
  end
  tasmota.cmd('Hostname ' + nome)
  print('Identidade configurada: ' + nome)
end

# ── Display update ────────────────────────────────

def update_display()
  loop_count += 1
  var raw = tasmota.read_sensors()
  if raw == nil  return  end
  var j = json.load(raw)
  if j == nil  return  end
  var scd = j.find('SCD41')
  if scd == nil  return  end
  var co2  = str(int(scd.find('CarbonDioxide', 0)))
  var temp = format('%.1f', scd.find('Temperature', 0.0))
  var humi = str(int(scd.find('Humidity', 0)))
  var t    = read_rtc()
  var wf   = tasmota.wifi()
  var ip   = wf.find('ip', '192.168.4.1')
  log_counter += 10
  var should_log = (log_counter >= LOG_INTERVAL)
  if should_log  log_counter = 0  end
  var rtc_ok = (t[5] >= 2024 && t[5] <= 2035)
  if rtc_ok
    ssd_print_fixed(zpad(t[3]) + '/' + zpad(t[4]) + '/' + str(t[5]), 0, 0, 10)
    ssd_print_fixed(zpad(t[0]) + ':' + zpad(t[1]), 0, 1, 5)
    if should_log  log_sd(co2, temp, humi, t)  end
  else
    ssd_print_fixed('Acerte o RTC!', 0, 0, 13)
    ssd_print_fixed('--/--/----', 0, 1, 10)
  end
  ssd_print_fixed('CO2:' + co2 + ' ppm', 0, 3, 15)
  ssd_print_fixed('T:' + temp + 'C H:' + humi + '%', 0, 5, 16)
  ssd_print_fixed(ip, 0, 7, 16)
end

# ── Loop principal ────────────────────────────────

def disp_loop()
  try
    update_display()
  except .. as e, m
    print('ERR disp_loop: ' + str(e) + ' ' + str(m))
  end
  tasmota.set_timer(10000, disp_loop)
end

# ── Watchdog ──────────────────────────────────────

def watchdog()
  if loop_count == last_count
    print('ALERTA: loop travado! Reiniciando...')
    tasmota.cmd('Restart 1')
  end
  last_count = loop_count
  tasmota.set_timer(60000, watchdog)
end

# ── Boot ──────────────────────────────────────────

tasmota.set_timer(20000, def()
  setup_gpio()
  setup_identity()
  sync_rtc()
  var t = read_rtc()
  var rtc_valid = (t[5] >= 2024 && t[5] <= 2035)
  if rtc_valid  init_logfile(t)  end
  ssd_init()
  ssd_clear()
  tasmota.set_timer(1000, disp_loop)
  tasmota.set_timer(70000, watchdog)
end)

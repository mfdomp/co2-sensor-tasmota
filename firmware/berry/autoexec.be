#- ─────────────────────────────────────────────────────────────────────────────
  autoexec.be — CO2 Sensor Monitor
  Hardware : ESP32-D0WD-V3 + SCD41 + SSD1306 + DS3231 + MicroSD
  Firmware : Tasmota v14+ com Berry scripting

  Comportamento:
  - Lê CO2, temperatura e umidade do SCD41 a cada 5 s (display)
  - Atualiza o display OLED SSD1306 128×64 com os dados e o horário do DS3231
  - Grava uma linha CSV no cartão SD a cada 60 s
  - Emite log no console Tasmota para depuração
──────────────────────────────────────────────────────────────────────────────-#

import json
import string

class CO2Monitor

  var log_file       # caminho do CSV no SD card
  var log_interval   # intervalo de log em ms
  var disp_interval  # intervalo de refresh do display em ms
  var last_log       # timestamp do último log (millis)
  var last_disp      # timestamp do último refresh de display (millis)
  var co2            # última leitura de CO2 (ppm)
  var temp           # última temperatura (°C)
  var hum            # última umidade (%)
  var initialized    # flag: inicialização concluída

  # ── construtor ──────────────────────────────────────────────────────────────

  def init()
    self.log_file     = "/sd/co2_log.csv"
    self.log_interval = 60000    # 60 s
    self.disp_interval = 5000    # 5 s
    self.last_log     = -60000   # força log imediato na primeira leitura
    self.last_disp    = -5000
    self.co2          = 0.0
    self.temp         = 0.0
    self.hum          = 0.0
    self.initialized  = false

    # aguarda Tasmota terminar o boot antes de inicializar periféricos
    tasmota.set_timer(3000, /-> self._startup())
  end

  # ── inicialização pós-boot ──────────────────────────────────────────────────

  def _startup()
    self._init_display()
    self._init_log()
    self.initialized = true
    tasmota.log("CO2Monitor: pronto", 2)
  end

  # ── display ─────────────────────────────────────────────────────────────────

  def _init_display()
    tasmota.cmd("DisplayMode 0")   # modo texto livre
    tasmota.cmd("DisplayClear")
    tasmota.cmd("DisplayText [f1s2x8y0]CO2 Monitor")
    tasmota.cmd("DisplayText [f1x0y20]Iniciando...")
    tasmota.cmd("DisplayText [f1x0y36]Aguarde o sensor")
  end

  def _co2_label(ppm)
    if ppm < 600   return "Excelente"  end
    if ppm < 800   return "Bom      "  end
    if ppm < 1000  return "Moderado "  end
    if ppm < 1500  return "Ruim     "  end
    return                "Perigoso "
  end

  def _refresh_display()
    var rtc      = tasmota.rtc()
    var time_str = tasmota.strftime("%H:%M:%S", rtc["local"])
    var date_str = tasmota.strftime("%d/%m/%Y", rtc["local"])
    var label    = self._co2_label(self.co2)

    tasmota.cmd("DisplayClear")
    # linha 0: título e hora
    tasmota.cmd(string.format("DisplayText [f1s1x0y0]CO2  %s", time_str))
    # linha 1: data
    tasmota.cmd(string.format("DisplayText [f1x0y12]%s", date_str))
    # linha 2: CO2 em destaque
    tasmota.cmd(string.format("DisplayText [f1x0y26]CO2: %i ppm", int(self.co2)))
    # linha 3: qualidade do ar
    tasmota.cmd(string.format("DisplayText [f1x0y38]Ar : %s", label))
    # linha 4: temperatura e umidade
    tasmota.cmd(string.format("DisplayText [f1x0y50]%.1fC   %.0f %%RH", self.temp, self.hum))
  end

  # ── SD card / log CSV ───────────────────────────────────────────────────────

  def _init_log()
    import path
    if !path.exists(self.log_file)
      var f = open(self.log_file, "w")
      if f != nil
        f.write("datetime,co2_ppm,temperature_c,humidity_pct\n")
        f.close()
        tasmota.log("CO2Monitor: arquivo de log criado em " + self.log_file, 2)
      else
        tasmota.log("CO2Monitor: ERRO - nao foi possivel criar o log (SD montado?)", 1)
      end
    else
      tasmota.log("CO2Monitor: log existente em " + self.log_file, 2)
    end
  end

  def _write_log()
    var f = open(self.log_file, "a")
    if f == nil
      tasmota.log("CO2Monitor: ERRO - nao foi possivel abrir o log para escrita", 1)
      return
    end
    var dt = tasmota.strftime("%Y-%m-%dT%H:%M:%S", tasmota.rtc()["local"])
    f.write(string.format("%s,%i,%.2f,%.2f\n",
            dt, int(self.co2), self.temp, self.hum))
    f.close()
  end

  # ── leitura de sensores ──────────────────────────────────────────────────────

  def _read_sensors()
    var raw = tasmota.read_sensors()
    if raw == nil || raw == "" return false end

    var j = json.load(raw)
    if j == nil return false end

    # Tasmota registra SCD41 sob a chave "SCD40" (driver cobre ambos os modelos)
    if j.contains("SCD40")
      var s = j["SCD40"]
      self.co2  = real(s["CarbonDioxide"])
      self.temp = real(s["Temperature"])
      self.hum  = real(s["Humidity"])
      return true
    end
    return false
  end

  # ── interface de driver Tasmota (chamada a cada segundo) ─────────────────────

  def every_second()
    if !self.initialized return end

    var now = tasmota.millis()

    # refresh do display
    if (now - self.last_disp) >= self.disp_interval
      if self._read_sensors()
        self._refresh_display()
      end
      self.last_disp = now
    end

    # gravação no log
    if (now - self.last_log) >= self.log_interval
      if self.co2 > 0
        self._write_log()
        tasmota.log(string.format(
          "CO2Monitor: log gravado — CO2=%i ppm T=%.1fC H=%.0f%%",
          int(self.co2), self.temp, self.hum), 2)
      else
        tasmota.log("CO2Monitor: aguardando leitura valida do SCD41", 2)
      end
      self.last_log = now
    end
  end

end  # class CO2Monitor

# ── instancia e registra o driver ────────────────────────────────────────────
var co2_monitor = CO2Monitor()
tasmota.add_driver(co2_monitor)

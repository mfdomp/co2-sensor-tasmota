# Guia de Configuração

## Pré-requisitos

- Python 3.8+ (para esptool)
- Tasmota `tasmota32.bin` v14.0 ou superior — [download](https://github.com/arendst/Tasmota/releases)
- Cartão MicroSD FAT32, até 32 GB
- Módulo ESP32 conectado via USB

## 1. Instalar o firmware Tasmota no ESP32

### Opção A — tasmota-install (recomendado)

```bash
pip install tasmota-install
tasmota-install
```

Selecione a porta serial e o firmware `tasmota32.bin`.

### Opção B — esptool manual

```bash
pip install esptool

# Apaga a flash
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Grava o firmware (offset 0x0 para binários Tasmota ESP32)
esptool.py --chip esp32 --port /dev/ttyUSB0 \
  --baud 921600 write_flash -z 0x0 tasmota32.bin
```

No Windows, substitua `/dev/ttyUSB0` por `COM3` (ou a porta correta).

### Opção C — Tasmota Web Installer

Acesse [https://tasmota.github.io/install/](https://tasmota.github.io/install/) via Chrome/Edge e grave diretamente pelo browser.

## 2. Configuração inicial do Wi-Fi

1. Após gravar, o ESP32 cria uma rede Wi-Fi chamada **tasmota-XXXXXX**.
2. Conecte-se a ela e acesse `http://192.168.4.1`.
3. Configure o SSID e a senha da sua rede.
4. O dispositivo reinicia e obtém um IP na sua rede.

## 3. Aplicar o template de GPIOs

1. Acesse a interface web do dispositivo: `http://<ip-do-dispositivo>`.
2. Vá em **Configuration → Configure Other**.
3. Cole o conteúdo de `firmware/tasmota/tasmota_template.json` no campo **Template**.
4. Marque **Activate** e clique em **Save**.
5. O dispositivo reinicia com os GPIOs mapeados.

### Mapeamento do template

| GPIO | Função Tasmota | Periférico |
|---|---|---|
| GPIO 21 | I2C SDA | SCD41, SSD1306, DS3231 |
| GPIO 22 | I2C SCL | SCD41, SSD1306, DS3231 |
| GPIO 23 | SPI MOSI | SD Card |
| GPIO 19 | SPI MISO | SD Card |
| GPIO 18 | SPI CLK | SD Card |
| GPIO 5 | SD Card CS | SD Card |

## 4. Configurar drivers e display via console

Acesse **Tools → Console** na interface web e execute:

```
# Drivers I2C: SCD40/SCD41 (44) e DS3231 (56)
Backlog I2CDriver44 1; I2CDriver56 1

# Display SSD1306 128x64 no endereço 0x3C (decimal 60)
Backlog DisplayModel 2; DisplayWidth 128; DisplayHeight 64; DisplayAddress 60; DisplayMode 0

# Fuso horário UTC-3 (Brasília)
Backlog Timezone -3

# Telemetria MQTT a cada 60 segundos
TelePeriod 60

# Reiniciar
Restart 1
```

## 5. Verificar detecção dos sensores

Após reiniciar, no console:

```
I2CScan
```

Saída esperada:
```
I2C Device found at address 0x3C  (SSD1306)
I2C Device found at address 0x62  (SCD41)
I2C Device found at address 0x68  (DS3231)
```

```
Status 8
```

Deve retornar JSON com campos `SCD40.CarbonDioxide`, `SCD40.Temperature`, `SCD40.Humidity`.

## 6. Preparar o cartão SD

1. Formate o cartão como **FAT32**.
2. Insira no módulo SD (conectado ao ESP32).
3. No console Tasmota, verifique:

```
SDInfo
```

Saída esperada:
```
{"SDCard":{"Mounted":1,"Free":14982144,"Used":0,"Total":14982144}}
```

## 7. Carregar o script Berry

1. Na interface web, vá em **Tools → Manage File System**.
2. Clique em **Choose File** e selecione `firmware/berry/autoexec.be`.
3. Clique em **Upload**.
4. Reinicie o dispositivo:

```
Restart 1
```

O display deve acender em ~3 segundos após o boot e exibir as leituras em ~8 segundos (tempo de aquecimento do SCD41 na primeira medição).

## 8. Acerto do RTC DS3231

O Tasmota sincroniza o DS3231 automaticamente via NTP quando há conexão com a internet. Para definir a hora manualmente (sem internet):

```
Time 2025-01-15T14:30:00
```

O DS3231 mantém o horário mesmo sem energia no ESP32 (bateria CR2032).

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| Display não liga | GPIO errado ou display sem alimentação | Verificar pinagem e `I2CScan` |
| SCD41 não detectado | Endereço I2C errado ou pull-ups faltando | Verificar 4,7 kΩ no SDA/SCL |
| SD não montado | Formato incorreto ou CS errado | Formatar FAT32; conferir GPIO5 |
| `Status 8` sem SCD40 | Driver I2CDriver44 não habilitado | `I2CDriver44 1` + `Restart 1` |
| Hora incorreta | DS3231 sem bateria ou fuso errado | Verificar CR2032; `Timezone -3` |
| Log não criado | SD não montado no momento do boot | Reiniciar após confirmar `SDInfo` |

## Compilação customizada (opcional)

Se preferir compilar o Tasmota com os drivers incluídos estaticamente:

```c
// user_config_override.h
#define USE_SCD40         // SCD41 sensor
#define USE_DS3231        // RTC DS3231
#define USE_DISPLAY       // subsistema de display
#define USE_DISPLAY_SSD1306
#define USE_BERRY         // scripting Berry
#define USE_SDCARD        // suporte SD card
```

Use PlatformIO com o `platformio.ini` do repositório Tasmota.

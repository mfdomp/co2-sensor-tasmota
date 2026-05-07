# Guia de Configuração

## Pré-requisitos

- Python 3.8+ (para esptool, se for gravar via serial)
- Cartão MicroSD FAT32, até 32 GB
- Módulo ESP32 conectado via USB (para flash inicial)

## 1. Instalar o firmware Tasmota no ESP32

Este projeto fornece um firmware pré-compilado em `firmware/tasmota32-custom.zip` com todos os drivers necessários (SCD41, DS3231, SD Card, Berry). Extraia o `.bin` antes de gravar.

> Se já tiver um Tasmota qualquer rodando no ESP32, use a **Opção D (OTA)** — mais prática.

### Opção A — esptool manual (recomendado para flash inicial)

```bash
pip install esptool

# Apaga a flash
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Grava o firmware (offset 0x0 para binários Tasmota ESP32)
esptool.py --chip esp32 --port /dev/ttyUSB0 \
  --baud 921600 write_flash -z 0x0 tasmota32-custom.bin
```

No Windows, substitua `/dev/ttyUSB0` por `COM3` (ou a porta correta).

### Opção B — tasmota-install

```bash
pip install tasmota-install
tasmota-install
```

Selecione a porta serial e aponte para o `tasmota32-custom.bin` extraído do zip.

### Opção C — Tasmota Web Installer

Acesse [https://tasmota.github.io/install/](https://tasmota.github.io/install/) via Chrome/Edge, conecte o ESP32 via USB e selecione o arquivo `tasmota32-custom.bin`.

### Opção D — Atualização OTA (para dispositivos já com Tasmota)

1. Na interface web do dispositivo, vá em **Firmware Upgrade → Upgrade by file upload**.
2. Selecione o arquivo `tasmota32-custom.bin` extraído do zip.
3. Clique em **Start upgrade**.
4. O dispositivo reinicia automaticamente com o novo firmware.

> Não é necessário apagar a flash no upgrade OTA — as configurações de Wi-Fi e GPIOs são preservadas.

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

| GPIO | Código Tasmota | Periférico |
|---|---|---|
| GPIO 5  | 6720 — SD Card CS | SD Card |
| GPIO 18 | 736 — SPI CLK    | SD Card |
| GPIO 19 | 672 — SPI MISO   | SD Card |
| GPIO 21 | 640 — I2C SDA    | SCD41, SSD1306, DS3231 |
| GPIO 22 | 608 — I2C SCL    | SCD41, SSD1306, DS3231 |
| GPIO 23 | 704 — SPI MOSI   | SD Card |

> O script Berry também aplica esses GPIOs via `setup_gpio()` no boot, mas o template garante o mapeamento correto desde o primeiro reinício.

## 4. Configurar drivers via console

Acesse **Tools → Console** na interface web e execute:

```
# Drivers I2C: SCD41 (44) e DS3231 (56)
Backlog I2CDriver44 1; I2CDriver56 1

# Fuso horário UTC-3 (Brasília) para NTP
Backlog Timezone -3; TimeDST 0,0,0,0,0,-2; TimeSTD 0,0,0,0,0,-3

# Reiniciar
Restart 1
```

> O display SSD1306 é controlado diretamente pelo script Berry via `wire1` — **não** configure `DisplayModel` nem `DisplayMode`. O subsistema de Display do Tasmota não é utilizado.

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

Deve retornar JSON com campos `SCD41.CarbonDioxide`, `SCD41.Temperature`, `SCD41.Humidity`.

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
2. Clique em **Choose File** e selecione `firmware/autoexec.be`.
3. Clique em **Upload**.
4. Reinicie o dispositivo:

```
Restart 1
```

O script aguarda **20 s** após o boot antes de inicializar (tempo de estabilização do Tasmota e do Wi-Fi). O display acende ~1 s depois, exibindo as primeiras leituras em ~21 s no total.

## 8. Sincronização do DS3231

O script sincroniza o DS3231 automaticamente via NTP (usando `tasmota.rtc()`) no boot, desde que haja conexão com a internet. O RTC mantém o horário mesmo sem energia no ESP32 (bateria CR2032).

Para definir a hora manualmente (sem internet):

```
Time 2025-04-28T14:30:00
Restart 1
```

O script usa o horário do Tasmota (UTC-3) para sincronizar o DS3231 na próxima reinicialização.

## 9. Calibração do SCD41

Para calibração forçada com ar externo (~420 ppm CO₂):

```
Br calibrar_scd41(420)
```

A função para a medição, aguarda 3 s, aplica FRC (Forced Recalibration) e imprime confirmação no console. Execute em ambiente externo ventilado com o sensor estabilizado por pelo menos 3 minutos.

## Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| Display não liga após 21 s | GPIO errado ou endereço I2C | Verificar pinagem e `I2CScan` |
| SCD41 não detectado | Endereço I2C errado ou pull-ups faltando | Verificar 4,7 kΩ no SDA/SCL |
| SD não montado | Formato incorreto ou CS errado | Formatar FAT32; confirmar GPIO5=6720 no template |
| `Status 8` sem SCD41 | Driver I2CDriver44 não habilitado | `I2CDriver44 1` + `Restart 1` |
| Hora incorreta no display | DS3231 sem bateria ou NTP indisponível | Verificar CR2032; usar `Time` manual + `Restart 1` |
| Log não criado | SD não montado no momento do boot | Reiniciar após confirmar `SDInfo` |
| ESP32 reinicia sozinho | Watchdog ativo (loop travado) | Verificar console para mensagem `ALERTA: loop travado!` |

## Recompilação customizada (opcional)

O firmware em `firmware/tasmota32-custom.zip` já foi compilado com as flags abaixo. Recompile apenas se precisar alterar drivers ou versão do Tasmota.

```c
// user_config_override.h
#define USE_SCD40         // SCD41 sensor (driver cobre ambos os modelos)
#define USE_DS3231        // RTC DS3231
#define USE_BERRY         // scripting Berry
#define USE_SDCARD        // suporte SD card
```

> `USE_DISPLAY` e `USE_DISPLAY_SSD1306` **não são necessários** — o script controla o SSD1306 diretamente via I2C.

Use PlatformIO com o `platformio.ini` do repositório Tasmota.

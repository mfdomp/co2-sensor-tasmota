# CO2 Sensor — ESP32 + Tasmota

Monitor de qualidade do ar com ESP32, sensor SCD41, display OLED, RTC e log em cartão SD. O firmware é o Tasmota 15.3.0.4 com script Berry (`autoexec.be`) que controla o display SSD1306 diretamente via I2C, sincroniza o DS3231 via NTP no boot e grava logs CSV no cartão SD.

## Funcionalidades

- Leitura de CO2 (ppm), temperatura (°C) e umidade relativa (%) via SCD41
- Display OLED SSD1306 128×64 com driver próprio em Berry (fonte 5×7, sem subsistema Display do Tasmota)
- Relógio em tempo real DS3231 — lido diretamente via I2C, sincronizado por NTP a cada boot
- Log CSV no cartão SD com timestamp local, gravado a cada 10 s; nome de arquivo gerado pela data/hora do boot
- Watchdog de software: reinicia o ESP32 se o loop principal travar por mais de 60 s
- Calibração forçada do SCD41 via função Berry `calibrar_scd41(ppm)` acessível pelo console
- Telemetria MQTT e painel web via Tasmota (opcional)
- Sem código C/C++ customizado — só Berry script + configuração Tasmota

## Hardware

| Componente | Descrição |
|---|---|
| ESP32-D0WD-V3 | Módulo principal (ex.: DevKit-C V4 38 pinos) |
| SCD41 | Sensor CO2 fotoacústico ± 40 ppm (I2C 0x62) |
| SSD1306 | Display OLED 0,96″ 128×64 px (I2C 0x3C) |
| DS3231 | Módulo RTC alta precisão (I2C 0x68) |
| Módulo MicroSD | Adaptador SPI para cartão MicroSD |

Todos os dispositivos I2C compartilham o mesmo barramento (GPIO 21/22).  
O cartão SD usa SPI dedicado (GPIO 5/18/19/23).

## Estrutura do repositório

```
co2-sensor-tasmota/
├── README.md
├── LICENSE
├── docs/
│   ├── bom.md          # Bill of Materials detalhada
│   ├── wiring.md       # Diagrama de conexões e pinagem
│   └── setup.md        # Guia completo de configuração
├── firmware/
│   ├── autoexec.be     # Script Berry principal (carregar no Tasmota)
│   └── tasmota/
│       ├── tasmota_template.json  # Template de GPIOs para Tasmota
│       └── backlog_config.txt     # Comandos de configuração via console
└── hardware/
    └── pinout.md       # Tabela de pinos ESP32 ↔ periféricos
```

## Início rápido

1. **Grave o firmware Tasmota** no ESP32 — veja [`docs/setup.md`](docs/setup.md).
2. **Conecte os componentes** conforme [`hardware/pinout.md`](hardware/pinout.md).
3. **Configure os GPIOs e drivers** via console Tasmota com os comandos em [`firmware/tasmota/backlog_config.txt`](firmware/tasmota/backlog_config.txt).
4. **Carregue o script Berry** copiando [`firmware/autoexec.be`](firmware/autoexec.be) via Tasmota File Manager (`Tools → Manage File System`).
5. **Reinicie** o dispositivo. O display acende ~21 s após o boot.

## Layout do display

```
28/04/2025        ← data (DS3231)
14:30             ← hora (DS3231)

CO2:512 ppm       ← leitura SCD41

T:22.5C H:45%     ← temperatura e umidade

192.168.1.42      ← IP Wi-Fi
```

Linha em branco entre grupos = página vazia no SSD1306 (fonte 5×7, 6 px por coluna).

## Log CSV

O arquivo é criado no cartão SD com nome baseado na data e hora do boot:

```
/sd/co2_20250428_1430.csv
```

Cabeçalho e formato:

```csv
datetime,co2,temperature,humidity
28/04/2025 14:30:00,512,22.5,45
28/04/2025 14:30:10,515,22.5,45
```

Gravação a cada **10 segundos**. Cada reinicialização cria um novo arquivo.

## Calibração do SCD41

Para calibração forçada pelo ar exterior (~420 ppm), execute no console Tasmota:

```
Br calibrar_scd41(420)
```

A função interrompe a medição, aguarda 3 s, aplica a calibração forçada (Forced Recalibration — FRC) e retoma automaticamente.

## Dependências de firmware

- [Tasmota 15.3.0.4](https://github.com/arendst/Tasmota) — build `tasmota32.bin`
- Nenhuma biblioteca externa — tudo incluso no Tasmota

## Licença

MIT — veja [`LICENSE`](LICENSE).

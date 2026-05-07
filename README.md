# CO2 Sensor — ESP32 + Tasmota

Monitor de qualidade do ar com ESP32, sensor SCD41, display OLED, RTC e log em cartão SD. O firmware é o Tasmota com script Berry (`autoexec.be`) que controla o display, sincroniza o tempo via DS3231 e grava logs CSV no cartão SD.

## Funcionalidades

- Leitura de CO2 (ppm), temperatura (°C) e umidade relativa (%) via SCD41
- Display OLED SSD1306 128×64 com indicador de qualidade do ar em português
- Relógio em tempo real DS3231 — sem depender de NTP na rede local
- Log CSV no cartão SD com timestamp ISO 8601, gravado a cada 60 s
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
│   ├── berry/
│   │   └── autoexec.be # Script Berry principal
│   └── tasmota/
│       ├── tasmota_template.json  # Template de GPIOs para Tasmota
│       └── backlog_config.txt     # Comandos de configuração via console
└── hardware/
    └── pinout.md       # Tabela de pinos ESP32 ↔ periféricos
```

## Início rápido

1. **Grave o firmware Tasmota** no ESP32 — veja [`docs/setup.md`](docs/setup.md).
2. **Conecte os componentes** conforme [`hardware/pinout.md`](hardware/pinout.md).
3. **Configure os GPIOs** via console Tasmota com os comandos em [`firmware/tasmota/backlog_config.txt`](firmware/tasmota/backlog_config.txt).
4. **Carregue o script Berry** copiando [`firmware/berry/autoexec.be`](firmware/berry/autoexec.be) via Tasmota File Manager (interface web → `Consola → Gerenciador de Arquivos`).
5. **Reinicie** o dispositivo. O display deve exibir as leituras em ~10 s.

## Qualidade do ar — classificação

| CO₂ (ppm) | Classificação |
|---|---|
| < 600 | Excelente |
| 600–799 | Bom |
| 800–999 | Moderado |
| 1000–1499 | Ruim |
| ≥ 1500 | Perigoso |

## Log CSV

O arquivo `/sd/co2_log.csv` é criado automaticamente no cartão SD:

```csv
datetime,co2_ppm,temperature_c,humidity_pct
2025-01-15T14:30:00,512,22.50,45.00
2025-01-15T14:31:00,518,22.48,44.90
```

## Dependências de firmware

- [Tasmota v14+](https://github.com/arendst/Tasmota) — build `tasmota32.bin` ou compilação customizada com os drivers listados em `docs/setup.md`
- Nenhuma biblioteca externa — tudo incluso no Tasmota

## Licença

MIT — veja [`LICENSE`](LICENSE).

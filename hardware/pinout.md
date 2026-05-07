# Pinagem — ESP32 DevKit-C V4 × Periféricos

## Barramento I2C (GPIO 21 / 22)

Todos os três dispositivos compartilham o **mesmo barramento I2C**. Os resistores de pull-up (4,7 kΩ para 3,3 V) devem estar presentes — muitos módulos breakout já os incluem.

| Sinal I2C | GPIO ESP32 | SCD41 | SSD1306 | DS3231 |
|---|---|---|---|---|
| SDA | **GPIO 21** | SDA | SDA | SDA |
| SCL | **GPIO 22** | SCL | SCL | SCL |
| VCC | 3,3 V | VDD | VCC | VCC |
| GND | GND | GND | GND | GND |

Endereços I2C padrão:

| Dispositivo | Endereço (hex) | Endereço (decimal) |
|---|---|---|
| SCD41 | 0x62 | 98 |
| SSD1306 | 0x3C | 60 |
| DS3231 | 0x68 | 104 |

> Para confirmar os endereços no Tasmota: `I2CScan` no console.

## SPI — Módulo MicroSD (GPIO 5/18/19/23)

| Sinal SPI | GPIO ESP32 | Módulo SD |
|---|---|---|
| MOSI | **GPIO 23** | MOSI / DI |
| MISO | **GPIO 19** | MISO / DO |
| CLK | **GPIO 18** | SCK / CLK |
| CS | **GPIO 5** | CS / SS |
| VCC | 3,3 V | VCC |
| GND | GND | GND |

> Use módulos SD com nível lógico 3,3 V ou que incluam divisor de tensão. O ESP32 **não tolera** 5 V nos pinos de I/O.

## Diagrama de conexão simplificado

```
ESP32 DevKit-C V4
┌─────────────────────────────────────────────┐
│                                             │
│  3V3 ──┬─── VCC (SCD41)                    │
│        ├─── VCC (SSD1306)                  │
│        ├─── VCC (DS3231)                   │
│        └─── VCC (SD Module)                │
│                                             │
│  GND ──┬─── GND (SCD41)                   │
│        ├─── GND (SSD1306)                  │
│        ├─── GND (DS3231)                   │
│        └─── GND (SD Module)                │
│                                             │
│  GPIO21 (SDA) ──┬─── SDA (SCD41)          │
│                 ├─── SDA (SSD1306)         │
│                 └─── SDA (DS3231)          │
│                                             │
│  GPIO22 (SCL) ──┬─── SCL (SCD41)          │
│                 ├─── SCL (SSD1306)         │
│                 └─── SCL (DS3231)          │
│                                             │
│  GPIO23 (MOSI) ─── DI  (SD Module)        │
│  GPIO19 (MISO) ─── DO  (SD Module)        │
│  GPIO18 (CLK)  ─── SCK (SD Module)        │
│  GPIO5  (CS)   ─── CS  (SD Module)        │
│                                             │
└─────────────────────────────────────────────┘
```

## Recomendações de montagem

- Mantenha os fios I2C com **menos de 20 cm** para evitar problemas de integridade de sinal.
- O SCD41 precisa de **circulação de ar** — não enclausure hermeticamente.
- Coloque o DS3231 **longe de fontes de calor** para manter a precisão do RTC.
- Um capacitor de 100 nF entre VCC e GND próximo a cada módulo reduz ruído na alimentação.

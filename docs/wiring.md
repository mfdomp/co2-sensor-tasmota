# Diagrama de Fiação

## Visão geral

```
                    ┌──────────────┐
                    │   ESP32      │
                    │  DevKit-C V4 │
         ┌──────────┤ GPIO21 (SDA) │
         │          │ GPIO22 (SCL) │────────────┐
         │          │              │            │
         │    ┌─────┤ GPIO23 MOSI  │            │
         │    │ ┌───┤ GPIO19 MISO  │            │
         │    │ │ ┌─┤ GPIO18 CLK   │            │
         │    │ │ │ ┤ GPIO5  CS    │            │
         │    │ │ │ │              │            │
         │    │ │ │ │ 3V3 ─────────┼─── VCC     │
         │    │ │ │ │ GND ─────────┼─── GND     │
         │    │ │ │ └──────────────┘            │
         │    │ │ │                             │
         │    │ │ │    MicroSD Module           │
         │    │ │ │  ┌──────────────┐           │
         │    └─┼─┼──┤ MOSI         │           │
         │      └─┼──┤ MISO         │           │
         │        └──┤ SCK          │           │
         │           ┤ CS           │           │
         │           │ VCC ── 3V3   │           │
         │           │ GND ── GND   │           │
         │           └──────────────┘           │
         │                                      │
         │  I2C Bus (SDA/SCL)                   │
         │  ┌──────────────┐                    │
         └──┤ SDA  SCD41   │                    │
            ┤ SCL          │────────────────────┤
            │ VDD ── 3V3   │                    │
            │ GND ── GND   │                    │
            └──────────────┘                    │
                                                │
            ┌──────────────┐                    │
            ┤ SDA SSD1306  │────────────────────┤
            ┤ SCL (OLED)   │────────────────────┤
            │ VCC ── 3V3   │                    │
            │ GND ── GND   │                    │
            └──────────────┘                    │
                                                │
            ┌──────────────┐                    │
            ┤ SDA  DS3231  │────────────────────┘
            ┤ SCL  (RTC)   │────────────────────
            │ VCC ── 3V3   │
            │ GND ── GND   │
            └──────────────┘
```

## Pull-ups I2C

Se os módulos não incluírem resistores de pull-up internos, adicione 4,7 kΩ entre:
- SDA (GPIO21) → 3,3 V
- SCL (GPIO22) → 3,3 V

A maioria dos breakouts para SSD1306 e DS3231 já inclui pull-ups. O breakout do SCD41 geralmente **não** inclui — adicione nesse caso.

## Alimentação

```
Fonte USB 5V
     │
     └── ESP32 (USB / VIN)
              │
              └── Regulador interno 3,3 V
                         │
                         ├── SCD41
                         ├── SSD1306
                         ├── DS3231
                         └── Módulo SD
```

**Corrente máxima do regulador onboard do DevKit-C:** ~600 mA (AMS1117-3.3). Com todos os periféricos ativos + Wi-Fi, fique abaixo de 500 mA para margem de segurança.

## Verificação de fiação

Após montar, use o console Tasmota para verificar:

```
I2CScan
```

Saída esperada:
```
I2C Driver List: 
I2C Device found at address 0x3C   (SSD1306)
I2C Device found at address 0x62   (SCD41)
I2C Device found at address 0x68   (DS3231)
```

Se algum dispositivo não aparecer, verifique:
1. Conexões SDA/SCL no módulo correto
2. Alimentação 3,3 V no módulo
3. Pull-ups presentes no barramento

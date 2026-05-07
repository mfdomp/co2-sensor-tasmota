# Bill of Materials (BOM)

Revisão: 1.0 — 2025

## Componentes principais

| # | Componente | Fabricante | Part Number | Qtd | Notas |
|---|---|---|---|---|---|
| 1 | Módulo ESP32-DevKit-C V4 | Espressif / genérico | ESP32-D0WD-V3 | 1 | 38 pinos, USB-C preferível |
| 2 | Sensor CO2 SCD41 | Sensirion | SCD41 (breakout) | 1 | I2C 0x62; alimentação 3,3 V |
| 3 | Display OLED 0,96″ 128×64 | SSD1306 | genérico | 1 | I2C 0x3C; tensão 3,3 V ou 5 V |
| 4 | Módulo RTC DS3231 | Maxim / genérico | DS3231 (breakout) | 1 | I2C 0x68; inclui bateria CR2032 |
| 5 | Módulo MicroSD SPI | genérico | — | 1 | Nível lógico 3,3 V |

## Componentes passivos e auxiliares

| # | Componente | Valor | Qtd | Notas |
|---|---|---|---|---|
| 6 | Resistor pull-up I2C | 4,7 kΩ 1/4 W | 2 | SDA e SCL; omitir se os módulos já têm pull-up integrado |
| 7 | Capacitor de desacoplamento | 100 nF cerâmico | 4 | Um por módulo, próximo ao VCC |
| 8 | Capacitor bulk | 10 µF eletrolítico | 1 | Na alimentação 3,3 V |
| 9 | Bateria CR2032 | — | 1 | Para o DS3231 |

## Alimentação

| # | Item | Especificação | Qtd | Notas |
|---|---|---|---|---|
| 10 | Fonte USB 5 V | ≥ 1 A | 1 | O ESP32 consome ~240 mA em pico de TX Wi-Fi |
| 11 | Cabo USB (gravação/energia) | USB-A → USB-C ou Micro-USB | 1 | Conforme o conector do módulo |
| 12 | Regulador 3,3 V (opcional) | AMS1117-3.3 | 1 | Somente se a placa DevKit não tiver regulador interno |

## Fixação e enclosure

| # | Item | Qtd | Notas |
|---|---|---|---|
| 13 | Protoboard / PCB perfurada | 1 | Para prototipagem |
| 14 | Jumpers Macho-Macho 20 cm | 20 | Para prototipagem |
| 15 | Caixa plástica ≥ 80×60×30 mm | 1 | Furar para saídas de ar no SCD41 |
| 16 | Parafuso M3 × 6 mm | 4 | Fixação da placa na caixa |

## Consumo estimado

| Componente | Corrente típica (3,3 V) |
|---|---|
| ESP32 (Wi-Fi ativo) | 160–240 mA |
| SCD41 | 15 mA (medição) / 0,4 mA (espera) |
| SSD1306 | 10–20 mA |
| DS3231 | < 1 mA |
| Módulo SD (leitura/escrita) | 50–100 mA |
| **Total estimado** | **~250–380 mA @ 3,3 V** |

## Custo estimado (2025, mercado brasileiro)

| Componente | Preço aproximado (R$) |
|---|---|
| ESP32-DevKit-C V4 | R$ 30–50 |
| SCD41 (breakout) | R$ 200–280 |
| SSD1306 OLED 0,96″ | R$ 15–25 |
| DS3231 (módulo com bateria) | R$ 15–25 |
| Módulo MicroSD | R$ 8–15 |
| Componentes passivos | R$ 5–10 |
| MicroSD card 8–32 GB | R$ 15–30 |
| **Total estimado** | **R$ 288–435** |

> O SCD41 é o componente mais caro (~60–65% do custo total). Uma alternativa econômica é o MH-Z19C (~R$ 80), porém com menor precisão e sem medição de umidade.

## Onde comprar

- [Filipeflop](https://www.filipeflop.com)
- [Makerstore](https://www.makerstore.com.br)
- [AliExpress](https://www.aliexpress.com) — SCD41 breakout da Sensirion
- [Mouser Brasil](https://br.mouser.com) — SCD41 original Sensirion

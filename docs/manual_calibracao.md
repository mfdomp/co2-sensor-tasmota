# Sensor CO₂ — Manual de Calibração Rápida

**SCD41 · Tasmota 15.3.0.4 · Berry Script**  
[github.com/mfdomp/co2-sensor-tasmota](https://github.com/mfdomp/co2-sensor-tasmota)

---

> ⚠️ **Atenção:** A calibração forçada substitui a referência interna do sensor.  
> Realize somente em ambiente com concentração de CO₂ **conhecida e estável**.  
> Aguarde **3 minutos** de estabilização antes de executar.

---

## Passo 1 — Conectar ao Sensor

Ligue o sensor e conecte ao WiFi **Sensor-XXXXXX** (os 6 últimos dígitos são o MAC Address do dispositivo).

Abra o navegador e acesse:

```
http://192.168.4.1
```

A página inicial exibe as leituras em tempo real do SCD41 (CO₂ em ppm, temperatura e umidade).

> 💡 Confirme que o sensor está operando e exibindo valores antes de iniciar a calibração.

---

## Passo 2 — Abrir o Berry Scripting Console

Na página inicial, clique em **Tools** e em seguida em **Berry Scripting Console**.

---

## Passo 3 — Estabilizar o Sensor

Coloque o sensor no ambiente de referência e aguarde **no mínimo 3 minutos** para estabilização térmica e química completa.

| Referência | Concentração típica |
|---|---|
| Ar externo (outdoor) | ~420 ppm |
| Ambiente controlado | Valor do equipamento de referência |
| Câmara de calibração | Valor injetado na câmara |

---

## Passo 4 — Executar a Calibração

No Berry Scripting Console, digite o comando abaixo substituindo o valor pelo ppm real do seu ambiente, e pressione **Run code**:

```berry
calibrar_scd41(420)
```

> ✅ Após alguns segundos aparecerá a mensagem de confirmação:  
> **`Calibracao enviada: 420 ppm`**

> 💡 A calibração é gravada na EEPROM interna do SCD41 e persiste mesmo após desligar o sensor.

---

## Passo 5 — Verificar o Resultado

Volte à página inicial (`http://192.168.4.1`) e verifique se o valor de **Carbon Dioxide** está próximo ao valor de referência utilizado.

Aguarde 1–2 ciclos de medição (cada ciclo dura ~5 segundos) para confirmar a estabilização.

> ⚠️ **Se o valor ainda estiver muito diferente do esperado:** Aguarde mais 3 minutos e repita o procedimento a partir do Passo 3.

---

## Referência de Comandos

### Calibração

| Comando | Descrição |
|---|---|
| `calibrar_scd41(420)` | Calibrar usando ar externo como referência (~420 ppm) |
| `calibrar_scd41(N)` | Calibrar usando `N` ppm como valor de referência |

### Log e Intervalo de Amostragem

| Comando | Descrição |
|---|---|
| `LOG_INTERVAL=60` | Alterar intervalo de gravação no SD para 60 segundos |
| `LOG_INTERVAL=10` | Restaurar intervalo de gravação para 10 segundos (padrão) |

---

*Sensor CO₂ — Tasmota 15.3.0.4 | SCD41 + ESP32-D0WD-V3*

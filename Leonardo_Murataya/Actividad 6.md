# DETALLES TÉCNICOS Y SISTEMAS

## Nexus Protegido - Sistema Económico Detallado

---

## 1. Sistema de Dinero (Créditos)

### Fuentes de Ingresos en Partida

| Acción | Créditos | Notas |
|--------|----------|-------|
| Enemigo débil eliminado | +5 | Oleadas 1-3 |
| Enemigo normal eliminado | +10 | Oleadas 4-8 |
| Enemigo fuerte eliminado | +20 | Oleadas 8+ |
| Completar oleada | +100 | Bonus por terminar oleada |
| Ganar partida | +500 | Multiplicador por dificultad |
| Bonus eficiencia | 0-200 | Enemies que NO lleguen al núcleo |

**Multiplicadores por Dificultad Ganadora:**
- Fácil: x1 (500 base)
- Medio: x1.5 (750 total)
- Difícil: x2 (1000 total)
- Infierno: x2.5 (1250 total)
- Hardcore: x5 (2500 total + Cristales)

### Ejemplo de Partida Ganada (Dificultad Difícil, 10 Oleadas)

```
Oleada 1: 45 enemigos × 5 Cr = 225 Cr + 100 Cr = 325 Cr
Oleada 2: 50 enemigos × 5 Cr = 250 Cr + 100 Cr = 350 Cr
...
Oleada 10: 180 enemigos × 20 Cr = 3600 Cr + 100 Cr = 3700 Cr
───────────────────────────────────────────────────────
Subtotal oleadas: ~12,000 Cr
Bonus victoria (x2): +1000 Cr
Bonus eficiencia: +150 Cr
───────────────────────────────────────────────────────
TOTAL: ~13,150 Cr por partida ganada (Difícil)
```

### Progresión de Créditos Acumulados

```
HITO 1: 500 Cr
└─ Desbloquea: Tienda básica completa
└─ Disponible: Modo Fácil + Medio

HITO 2: 2,000 Cr
└─ Desbloquea: Torres Avanzadas comienzan
└─ Disponible: Modo Difícil

HITO 3: 5,000 Cr
└─ Desbloquea: 50% torres legendarias
└─ Disponible: Todos modos excepto Hardcore

HITO 4: 15,000 Cr
└─ Desbloquea: Torres Legendarias restantes
└─ Objetivo: Farm hacia Hardcore

HITO 5: 50,000 Cr ⭐
└─ Desbloquea: MODO HARDCORE + Torres de Cristal
└─ Nueva moneda: Cristales Hardcore
```

---

## 2. Torre de Cristal Hardcore

Solo disponible en Modo Hardcore. Se compran con Cristales (moneda exclusiva).

**Cristales por Partida Hardcore Ganada:**
- 1ª victoria Hardcore: 50 Cristales
- Victorias posteriores: 25 Cristales cada una

**Torres de Cristal Únicas (Ejemplos):**

| Torre | Costo | Efecto Especial |
|-------|-------|-----------------|
| Nexo Primordial | 100 Cristales | Daño escalado por oleada actual |
| Entropía | 75 Cristales | Enemigos pierden armadura |
| Replicador | 150 Cristales | Copia daño de otras torres cercanas |
| Anomalía | 200 Cristales | Ralentiza tiempo localmente |
| Ascensión | 250 Cristales | Mejora automáticamente cada oleada |

### Cuánto tarda desbloquear una Torre de Cristal

```
Victrias necesarias = Costo Cristal / 25

Nexo Primordial (100 Cr):
100 / 25 = 4 victorias Hardcore

Anomalía (200 Cr):
200 / 25 = 8 victorias Hardcore

Ascensión (250 Cr):
250 / 25 = 10 victorias Hardcore
```

**Meta-objetivo**: Jugador veterano tarda ~20-30 horas para obtener todas las torres de Cristal.

---

## 3. Sistema de Inventario (5 Máximo)

### Reglas

- Máximo 5 torres por inventario
- Pueden ser múltiples instancias de la misma torre
- Se selecciona ANTES de empezar la partida
- NO se puede cambiar durante la partida
- Se puede guardar como "preset" (ej: setup_infierno, setup_hardcore)

### Ejemplos de Setups Estratégicos

**Setup Ofensivo Puro:**
```
1. Láser
2. Plasma
3. Onda Choque
4. Rayo
5. Antimaterial
→ Máximo daño, vulnerable si no placer bien
```

**Setup Económico:**
```
1. Generador
2. Generador
3. Láser
4. Plasma
5. Congelación
→ Generan dinero rápido, menos daño inicial
```

**Setup Balanceado:**
```
1. Láser
2. Plasma
3. Generador
4. Congelación
5. Rayo
→ Versátil, funciona en múltiples enemigos
```

**Setup Especializado (vs Hordas):**
```
1. Plasma
2. Plasma
3. Onda Choque
4. Congelación
5. Rayo
→ Área de daño masivo
```

---

## 4. Modos de Dificultad - Tabla Comparativa

| Aspecto | Fácil | Medio | Difícil | Infierno | Hardcore |
|---------|-------|-------|---------|----------|-----------|
| **Oleadas** | 5 | 7 | 10 | 15 | 20 |
| **Enemigos/Oleada** | 5-8 | 8-12 | 12-18 | 18-30 | 30-50 |
| **Vida Enemigos** | Base | +25% | +50% | +100% | +150% |
| **Velocidad Enemigos** | x1 | x1 | x1.1 | x1.2 | x1.3 |
| **Créditos Base** | 200 | 350 | 500 | 1000 | 2500 |
| **Tiempo Partida** | 8 min | 12 min | 18 min | 28 min | 40 min |
| **Recomendado Nivel** | Nuevo | Casual | Intermedio | Veterano | Hardcore |

### Multiplicador de Dificultad en Oleadas

```
Oleada 1: x1.0 multiplicador enemigo vida
Oleada 5: x2.0 multiplicador enemigo vida
Oleada 10: x4.0 multiplicador enemigo vida
Oleada 15: x7.0 multiplicador enemigo vida
Oleada 20: x10.0 multiplicador enemigo vida (Hardcore)
```

---

## 5. Ecuación de Ganancia Esperada

Para que el jugador sienta progresión, la ganancia debe ser > costo de nuevas torres.

```
Ganancia Esperada = (Créditos/min) × (Tiempo partida en min)
                  = Objetivo: 500-1000 Cr por partida promedio
```

**Equilibrio Económico:**
- Nuevas torres básicas: 50-80 Cr (1 partida Fácil)
- Nuevas torres avanzadas: 120-300 Cr (1-2 partidas Difícil)
- Nuevas torres legendarias: 500+ Cr (1-2 partidas Infierno)
- Modo Hardcore: 50,000 Cr (50+ partidas Infierno)

Esto mantiene una **curva de progresión satisfactoria sin pay-to-win**.

---

## 6. Torres: Categorías y Características

### Estadísticas Base de Torre

Cada torre tiene:
- **Daño**: Puntos de vida enemigos que elimina por disparo
- **Rango**: Radio de acción en unidades hexagonales
- **Velocidad disparo**: Intervalos entre ataques (segundos)
- **Especial**: Efecto único (quema, congela, área, etc)
- **Coste**: Créditos para comprar
- **Rareza**: Visual/gameplay (común, raro, épico, legendario)

### Balanceo: Triángulo de Fuerzas

```
        DAÑO
         /\
        /  \
       /    \
      /      \
     /        \
  RANGO --- VELOCIDAD

Láser:     Alto daño, alto rango, lenta
Plasma:    Medio daño, medio rango, área
Rayo:      Bajo daño x3 objetivos, bajo rango, rápida
Congelación: Bajo daño, medio rango, ralentiza
Generador:  0 daño, genera dinero, especializada
```

---

## 7. Curve de Dificultad en Oleadas

### Modelo Matemático

```
Vida_enemigo_base = 10 HP
Multiplicador_oleada = 1.0 + (oleada_actual × 0.15)

Oleada 1:  10 × 1.15 = 11.5 HP por enemigo
Oleada 5:  10 × 1.75 = 17.5 HP por enemigo
Oleada 10: 10 × 2.5  = 25 HP por enemigo
Oleada 15: 10 × 3.25 = 32.5 HP por enemigo
Oleada 20: 10 × 4.0  = 40 HP por enemigo (Hardcore)
```

### Tensión Emocional por Oleada

```
OLEADAS 1-3: Verde (Relajado)
└─ Enemigos débiles, setup básico es suficiente
└─ Jugador aprende mecánicas sin presión

OLEADAS 4-7: Amarillo (Alerta)
└─ Dificultad aumenta, primeros desafíos
└─ Jugador debe pensar en posicionamiento

OLEADAS 8-12: Naranja (Crítico)
└─ Enemigos muy fuertes, presión real
└─ Optimización de setup es mandatoria

OLEADAS 13-15: Rojo (Caótico)
└─ Hordas masivas, oleadas dinámicas
└─ Cada segundo cuenta, adrenalina pura

OLEADA 16-20: Negro (Infierno) [Solo Hardcore]
└─ Oleadas especiales con enemigos únicos
└─ Momento de verdad, victoria o derrota total
```

---

## 8. Anti-Grinding Mechanics

Para evitar que el jugador "grindee" indefinidamente:

**Bonificadores Decrecientes:**
- 1ª victoria del día en Fácil: +50% créditos
- 2ª victoria del día: +25% créditos
- 3ª+ victorias: Créditos normales

**Esto incentiva:** Jugar múltiples modos en lugar de repetir uno.

**Misiones Diarias Opcionales:**
- "Gana 3 partidas en modo Difícil": +200 Cr extra
- "Desbloquea 1 nueva torre": +150 Cr extra
- "Lleva solo torres básicas y gana": +100 Cr extra

---

## 9. Roadmap de Desbloques por Créditos

```
0 Cr
├─ Torres: Láser, Plasma
├─ Modos: Fácil
└─ Tienda: Visible (parcial)

500 Cr ✓
├─ Torres: + Congelación
├─ Modos: Medio
└─ Tienda: Completa (básicas)

2,000 Cr ✓
├─ Torres: + Generador, Onda Choque, Rayo
├─ Modos: Difícil
└─ Indicador: "50% camino a Hardcore"

5,000 Cr ✓
├─ Torres: + Antimaterial (50% precio)
├─ Modos: Infierno
└─ Indicador: "Acceso completo torres avanzadas"

15,000 Cr ✓
├─ Torres: + Singularidad, Teletransporte
├─ Modos: Todos excepto Hardcore
└─ Indicador: "Falta 35,000 Cr para Hardcore"

50,000 Cr ✅ HITO FINAL
├─ Modo: HARDCORE DESBLOQUEADO
├─ Moneda: Cristales Hardcore activada
├─ Torres: Torres de Cristal disponibles
└─ Indicador: "Bienvenido al end-game"
```

---

## 10. Conclusión Técnica

El sistema económico está diseñado para:

✓ Crear loops de mejora continua (ganar dinero → comprar torres → mejorar estrategia)
✓ Mantener presión de progreso sin ser abrumador
✓ Proporcionar objetivos claros (próxima torre, próximo modo, Hardcore)
✓ Permitir infinita replayabilidad mediante combinaciones de 5 torres
✓ Diferenciar a jugadores dedicados (modo Hardcore) con moneda exclusiva
✓ Evitar pay-to-win: todo es ganablable sin dinero real

**Resultado**: Juego con profundidad económica que mantiene al jugador motivado a través de 100+ horas de gameplay.

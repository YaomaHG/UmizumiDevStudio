# SUPONGAMOS QUE MAÑANA

**Género:** Simulación doméstica + terror psicológico  
**Plataforma objetivo (prototipo):** PC (teclado y mouse)  
**Sesiones objetivo:** 15–20 min por día in game  
**Versión:** 1.1 (Marzo 2026)  

**Autores:**  
Ana Torres  
Leonardo Mancilla  
Salvador Garibay  
Omar Hernández  
Leonardo Murataya  

---

# 1. High Concept

## Pitch (1 frase)
Un juego de gestión del tiempo y recursos donde encarnas a un ama de casa que, bajo una relación coercitiva, debe mantener el hogar impecable antes de las 19:00 mientras reúne en secreto $500 y una llave para escapar; cada minuto cuenta y cada decisión puede delatar tu plan.

## Foco emocional

- **Tensión constante:** el reloj global y los límites por tarea presionan.
- **Esperanza frágil:** cada billete escondido abre una ruta de salida.
- **Vigilancia ambigua:** el entorno “juzga” mediante estados y penalizaciones.

## Fantasía del jugador
Ser capaz de optimizar un día imposible: aparentar normalidad y, en paralelo, avanzar en un plan clandestino.

## Pilares de diseño

1. Tiempo como enemigo (macro a las 19:00 y micro por tarea).
2. Visibilidad y sospecha (feedback de paciencia y eventos).
3. Elecciones significativas (priorizar, arriesgar, esconder).
4. Psicológico por encima de lo gráfico (sonido, texto, UI).

**Frase clave:**  
Cada minuto cuenta. Cada decisión te acerca a la libertad… o a ser descubierta.

---

# 2. Fantasía, Experiencia Central y Público

## Experiencia central buscada

- Presión temporal progresiva (verde → amarillo → rojo en reloj global y por tarea).
- Trade offs claros: ¿cocinar bien y seguro, o arriesgar minijuego para ahorrar segundos?
- Latencia del peligro: la paciencia del marido es el equivalente a una “barra de amenaza”.

## Perfil de jugador objetivo

- **Explorador narrativo:** aprecia pistas, detalles ambientales y ambigüedad.
- **Triunfador táctico:** optimiza rutas, lee patrones, minimiza riesgo.
- **Nivel:** intermedio (loop claro, ejecución con margen de error).

**Sesión tipo:**  
15–20 min (un día in game). Ciclo de 14–15 días como campaña corta.

---

# 3. Core Loop + Estado de Juego

## Loop diario (micro)

1. **Despertar (Estado: Planificación)**  
   Revisar lista de tareas del día, tiempos límite por tarea, reloj global, ubicación de pistas.

2. **Ejecución (Estado: Acción)**  
   Realizar tareas (cocinar, limpiar, lavar ropa en días definidos), participar en minijuegos si aplica, esconder dinero.

3. **Cierre (Estado: Evaluación)**  
   A las 19:00 llega el marido; el sistema evalúa % de tareas completadas y dinero oculto.

4. **Transición (Estado: Progresión)**  
   Ajustar dificultad, guardar día y pasar al siguiente.

---

## Loop de progresión (macro)

- **Días 1–3:** Aprendizaje
- **Días 4–7:** Descubrimiento
- **Días 8–11:** Manipulación
- **Días 12–13:** Desesperación
- **Días 14–15:** Clímax

---

## Cambio de estado definido

### Estado PLANIFICACIÓN
UI de lista + cronómetro global pausado.

**Trigger:** pulsar *Comenzar Día*

### Estado ACCIÓN
Tiempo activo, tareas con temporizador individual.

**Triggers internos:**

- Completar tarea → ajusta paciencia y reloj
- Fallar tarea → penalización o tareas extra
- Evento de ruido sospechoso → chequeo de sospecha

### Estado EVALUACIÓN (19:00)

- Se congelan acciones
- Se calcula cumplimiento
- Se aplican consecuencias

**Trigger:** hora ≥ 19:00

### Estado PROGRESIÓN

Guardar progreso y aplicar cambios al siguiente día.

**Trigger:** continuar

---

# 4. Mecánicas y Sistemas

## Reloj Global (8:00–19:00)

Indicadores:

- 🟢 Verde → seguro
- 🟡 Amarillo → riesgo
- 🔴 Rojo → crítico

La UI reacciona con parpadeos y audio sutil.

---

## Sistema de tiempos por tarea

Si se excede el tiempo límite:

- Se pierde la tarea
- Disminuye paciencia
- Se pierden bonos

### Ejemplos

| Tarea | Tiempo | Penalización |
|------|------|------|
| Cocinar | 3–5 min | Paciencia mínima |
| Limpiar sala | 2–4 min | -15% paciencia |
| Lavar ropa | 5 min | Sin propina |
| Limpiar habitación | 3 min | +1 tarea siguiente día |

---

## Sistema de tareas

### Obligatorias

- Cocinar
- Limpiar cocina
- Limpiar sala
- Limpiar habitación
- Lavar ropa (algunos días)

### Opcionales

- Ordenar armario
- Limpiar ventanas

---

## Minijuegos (si se implementan)

- **Cocinar:** precisión
- **Lavar ropa:** ritmo
- **Esconder dinero:** memoria
- **Limpiar habitación:** organización rápida

---

## Medidor de paciencia

| Estado | Requisito | Resultado |
|------|------|------|
| Contento | 80–100% | $20 propina |
| Neutral | 50–79% | Sin propina |
| Enojado | <50% | +1 tarea siguiente día |

Si la comida no está lista a las 19:00 → paciencia mínima automática.

---

## Sistema de dinero

**Fuente:** propina $20

**Almacenamiento:** escondites (ej. colchón)

**Meta:** $500

---

## Sistema de escape

**Victoria**

- $500
- Llave encontrada

**Derrota**

- Ser descubierto
- Paciencia mínima repetida

---

# 5. Contenido, Mundo y Interfaz

## Espacios (MVP)

- **Cocina:** centro del gameplay
- **Sala:** tránsito y vigilancia
- **Habitación:** esconder dinero

---

## Tema y conflicto

La memoria como trampa.  
Recuerdos bonitos y contradictorios alimentan la duda.

---

## Interfaz conceptual

**HUD**

- reloj global
- lista de tareas
- medidor de paciencia

**Feedback**

- “+$20 escondidos”
- “Ropa manchada”

**Transiciones**

- corte a negro al final del día
- resumen textual

---

# 6. Diseño del MVP

## Objetivo

Validar:

- gestión de tiempo
- tareas con límite
- sistema de paciencia

---

## Ámbito

**Días jugables**

- Día 1
- Día 2
- Día 3

**Espacios**

- Cocina
- Sala
- Habitación

---

## Estructura por día

### Día 1 — Aprendizaje

Tareas:

- Cocinar (5 min)
- Limpiar cocina (3 min)
- Limpiar sala (4 min)

Objetivo: obtener propina.

---

### Día 2 — Consolidación

Tareas:

- Cocinar (4 min)
- Limpiar sala (3 min)
- Limpiar habitación (3 min)
- Lavar ropa (5 min opcional)

Eventos de ruido aparecen.

---

### Día 3 — Stress test

Tareas:

- Cocinar (3–4 min)
- Limpiar cocina (3 min)
- Limpiar sala (3 min)
- Limpiar habitación (3 min)

Evaluación estricta.

---

## Victoria en MVP

- ≥ $40 escondidos
- no caer en paciencia mínima más de 2 veces

## Derrota en MVP

- paciencia mínima 3 veces
- <50% tareas dos días seguidos

---

# 7. Qué NO entra en el MVP

- Minijuegos avanzados
- Sistema de sospecha complejo
- Narrativa no lineal
- Puzles de la llave
- Campaña completa de 15 días
- Audio avanzado
- Arte final

---

# 8. Economía y Balance

## Tiempo global

8:00–19:00  
≈ 12–15 minutos reales por día

---

## Paciencia del marido

Escala **0–100**

| Estado | Rango | Resultado |
|------|------|------|
| Contento | ≥80 | $20 |
| Neutral | 50–79 | $0 |
| Enojado | <50 | +1 tarea |

---

## Dinero

Ingreso máximo diario: **$20**

Meta MVP: **$40**

Escondites simples:

- colchón
- mesita

---

## Curva de dificultad

| Día | Dificultad |
|----|----|
| Día 1 | fácil |
| Día 2 | media |
| Día 3 | alta |

---

# 9. Producción y Riesgos

## Riesgos

### Tema sensible

Control:

- tono responsable
- sistema abstracto en vez de personaje visible

### Repetición del gameplay

Control:

- tareas extra
- eventos de ruido
- variaciones de tiempo

### Balance

Control:

- ajustes de tiempo ±10–20%

### UI saturada

Control:

- iconos simples
- capas de información progresivas

---

## Hitos de desarrollo (MVP)

**Semana 1**

- loop básico
- reloj
- evaluación 19:00

**Semana 2**

- paciencia
- propina
- UI básica

**Semana 3**

- esconder dinero
- eventos de ruido

**Semana 4**

- pulido
- tutorial
- QA

**Semana 5–6 (opcional)**

- telemetría
- SFX básicos

---

# 10. Cierre

## Definición de “Listo” (MVP)

Debe incluir:

1. Estados completos del juego
2. Reloj global
3. Sistema de tareas
4. Paciencia funcional
5. Economía de dinero
6. UI clara

---

## KPIs de validación

- ≥70% jugadores completan Día 3
- ≥60% reportan tensión narrativa
- duración media del día: **12–15 min**

---

## Roadmap post MVP

1. Minijuegos completos
2. Sistema de sospecha
3. Narrativa ramificada
4. Campaña completa (15 días)
5. Arte y audio finales
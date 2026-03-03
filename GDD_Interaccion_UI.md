# SUPONGAMOS QUE MAÑANA
**Documento de Diseño de Interacción y UI**

---

## 1. Concepto de UI y Canales de Información

### Filosofía de diseño
**Minimalismo funcional con tensión implícita**

La interfaz debe ser lo suficientemente clara para no frustrar, pero lo suficientemente discreta para mantener la inmersión. El jugador debe sentir que está en un hogar real, no en un videojuego, pero necesita la información crítica para tomar decisiones informadas.

---

### HUD Principal (Siempre visible)

#### 1. Reloj Digital - Superior Centro
```
╔════════════════╗
║    14:27       ║
╚════════════════╝
```

**Información que comunica:**
- Hora actual en formato 24h
- Tiempo restante hasta las 19:00 (implícito)

**Estados visuales:**
- **08:00-15:00** → Texto blanco sobre fondo oscuro semi-transparente
- **15:00-18:00** → Texto amarillo con pulso sutil cada 30 segundos
- **18:00-18:45** → Texto naranja con pulso cada 15 segundos
- **18:45-19:00** → Texto rojo parpadeante cada 5 segundos

**Justificación:** El cambio gradual de color comunica urgencia sin texto explícito. El jugador aprende a asociar colores con niveles de riesgo.

---

#### 2. Lista de Tareas - Lateral Derecho
```
╔═══════════════════════╗
║ TAREAS DEL DÍA        ║
║ ☐ Cocinar comida      ║
║ ☐ Limpiar cocina      ║
║ ☐ Limpiar sala        ║
║ ☐ Lavar ropa          ║
╚═══════════════════════╝
```

**Información que comunica:**
- Tareas pendientes vs completadas
- Prioridad de tareas (cocinar siempre arriba)
- Carga de trabajo del día

**Estados visuales:**
- ☐ Pendiente → Texto blanco
- ☑ Completada → Texto verde tachado
- ⚠ Crítica (cocinar después de 18:30) → Texto rojo parpadeante

**Interacción:**
- Hover sobre tarea muestra tiempo estimado
- Click no hace nada (solo es informativo)

**Justificación:** Lista tipo "to-do" replica la experiencia real de gestionar múltiples responsabilidades domésticas. Es un elemento diegético (podría ser una lista física en el mundo).

---

#### 3. Indicador de Dinero - Superior Izquierdo
```
╔═══════════════════╗
║ Dinero: $85       ║
╚═══════════════════╝
```

**Información que comunica:**
- Dinero disponible para compras
- NO muestra dinero escondido (esto es intencional)

**Estado visual:**
- Texto blanco simple
- Parpadeo verde breve al recibir propina

**Justificación:** El dinero escondido debe sentirse secreto. Mostrarlo constantemente reduce la tensión de la ocultación. Solo se revela al interactuar con el escondite.

---

### HUD Contextual (Aparece bajo condiciones específicas)

#### 4. Dinero Escondido - Solo visible al interactuar con el colchón
```
╔═══════════════════════════╗
║ Dinero escondido: $240    ║
║ Meta: $500                ║
║ [═══════════░░░] 48%      ║
╚═══════════════════════════╝
```

**Información que comunica:**
- Progreso hacia la meta de escape
- Cuánto falta para la libertad

**Interacción:**
- Solo aparece durante 3 segundos al mirar debajo del colchón
- Efecto de fade-in/fade-out
- Sonido sutil (papel arrugado)

**Justificación:** El acto de revisar tu progreso debe ser deliberado y arriesgado. No debe ser algo que puedas monitorear constantemente sin consecuencia.

---

#### 5. Evaluación del Día - Pantalla completa al final del día
```
╔═══════════════════════════════════════╗
║                                       ║
║           FIN DEL DÍA 5               ║
║                                       ║
║   Tareas completadas: 3/4 (75%)       ║
║                                       ║
║   [═════════════░░░░]                 ║
║                                       ║
║   Estado: NEUTRAL                     ║
║                                       ║
║   "Todo estuvo aceptable."            ║
║                                       ║
║   [Continuar al siguiente día]        ║
║                                       ║
╚═══════════════════════════════════════╝
```

**Estados posibles:**

| Estado | Visual | Texto del marido | Consecuencia |
|--------|--------|------------------|--------------|
| **CONTENTO** | Barra verde | "Buen trabajo hoy." | +$20 al dinero visible |
| **NEUTRAL** | Barra amarilla | "Todo estuvo aceptable." | Sin cambios |
| **ENOJADO** | Barra roja | "Esto no puede volver a pasar." | Tarea extra mañana |

**Justificación:** Este momento es el único feedback explícito del estado del marido. El jugador necesita saber cómo le fue, pero la revelación se retrasa hasta el final para mantener la incertidumbre.

---

#### 6. Notas del Entorno - In-world
```
[Icono de papel flotante sobre mesa/pared]
```

**Información que comunica:**
- Hay una nota disponible para leer
- Nueva información narrativa

**Interacción:**
- Hover: Icono crece ligeramente
- Click: Abre nota en pantalla modal semi-transparente
- Al leer: Icono cambia de color (ya leída)

**Apariencia de la nota:**
```
╔════════════════════════════════════════╗
║                                        ║
║  [Letra cursiva manuscrita]            ║
║                                        ║
║  "No olvides comprar cebollas          ║
║   para la receta de hoy."              ║
║                                        ║
║  - Tu esposo                           ║
║                                        ║
║  [Cerrar - Presiona ESC o Click]       ║
╚════════════════════════════════════════╝
```

**Tipos visuales según contenido:**
- **Funcional** → Papel blanco, letra negra
- **Bonita** → Papel amarillo, letra más delicada
- **Contradictoria** → Papel blanco con borde rojo
- **Manipuladora** → Papel gris, letra irregular

**Justificación:** Las notas deben sentirse como objetos del mundo, no como pop-ups de juego. El estilo visual diferenciado ayuda al jugador a categorizar información sin hacerlo explícito.

---

### Canales de Feedback

#### Audio
- **Reloj:** Tic-tac sutil que aumenta de volumen después de las 18:00
- **Tareas completadas:** Sonido satisfactorio (checkbox marcado)
- **Esconder dinero:** Sonido de papel deslizándose
- **Puerta de entrada:** Sonido de llave girando a las 19:00 (trigger de ansiedad)
- **Pasos:** Pasos del jugador cambian de ritmo según el tiempo restante

#### Visual
- **Viñeta sutil:** Los bordes de la pantalla se oscurecen ligeramente después de las 18:30
- **Partículas de polvo:** Visible en áreas sucias, desaparece al limpiar
- **Iluminación:** La luz de las ventanas cambia según la hora (más oscura = más tarde)

#### Kinestésico (si hay vibración)
- **Reloj crítico:** Vibración breve a las 18:45
- **Llegada del marido:** Vibración fuerte a las 19:00

**Justificación:** Múltiples canales de feedback refuerzan la misma información sin ser redundantes. Jugadores que ignoren el reloj visual recibirán señales auditivas.

---

## 2. Loop Principal de Interacción

### Estructura del loop diario (15-20 minutos de juego)

```
INICIO DEL DÍA (08:00)
    ↓
[FASE 1: PLANIFICACIÓN] (1-2 minutos)
    → Revisar lista de tareas
    → Evaluar tiempo disponible  
    → Decidir estrategia
    ↓
[FASE 2: EJECUCIÓN] (10-15 minutos)
    → Ciclo repetitivo:
       ├─ Navegar a habitación
       ├─ Interactuar con objeto/tarea
       ├─ Ver animación de tarea (con opción de skip)
       ├─ Verificar reloj
       ├─ Ajustar prioridades
       └─ Repetir
    
    → Decisiones intercaladas:
       ├─ ¿Leo esta nota? (pausa mental, no pausa de tiempo)
       ├─ ¿Escondo dinero ahora?
       └─ ¿Cambio de estrategia?
    ↓
[FASE 3: URGENCIA] (2-3 minutos finales)
    → Reloj en 18:00+
    → Priorización desesperada
    → Sacrificar tareas secundarias
    → Asegurar que la comida esté lista
    ↓
[FASE 4: LLEGADA] (19:00 exacto)
    → Fade a negro
    → Sonido de puerta abriéndose
    → Evaluación del día
    ↓
[FASE 5: RESULTADO] (30 segundos)
    → Pantalla de evaluación
    → Recibir propina o penalización
    → Opción de revisar escondite
    → Botón: Continuar al día siguiente
    ↓
NUEVO DÍA
```

---

### Desglose de interacciones por fase

#### FASE 1: PLANIFICACIÓN
**Interacción:**
1. Jugador despierta en la habitación
2. Pantalla muestra: "DÍA 5 - 08:00"
3. Lista de tareas aparece con fade-in
4. Jugador puede:
   - Caminar libremente
   - Leer notas
   - Revisar escondite (si quiere)

**Información disponible:**
- Lista de tareas actualizada
- Reloj en 08:00
- Dinero visible actual
- (Opcional) Dinero escondido si revisa colchón

**Sin información:**
- Estado del marido (no se conoce hasta el final)
- Si habrá tareas extra hoy

---

#### FASE 2: EJECUCIÓN
**Interacción principal: Realizar tareas**

Ejemplo: Cocinar
1. Jugador va a la cocina
2. Interactúa con la estufa (Click o E)
3. Animación/pantalla de cocinar (5 segundos) con opción [Skip]
4. Tiempo avanza (variable según tarea)
5. Tarea marcada como completa ☑
6. Sonido de confirmación

**Tiempos de tareas:**
- Cocinar: 120 minutos (2 horas de juego = ~2-3 min reales con animación)
- Limpiar cocina: 45 minutos
- Limpiar sala: 45 minutos
- Limpiar habitación: 45 minutos
- Lavar ropa: 60 minutos

**Fórmula de compresión temporal:**
```
1 hora de juego = 1-1.5 minutos de tiempo real
11 horas disponibles = 15-20 minutos de sesión
```

**Interacción secundaria: Esconder dinero**

1. Jugador va a la habitación
2. Interactúa con el colchón
3. Opciones:
   - [Esconder $20] (si tiene dinero disponible)
   - [Revisar escondite] (solo ver cuánto hay)
   - [Cancelar]
4. Si esconde: Tiempo avanza 10 minutos
5. Feedback: "+$20 escondidos" flota en pantalla
6. Dinero visible disminuye

**Interacción terciaria: Leer notas**

1. Jugador ve icono de papel
2. Click abre nota en modal
3. Leer NO consume tiempo de juego
4. PERO el jugador pierde tiempo REAL decidiendo qué hacer con la información
5. Cerrar nota continúa el juego

---

#### FASE 3: URGENCIA (18:00+)
**Cambios en la interacción:**
- Reloj cambia a rojo/naranja
- Música intensifica (si hay)
- Animaciones de tareas NO se pueden skipear (para forzar la sensación de desesperación)
- Jugador tiende a:
  - Abandonar tareas secundarias
  - Priorizar solo cocinar
  - Ignorar notas

**Información crítica visible:**
- Tareas completadas vs pendientes
- Si la comida está lista (⚠ si no)
- Tiempo exacto restante

---

#### FASE 4: LLEGADA (19:00)
**Interacción forzada:**
1. A las 19:00 exactas, el control se bloquea
2. Fade a negro
3. Sonido de puerta + pasos
4. Transición a pantalla de evaluación

**Sin interacción del jugador:** Este momento es puramente narrativo.

---

#### FASE 5: RESULTADO
**Interacción:**
1. Pantalla muestra evaluación
2. Jugador lee resultado
3. Opciones:
   - [Continuar al día siguiente]
   - [Revisar escondite] (opcional)
   - [Menú principal] (pausa)
4. Click en continuar → Siguiente día

**Información adicional:**
- Si recibió propina: Dinero visible aumenta
- Si hay tarea extra: Aparece nota de advertencia
- Contador de días transcurridos

---

### Frecuencia de decisiones

Durante una sesión de 15 minutos:
- **Decisiones triviales:** Cada 30-60 segundos (qué tarea hacer ahora)
- **Decisiones estratégicas:** 3-4 por día (¿escondo dinero? ¿leo esta nota?)
- **Decisiones críticas:** 1 por día (¿sacrifico tareas para maximizar propina?)

**Ratio de interacción:**
- 60% navegación y tareas
- 30% decisiones estratégicas
- 10% lectura narrativa

---

## 3. Dinámicas Reguladas por la UI

### Dinámica 1: Presión Temporal
**Cómo la UI la genera:**
- Reloj visible constantemente
- Cambio de color según urgencia
- Tic-tac audible que acelera
- Viñeta visual cerca del límite

**Regulación:**
- Los colores enseñan al jugador a anticipar riesgo
- No hay cuenta regresiva explícita (más inmersivo)
- El jugador aprende a leer el reloj y planificar

**Resultado esperado:**
El jugador constantemente verifica el reloj y ajusta prioridades. La tensión crece naturalmente sin UI agresiva.

---

### Dinámica 2: Riesgo Calculado (esconder dinero)
**Cómo la UI la genera:**
- Dinero escondido NO está siempre visible
- Revisar escondite requiere ir a la habitación (tiempo)
- Esconder dinero muestra claramente el costo: -$20 visible, -10 min

**Regulación:**
- Pantalla de progreso al revisar escondite recompensa la exploración
- Feedback inmediato al esconder: jugador ve consecuencias
- Decisión siempre explícita (botón [Esconder $20])

**Resultado esperado:**
Jugador evalúa si vale la pena el riesgo según su situación actual. La UI no oculta consecuencias.

---

### Dinámica 3: Esperanza Contenida
**Cómo la UI la genera:**
- Barra de progreso al revisar escondite
- Feedback positivo al esconder dinero (+$20!)
- Meta visible: $500

**Regulación:**
- Progreso mostrado solo cuando el jugador lo busca
- No hay celebración excesiva (mantiene seriedad temática)
- Incrementos pequeños hacen que cada decisión cuente

**Resultado esperado:**
Sentimiento de logro gradual. El jugador celebra internamente cada $20 escondido porque ve su impacto.

---

### Dinámica 4: Duda Estratégica (notas contradictorias)
**Cómo la UI la genera:**
- Notas con bordes/colores diferentes según tipo
- Texto contradictorio sin resolución inmediata
- No hay sistema de quest markers o "verdad confirmada"

**Regulación:**
- El estilo visual diferenciado da pistas sutiles
- Jugador debe recordar información (no hay log de notas leídas, esto es intencional)
- La UI no dice qué es verdad o mentira

**Resultado esperado:**
Jugador forma teorías y debe confiar en su memoria y análisis. La incertidumbre es parte de la experiencia.

---

### Dinámica 5: Optimización Progresiva
**Cómo la UI la genera:**
- Tiempos de tareas consistentes
- Evaluación clara al final: "75% completado"
- Feedback inmediato: ☑ tarea completa

**Regulación:**
- Jugador aprende tiempos exactos con la experiencia
- No hay tutoriales explícitos más allá del Día 1
- El sistema es predecible (permite optimización)

**Resultado esperado:**
Con cada día, el jugador mejora su estrategia. La UI recompensa la maestría sin hacerla trivial.

---

## 4. Principal Riesgo del Diseño

### Riesgo Identificado: **Balance entre Tensión y Frustración**

**Descripción del problema:**
El tiempo real con límite estricto puede cruzar la línea entre "desafiante y tenso" a "frustrante e injusto". Si el jugador siente que NO HAY MANERA de completar las tareas a tiempo, abandonará el juego.

**Por qué es el mayor riesgo:**
1. **Es el pilar central del diseño:** Sin tensión temporal, el juego pierde su identidad
2. **Es subjetivo:** Lo que es desafiante para un jugador es imposible para otro
3. **Afecta directamente la experiencia emocional:** Frustración mata inmersión
4. **Es difícil de ajustar post-lanzamiento:** Cambiar tiempos afecta todo el balance

**Consecuencias si falla:**
- Jugadores abandonan en los primeros días
- Reviews negativas centradas en "injusticia del sistema"
- El mensaje narrativo se pierde por fricción mecánica
- El juego se vuelve un juego de frustración, no de tensión

---

### Tipos de riesgo

**Riesgo de experiencia (principal):**
- ¿El jugador siente presión justa o arbitrariedad?
- ¿La tensión es satisfactoria o solo estresante?
- ¿El jugador tiene sensación de agencia?

**Riesgo técnico (secundario):**
- ¿Los tiempos son consistentes en diferentes máquinas?
- ¿Las animaciones pueden causar que tareas sean más largas de lo diseñado?
- ¿El tiempo pausado para leer notas afecta el balance?

---

### Trade-off Explícito: **Tensión vs Accesibilidad**

#### Opción A: Tiempo real estricto (máxima tensión)
**Diseño:**
- Reloj avanza sin pausas
- No hay forma de recuperar tiempo perdido
- Leer notas consume tiempo mental real del jugador pero no pausa el juego

**Ventajas:**
+ Máxima inmersión
+ Tensión constante y auténtica
+ Replica fielmente la sensación de vivir bajo presión

**Desventajas:**
- Puede ser demasiado frustrante
- Jugadores lentos o distraídos fallarán inevitablemente
- Primera partida casi garantizada a perder

---

#### Opción B: Tiempo pausable (más accesible)
**Diseño:**
- Jugador puede pausar para tomar decisiones estratégicas
- Tiempo pausa automáticamente al leer notas
- Jugador conserva control total

**Ventajas:**
+ Más accesible para todo tipo de jugadores
+ Permite pensar estrategia sin penalización
+ Menos abandono temprano

**Desventajas:**
- Pierde tensión e inmersión
- Se convierte en puzzle en lugar de experiencia visceral
- Ya no replica la sensación de no tener tiempo propio

---

#### Opción C: Híbrido - Tiempo real con "respiros" (RECOMENDADA)
**Diseño:**
- Reloj avanza en tiempo real DURANTE tareas
- Pausa automática al abrir notas (justificación: leer es mental, no física)
- Mecánica de "Nube de Descanso": Item consumible que pausa tiempo 60 segundos, 1 uso por día

**Ventajas:**
+ Mantiene tensión sin ser injusto
+ Jugadores lentos pueden usar "Nube" estratégicamente
+ Leer notas no penaliza (fomenta exploración narrativa)
+ Permite ajuste de dificultad orgánico (buenos jugadores no necesitan Nube)

**Desventajas:**
- Añade complejidad (¿cómo se obtiene la Nube?)
- Puede romper inmersión si se usa mal
- Necesita balanceo adicional

---

### Decisión de diseño: **Opción C - Híbrido**

**Justificación:**
1. **Prioridad narrativa:** El juego debe contar una historia sobre abuso psicológico. Si la frustración mecánica opaca el mensaje, fallamos como diseñadores.
2. **Accesibilidad sin compromiso:** La Nube permite a diferentes tipos de jugadores tener éxito sin trivializar el desafío.
3. **Leer notas es contenido core:** Pausar al leer garantiza que los jugadores exploren la narrativa sin penalización, lo cual es esencial.
4. **Ajuste de dificultad orgánico:** Jugadores hábiles simplemente no usan la Nube. Jugadores novatos la necesitan. Ambos pueden disfrutar.

**Implementación de la Nube:**
- Objeto visual: Nube de papel flotante en la habitación cada mañana
- Interacción: Click para activar
- Efecto: Tiempo pausa por 60 segundos, reloj muestra icono de pausa
- Visual: Pantalla desatura ligeramente mientras está activa
- Restricción: 1 uso por día, no se acumula

---

## 5. Prototipo de Validación

### Objetivo del prototipo
**Validar si el balance de tiempo genera tensión satisfactoria o frustración injusta.**

### Alcance (2-3 días de implementación)

#### Mecánicas funcionales:
- Reloj real de 08:00 a 19:00 (comprimido a 15 minutos reales)
- 3 tareas: Cocinar (120 min), Limpiar cocina (45 min), Limpiar sala (45 min)
- Evaluación al final con estados: Contento/Neutral/Enojado
- Dinero y escondite (sin consecuencias reales aún)
- 1 Nube de Descanso disponible por día

#### UI implementada:
- Reloj visible con cambios de color
- Lista de tareas con checkbox
- Pantalla de evaluación al final
- Botón de Nube de Descanso

#### Espacios:
- Casa simplificada: Cocina - Sala - Habitación (navegación mínima)
- Sin arte final, placeholders visuales

#### Duración del test:
- 3 días de juego (3 sesiones de 15 min = 45 min total)

---

### Métricas de validación

#### Datos cuantitativos:
1. **Tasa de éxito:** ¿Qué % de jugadores logra estado "Contento" en Día 1, 2 y 3?
   - Target: 30% día 1, 60% día 2, 80% día 3 (curva de aprendizaje)
2. **Uso de Nube:** ¿En qué día usan la Nube? ¿Cuántos no la usan?
   - Target: 70% usa Nube día 1, 40% día 2, 20% día 3
3. **Tiempo promedio de completar tareas:** ¿Cuánto tiempo real les toma?
   - Target: 10-15 minutos
4. **Tasa de abandono:** ¿Cuántos abandonan antes de completar 3 días?
   - Target: <20% de abandono

#### Datos cualitativos (encuesta post-test):
1. "En una escala de 1-10, ¿qué tan tenso te sentiste?" → Target: 7-8
2. "¿Sentiste que el sistema era justo o injusto?" → Target: >70% justo
3. "¿Qué fue más estresante: el reloj, las tareas o las decisiones?"
4. "¿Usaste la Nube de Descanso? ¿Por qué sí/no?"
5. "¿Volverías a jugar para mejorar tu estrategia?"

---

### Condiciones de éxito del prototipo

| Métrica | Éxito | Ajuste necesario | Fallo |
|---------|-------|------------------|-------|
| Tasa de éxito Día 3 | >75% | 50-75% | <50% |
| Sensación de tensión | 7-8/10 | 6/10 | <5/10 |
| Percepción de justicia | >70% | 50-70% | <50% |
| Uso de Nube (progresivo) | Decremento claro | Uso constante | No usan nunca |
| Tasa de abandono | <20% | 20-40% | >40% |

---

### Posibles resultados y acciones

#### Resultado 1: Demasiado difícil
**Señales:**
- Tasa de éxito <50% incluso en Día 3
- Uso de Nube 100% todos los días
- Feedback: "imposible", "injusto", "frustrante"

**Acción:**
- Aumentar tiempo disponible (12 horas en lugar de 11)
- Reducir tiempo de cocinar (100 min en lugar de 120)
- Permitir 2 Nubes por día

---

#### Resultado 2: Demasiado fácil
**Señales:**
- Tasa de éxito >90% desde Día 1
- Nadie usa Nube
- Feedback: "aburrido", "sin tensión", "repetitivo"

**Acción:**
- Reducir tiempo disponible
- Agregar tarea obligatoria adicional
- Aumentar tiempo de tareas
- Eliminar Nube o reducir duración a 30 seg

---

#### Resultado 3: Balance correcto (OBJETIVO)
**Señales:**
- Curva de aprendizaje clara (mejoran con cada día)
- Uso de Nube estratégico (no necesario, pero útil)
- Tensión alta pero justa
- Feedback positivo sobre sensación de logro

**Acción:**
- Proceder con implementación completa
- Ajustes menores según feedback cualitativo

---

### Implementación del prototipo

**Herramientas sugeridas:**
- Unity 2D (simple, rápido para prototipo)
- UI básica con TextMeshPro
- Navegación con clic simple

**Assets necesarios:**
- Reloj funcional
- Timer system
- Sistema de tareas (checklist)
- Transición entre habitaciones

**No necesario para prototipo:**
- Arte final
- Animaciones complejas
- Sistema de notas (probarlo en fase 2)
- Sistema de dinero complejo

---

### Timeline de testeo

**Día 1-2:** Desarrollo del prototipo
**Día 3:** Testing interno (equipo)
**Día 4-5:** Testing con 10-15 jugadores externos
**Día 6:** Análisis de datos
**Día 7:** Iteración basada en resultados

**Total:** 1 semana de validación antes de comprometer recursos a desarrollo completo

---

## 6. Trade-offs Adicionales

### Trade-off 1: Información visible vs Secreto
**Decisión:** Dinero escondido NO es visible en el HUD

**Beneficio:** Aumenta tensión y sensación de secreto
**Costo:** Jugador puede olvidarse de su progreso, debe ir a revisar manualmente

**Justificación:** El tema del juego es ocultación. Mostrar el progreso constantemente trivializa el secreto.

---

### Trade-off 2: Animaciones vs Control
**Decisión:** Tareas tienen animaciones breves que pueden ser "skiped" EXCEPTO después de las 18:00

**Beneficio:** Animaciones mejoran inmersión, skip da control
**Costo:** Jugadores pueden skipear todo y perder feeling

**Justificación:** El bloqueo después de 18:00 fuerza a sentir la desesperación visceral.

---

### Trade-off 3: Tutorial vs Descubrimiento
**Decisión:** Único tutorial es Día 1 con lista de tareas simple, resto es aprendizaje por experiencia

**Beneficio:** Respeta inteligencia del jugador, aprendizaje natural
**Costo:** Jugadores confundidos pueden abandonar

**Justificación:** El tema del juego es falta de agencia. Exceso de tutoriales contradice esto.

---

### Trade-off 4: Narrativa vs Gameplay
**Decisión:** Leer notas pausa el tiempo

**Beneficio:** Fomenta exploración narrativa sin penalización
**Costo:** Rompe la tensión temporal durante la lectura

**Justificación:** La historia es tan importante como las mecánicas. Penalizar la exploración narrativa sería contraproducente.

---

## 7. Justificación de Decisiones Principales

### Decisión 1: Reloj con cambio de color progresivo
**Por qué no un timer numérico con cuenta regresiva:**
- Más inmersivo (parece un reloj real)
- Menos agresivo visualmente
- Enseña al jugador a anticipar en lugar de reaccionar

**Riesgo aceptado:** Jugadores pueden ignorar el reloj hasta que sea tarde

---

### Decisión 2: Evaluación solo al final del día
**Por qué no mostrar el medidor de paciencia en tiempo real:**
- Mantiene incertidumbre: el jugador no sabe si "va bien" hasta el final
- Replica experiencia real de no saber cómo reaccionará la pareja
- Aumenta tensión

**Riesgo aceptado:** Jugadores pueden sentirse "ciegos"

---

### Decisión 3: Dinero escondido visible solo al interactuar
**Por qué no un contador permanente:**
- El acto de revisar debe ser deliberado (replica paranoia)
- El progreso se siente más significativo cuando es revelado intencionalmente
- Añade momento de "respiro" cuando decides revisarlo

**Riesgo aceptado:** Jugadores olvidan revisar su progreso

---

### Decisión 4: Lista de tareas siempre visible
**Por qué no un sistema de quest oculto:**
- Tareas domésticas son recordatorios constantes en la vida real
- Ver lista completa permite planificación estratégica
- Transparencia reduce frustración de "qué se supone que debo hacer"

**Riesgo aceptado:** Puede sentirse menos inmersivo (muy "gamey")

---

### Decisión 5: Notas con estilo visual diferenciado
**Por qué no texto uniforme:**
- Pistas sutiles ayudan al jugador sin ser explícitas
- Reduce confusión sin eliminar ambigüedad
- Estéticamente interesante

**Riesgo aceptado:** Jugadores pueden sobre-interpretar las pistas visuales

---

## 8. Diagrama de Flujo de Interacción

```
DESPERTAR (08:00)
    ↓
[¿Revisar escondite?] ←─────────┐
    ↓ No                        │ Sí (opcional)
[Ir a habitación]               │
    ↓                          │
[Planificar]                   │
    ↓                          │
[Elegir tarea] ←───────────────┼─────┐
    ↓                          │     │
[Navegar a habitación]         │     │
    ↓                          │     │
[Interactuar con objeto]       │     │
    ↓                          │     │
[Animación (skip opcional)]    │     │
    ↓                          │     │
[Tarea completa ☑]            │     │
    ↓                          │     │
[¿Hay más tareas?] ──Sí────────┘     │
    ↓ No                             │
[¿Esconder dinero?] ──Sí─────────────┘
    ↓ No
[¿Leer nota?] ──Sí→ [Pausa] → [Leer] → [Cerrar] ─┐
    ↓ No                                         │
[Verificar reloj] <──────────────────────────────┘
    ↓
[¿Tiempo restante?]
    ↓ <18:00 → Loop continúa
    ↓ 18:00-19:00 → Modo urgencia
    ↓ 19:00 → FIN DE DÍA
        ↓
    [Fade a negro]
        ↓
    [Evaluación]
        ↓
    [Resultado]
        ↓
    [Siguiente día] → DESPERTAR
```

---

## 9. Resumen Ejecutivo

### Core del diseño de interacción
**El jugador debe tener información suficiente para tomar decisiones estratégicas, pero no tanta que elimine la tensión e incertidumbre.**

### Canales principales de información:
1. **Reloj** → Tensión temporal
2. **Lista de tareas** → Carga de trabajo
3. **Evaluación final** → Feedback de desempeño
4. **Escondite** → Progreso hacia meta
5. **Notas** → Ambigüedad narrativa

### Mayor riesgo:
**Balance entre tensión justa y frustración injusta**

### Validación:
Prototipo de 3 días con métricas claras de éxito

### Trade-off principal:
Tiempo real estricto (tensión máxima) vs Pausas permitidas (accesibilidad)
**Solución:** Híbrido con "Nube de Descanso"

---

**Última actualización:** 3 de marzo de 2026  
**Versión:** 1.0  
**Autores:** Equipo UmizumiDevStudio  
**Documento complementario a:** GDD.md

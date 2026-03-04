# SUPONGAMOS QUE MAÑANA
**Game Design Document**

---

## 1. High Concept

Un juego de simulación doméstica con elementos de terror psicológico donde controlas a un ama de casa que debe cumplir con las expectativas del hogar mientras reúne recursos en secreto para escapar de una relación abusiva. La gestión del tiempo es tu enemigo y tu única herramienta de supervivencia.

**Frase clave:** *Cada minuto cuenta. Cada decisión te acerca a la libertad... o a ser descubierta.*

---

## 2. Experiencia central

El jugador debe sentir:

### Tensión constante
El reloj avanza en tiempo real. Cada segundo es una decisión entre cumplir con las tareas domésticas o avanzar en el plan de escape.

### Presión temporal
El marido llega a las 19:00. Si la comida no está lista, hay consecuencias. La ansiedad crece conforme se acerca la hora límite.

### Esperanza frágil
Cada propina guardada es un paso hacia la libertad. El dinero escondido bajo el colchón representa la autonomía construida en secreto.

### Inmersión psicológica
La experiencia replica la sensación de vivir en un entorno controlado donde el tiempo no te pertenece, las decisiones son vigiladas y la única liberación posible requiere planificación invisible.

---

## 3. Perfil de jugador

### Explorador
- Busca entender la narrativa completa y los detalles ocultos

### Triunfador  
- Optimiza decisiones basándose en las pistas encontradas
- Busca la estrategia perfecta para maximizar propinas y minimizar riesgos
- Analiza patrones y consecuencias para ganar eficientemente

### Características generales
- **Nivel:** Intermedio - Sistema claro pero no obvio, requiere atención y análisis
- **Sesiones:** Cortas - Cada día del juego es una sesión completa (aproximadamente 15-20 minutos)
- **Preferencias:** Narrativa fuerte, decisiones significativas, desafío progresivo

---

## 4. Core Loop

### Loop diario (micro)
```
Despertar → Planificar el día → Realizar tareas → Esconder dinero → 
Ajustar estrategia → Esperar llegada del marido → 
Evaluación (paciencia) → Recibir propina o penalización → 
Siguiente día
```

### Loop de progresión (macro)
```
Día 1-3: Aprendizaje y supervivencia básica
   ↓
Día 4-7: Acumulación de recursos y descubrimiento de contradicciones
   ↓
Día 8-11: Manipulación activa y duda creciente
   ↓
Día 12-13: Desesperación y búsqueda de la llave
   ↓
Día 14-15: Clímax y decisión final
```

### Decisiones constantes
En cada momento el jugador debe elegir entre:
- ¿Terminar de limpiar o empezar a cocinar?
- ¿Esconder dinero ahora o después de las tareas?
- ¿Confiar en esta pista o buscar más información?

---

## 5. Mecánicas principales

### Gestión del tiempo
- Reloj en tiempo real que avanza de 8:00 a 19:00
- Cada tarea consume tiempo específico
- Hora límite no negociable: 19:00 (llegada del marido)
- El jugador decide el orden y priorización de actividades

### Sistema de tareas domésticas
**Tareas obligatorias:**
- Cocinar (obligatoria, mayor tiempo)
- Limpiar cocina
- Limpiar sala
- Limpiar habitación
- Lavar ropa (aparece algunos días)

**Consecuencia:** Si la comida no está servida a las 19:00 → paciencia mínima automática

### Medidor de paciencia del marido
Tres estados basados en porcentaje de tareas completadas:

| Estado | Condición | Consecuencia |
|--------|-----------|--------------|
| **Contento** | 80-100% de tareas | Propina de $20 |
| **Neutral** | 50-79% de tareas | Sin propina |
| **Enojado** | <50% de tareas | Tarea extra al día siguiente |

### Sistema de dinero
- **Dinero escondido:** Acumulado bajo el colchón para escapar
- **Propinas:** $20 cuando el marido está contento
- **Meta:** $500 escondidos

**Decisión estratégica:** ¿Priorizo propinas (cumpliendo tareas) o arriesgo para esconder dinero?

### Sistema de escape
- **Condición de victoria:** $500 escondidos + Llave encontrada
- **Condición de derrota:** Descubierta escapando o tiempo agotado
- La llave aparece solo bajo condiciones específicas

---

## 6. Dinámicas esperadas

### Priorización urgente
El jugador constantemente evalúa: *"¿Cocino antes de limpiar? ¿O limpio rápido y cocino después?"*

La presión temporal fuerza decisiones rápidas que determinan el éxito del día.

### Riesgo calculado
Cada vez que escondes dinero sacrificas tiempo de tareas. El jugador debe evaluar:
- ¿Vale la pena el riesgo hoy?
- ¿Puedo permitirme no recibir propina?
- ¿Qué pasa si me descubre?

### Miedo al reloj
El jugador mira constantemente el tiempo. Cada minuto que pasa aumenta la ansiedad. La urgencia se vuelve palpable cerca de las 19:00.

### Esperanza contenida
Revisar el escondite se convierte en ritual: *"¿Cuánto llevo? ¿Cuánto falta?"*

La acumulación progresiva da sensación de avance y control en un entorno opresivo.

### Duda estratégica
Las acciones contradictorias obligan al jugador a:
- Formar teorías sobre qué es verdad
- Rastrear patrones en las contradicciones
- Tomar decisiones con información incompleta

El juego replica la manipulación psicológica a nivel mecánico.

### Optimización progresiva
Con cada intento, el jugador aprende:
- Rutas óptimas entre habitaciones
- Tiempos exactos de cada tarea
- Patrones del sistema de paciencia

---

## 7. Mundo y conflicto

### Tema central
**La memoria como trampa.**

Los recuerdos no son refugio, son herramientas de manipulación. El marido ha reescrito la historia del hogar.

### Mundo
Una casa aislada con tres espacios:

| Habitación | Función narrativa | Función mecánica |
|------------|-------------------|------------------|
| **Cocina** | Lugar de deber donde se mide tu valor | Cocinar, encontrar recetas y pistas falsas |
| **Sala** | Lugar de vigilancia, desde aquí ves la puerta | Espacio de transición, intentos fallidos de ayuda |
| **Habitación** | Falsa intimidad, duermes con el enemigo | Escondite del dinero bajo el colchón, aparición de la llave |

**Características del mundo:**
- Aislamiento físico y psicológico
- No hay ayuda externa visible
- La casa es el único espacio disponible
- Podría estar en cualquier ciudad, pero no importa

### Conflicto central
No sabes si lo que recuerdas es real. El marido ha ido:
- Reemplazando objetos
- Reescribiendo la historia
- Manipulando tu percepción

**Consecuencia mecánica:** Las pistas para escapar están mezcladas con pistas falsas. Debes decidir en qué confiar.

### Escalada del conflicto

**Días 1-3: Confusión inicial**
- Parecen solo decoración narrativa
- Aprendizaje de mecánicas básicas

**Días 4-7: Aparición de contradicciones**
- Comienza la duda: *"¿Quizás no es tan malo?"*

**Días 8-11: Manipulación activa**
- *"No debo irme. Él me necesita."*
- Incomodidad meta-narrativa

**Días 12-13: Desesperación / Revelación**
- Mezcla de pistas reales y trampas
- Decisiones rápidas bajo presión máxima

**Día 14-15: Clímax**
- Las demás desaparecen o son irrelevantes
- Decisión final

### Obstáculos principales

1. **Recuerdos bonitos:** Momentos felices que hacen dudar de la necesidad de escapar
2. **Recuerdos contradictorios:** Información opuesta que obliga a elegir sin certeza

### Dos verbos del jugador
- **Hacer** (tareas domésticas)
- **Esconder** (dinero y evidencia)

**Prohibidos:** salir, gritar, pedir ayuda (porque no hay a quién)

---

## 8. Interfaz conceptual

### Pantalla principal

**Elemento superior:**
- Reloj digital prominente (08:00 - 19:00)
- Indicador visual de tiempo restante

**Área central:**
- Vista de la habitación actual
- Objetos interactivos resaltados sutilmente

**Elemento inferior izquierdo:**
- Inventario simplificado   
  - Estado de ingredientes

**Elemento inferior derecho:**
- Lista de tareas pendientes
  - Marcadas al completarse
  - Indicador de prioridad (comida)

**Oculto hasta interacción:**
- Dinero escondido (se ve al interactuar con el colchón)
- Medidor de paciencia del marido (se revela al final del día)

### Feedback visual

**Reloj:**
- Verde: 08:00-15:00 (tiempo abundante)
- Amarillo: 15:00-18:00 (precaución)
- Rojo: 18:00-19:00 (urgencia máxima)

**Tareas:**
- ✓ Completada (verde)
- ○ Pendiente (blanco)
- ! Crítica (comida, rojo si no está lista a las 18:30)

### Transiciones
- Movimiento fluido entre habitaciones (sin loading)
- Corte a negro al final del día → Evaluación → Siguiente día
- Texto flotante al esconder dinero: "+$20 escondidos"

---

## 9. MVP (Minimum Viable Product)

### Alcance mínimo para testear el core loop

**Mecánicas esenciales:**
1. Sistema de tiempo real (8:00 - 19:00)
2. Tres tareas básicas: Cocinar, Limpiar cocina, Limpiar sala
3. Sistema de paciencia del marido (3 estados)
4. Esconder dinero bajo el colchón
5. Sistema de días (mínimo 7 días para testear progresión)

**Espacios:**
- Cocina (funcional completa)
- Sala (espacio de paso)
- Habitación (escondite del dinero)

**Condiciones de victoria/derrota:**
- Victoria: $140 en 7 días (20x7) + llave aparece automáticamente día 7
- Derrota: Paciencia mínima 3 días seguidos

**Interfaz mínima:**
- Reloj visible
- Lista de tareas
- Contador de dinero escondido (oculto hasta interactuar)
- Mensaje al final del día con estado del marido

**Objetivo del MVP:**
Validar que el jugador siente:
- Presión temporal
- Conflicto entre tareas y esconder dinero
- Tensión creciente hacia las 19:00
- Satisfacción al acumular dinero en secreto

---

## 10. Riesgos y trade-offs

### Riesgo 1: Tiempo real puede ser frustrante
**Problema:** Jugadores pueden sentirse presionados de forma negativa

**Mitigación:**
- Ajustar velocidad del reloj para que sea retador pero alcanzable
- Permitir pausar para pensar estrategia (pero el tiempo sigue corriendo)
- Implementar "Nube de Descanso" como recurso limitado de pausa

**Trade-off:** Sacrificar algo de tensión por accesibilidad

---

### Riesgo 2: Tema sensible puede alejar jugadores
**Problema:** Abuso doméstico es un tema difícil que puede incomodar

**Mitigación:**
- Violencia implícita, nunca explícita
- Enfoque en el aspecto psicológico y la escapatoria
- Advertencia de contenido sensible al inicio
- Representación respetuosa y con propósito narrativo

**Trade-off:** Mantener impacto emocional sin caer en explotación

---

### Riesgo 3: Repetitividad de tareas
**Problema:** Hacer las mismas tareas cada día puede volverse monótono

**Mitigación:**
- Variación en exigencias diarias (tarea extra, ingredientes distintos)
- Duración de juego limitada (máximo 15 días)
- Cada día tiene cambios sutiles en el entorno

**Trade-off:** La repetición es temática (representa la rutina opresiva) pero debe balancearse con engagement

---

### Riesgo 4: Dificultad de balance
**Problema:** Muy fácil = sin tensión, muy difícil = frustración

**Mitigación:**
- Playtesting extensivo para ajustar tiempos
- Diferentes dificultades opcional (más/menos tiempo, mayor/menor exigencia)
- Feedback claro sobre por qué se perdió

**Trade-off:** Puede requerir múltiples iteraciones antes del balance correcto

---

### Riesgo 5: Mecánicas vs Narrativa
**Problema:** El enfoque en mecánicas puede diluir el mensaje narrativo

**Mitigación:**
- Mantener coherencia entre sistemas mecánicos y narrativos
- Cada mecánica refuerza el tema central
- Evitar gamificación excesiva que trivialice el tema

**Trade-off:** Algunas optimizaciones mecánicas pueden sacrificarse por integridad narrativa

---

## Coherencia del diseño

Este GDD mantiene la coherencia entre **Mecánicas → Dinámicas → Estética** planteada en la propuesta original:

**Mecánicas:**
- Tiempo real con límite
- Tareas domésticas obligatorias
- Sistema de paciencia del marido
- Acumulación de recursos en secreto

**Dinámicas:**
- Priorización urgente
- Riesgo calculado
- Miedo al reloj
- Esperanza contenida

**Estética:**
- Tensión constante
- Frustración justa
- Esperanza frágil
- Incomodidad narrativa

---

**Última actualización:** Febrero 2026  
**Versión:** 1.0  
**Autor:** Ana Torres

# ⚔️ Tom: El Desafío de las 5 Fases

Bienvenido al repositorio oficial de **Tom**, un emocionante juego de acción en 2D desarrollado íntegramente en **Godot Engine**. Enfréntate a una serie de batallas épicas en un formato *Boss Rush* donde la precisión y la estrategia son clave.

## 📖 Sinopsis
El mundo ha sido tomado por 5 poderosos jefes. **Tom**, nuestro valiente protagonista, es el único capaz de restaurar el orden. A través de un sistema de fases desbloqueables, deberás derrotar a cada enemigo para avanzar al siguiente nivel de dificultad.

## 🕹️ Características Principales
* **Combate 2D Intenso:** Mecánicas pulidas inspiradas en los grandes clásicos del género.
* **Sistema de Progresión:** Un "Cuadro de Espera" (Hub Central) donde gestionas tus combates y desbloqueas nuevos jefes.
* **Cinemáticas:** Video introductorio que te sumerge en la historia desde el primer segundo.
* **Fluidez:** Sistema de pantalla de carga optimizado para mantener la acción sin interrupciones.

## 🛠️ Arquitectura en Godot
El proyecto está construido bajo una arquitectura **modular y orientada a escenas**, permitiendo que cada jefe y nivel funcione de forma independiente:

* **Escenas de Jefes (`scenes/bosses/`):** Cada jefe es un sistema autónomo con su propia lógica de ataque y animaciones.
* **Controlador de Tom (`scenes/player/`):** Un nodo `CharacterBody2D` centralizado con toda la lógica de movimiento y combate.
* **Gestión de Estados (`scripts/global/`):** Uso de **Singletons (Autoload)** para guardar el progreso de los jefes derrotados.

## 🚀 Cómo Ejecutar el Proyecto
Para probar el juego en tu entorno local:

1. Clona el repositorio:
   ```bash
   git clone [https://github.com/javierdkn/proyecto-de-juego.git](https://github.com/javierdkn/proyecto-de-juego.git)

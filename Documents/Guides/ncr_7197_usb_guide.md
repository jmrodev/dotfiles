# Guía Completa de Conexión e Impresión USB - NCR 7197 / K590

Esta documentación detalla la integración, resolución de problemas de hardware/drivers, comunicación serie-USB y generación de códigos QR en la impresora térmica **NCR 7197 (7402-K592 / K590)** en Linux sin depender de servidores externos ni CUPS.

---

## 1. Arquitectura de Hardware y Conectividad USB

Aunque la impresora cuenta con un conector USB físico tipo B estándar (además del puerto serie DB9), internamente la electrónica utiliza un puente **Digi Edgeport / EPiC (VID: 0x0404, PID: 0x0310)**.

* **Reconocimiento en Linux:**
  * No opera como clase de impresora USB estándar (`usblp`).
  * El kernel carga automáticamente el módulo **`io_edgeport`** y le asigna un puerto serie virtual:
    * `/dev/ttyUSB0`
    * Enlace persistente por udev: `/dev/serial/by-id/usb-NCR_7401-K59X-if00-port0`
* **Permisos de Usuario:**
  * El dispositivo pertenece al grupo `uucp`. Tu usuario debe formar parte de este grupo (`usermod -a -G uucp $USER`).
  * Regla udev configurada en `/etc/udev/rules.d/99-ncr-printer.rules`:
    ```udev
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0404", ATTRS{idProduct}=="0310", MODE="0666", GROUP="lp"
    ```

---

## 2. Parámetros de Comunicación Serie (115200 8-N-1)

Para que el microcontrolador de la NCR procese los datos a través del puerto serie USB:

* **Velocidad (Baud Rate):** `115200` baudios.
* **Bits de datos:** 8 | **Bits de parada:** 1 | **Paridad:** Ninguna (`None`).
* **Control de flujo por hardware (CRÍTICO):** La impresora exige líneas activas de hardware:
  * `DTR = True` (Data Terminal Ready).
  * `RTS = True` (Request To Send).
  * Si estas líneas no se levantan en la apertura del puerto, la controladora asume que el host está desconectado y descarta el buffer.

---

## 3. Comportamientos y Soluciones de Hardware Hallados

### A. Switch de Puerta del Kiosco (Door Switch)
* **Problema:** La impresora cuenta con un módulo Presenter (Kiosco) con sensor de puerta. Al tener el soporte roto, el microcontrolador registraba `Door Open` constante, dejando los trabajos en cola sin avanzar motor ni calentar el cabezal térmico.
* **Solución:** Bloquear físicamente el switch en posición cerrada (ej. con cinta). En el diagnóstico ESC/POS (`10 04 02`), el bit de puerta debe reportar `False` (cerrada).

### B. Ruido Mecánico en el Módulo Presenter / Eyector
* **Problema:** El módulo Presenter de la K590 sostiene el ticket a la salida (`Rcpt Retain Length: 50mm`). Si se envía el comando de corte (`\x1bi`) inmediatamente después del texto, la cuchilla intenta cortar sobre los rodillos de tracción generando un ruido de engranajes forzados.
* **Solución:** Avanzar **8 líneas completas (`\r\n` * 8)** antes de emitir la orden de corte `\x1bi`. Esto garantiza que el papel supere los rodillos del eyector y la cuchilla corte en limpio.

---

## 4. Códigos QR: Limitación Técnica y Solución ("Truco CP437")

### La Limitación
La NCR 7197 es una impresora de arquitectura POS de principios de los 2000:
* **No implementa generador de QR en firmware:** Carece de los comandos modernos ESC/POS como `GS ( k`.
* **Desborde por mapas de bits (Raster Bitmap):** Al enviarle gráficos pesados mediante librerías genéricas de POS, el microcontrolador satura su memoria interna, imprime caracteres basura (`=== ??? n L`) y congela el puerto USB (`[Errno 110] Operation timed out`).

### La Solución 1:1 en Texto Puro (Code Page 437)
Para que el QR sea impreso de forma instantánea sin saturar el buffer:
1. Se genera la matriz matemática del QR mediante la librería `qrcode` de Python (Versión 1, corrección `ERROR_CORRECT_L`).
2. Se imprime como **texto puro** utilizando los medios bloques gráficos de la página de códigos residente **CP437**:
   * `0xDB` = Bloque completo (`█`)
   * `0xDF` = Medio bloque superior (`▀`)
   * `0xDC` = Medio bloque inferior (`▄`)
   * `0x20` = Espacio en blanco (` `)
3. Esto permite agrupar **dos filas del código QR en una sola línea de texto**, logrando una relación de aspecto **1:1 perfectamente cuadrada**, centrada y 100% escaneable por lectores de smartphones.
4. Las micro-rayitas blancas entre filas son normales por el espacio físico de diseño tipográfico entre caracteres en la ROM térmica y no impiden la lectura instantánea.

---

## 5. Herramientas y Scripts Disponibles

### A. Editor Gráfico de Tickets (`ncr-editor`)
* **Ubicación:** `~/.local/bin/ncr-editor` (apunta a `editor_ncr.py`).
* **Acceso:** Disponible en el menú de aplicaciones (`Super + d`), desde la barra o escribiendo `ncr-editor` / `editor` en la terminal.
* **Funciones:**
  * Escribir/pegar texto para rollo de 80 mm (42 caracteres de ancho estándar).
  * Formatos de texto (Negrita, Letra Grande, Alineación Izquierda/Centro/Derecha).
  * Auto-alineador de columnas con tabulaciones.
  * Botón **"Imprimir QR"**: Abre un cuadro de diálogo para ingresar cualquier URL/texto e imprimirlo al vuelo.
  * Envío automático directo a `/dev/ttyUSB0` con fallback a PyUSB y Debian CUPS.

### B. Generador de Códigos QR por CLI (`ncr-print-qr`)
* **Ubicación:** `~/.local/bin/ncr-print-qr`.
* **Uso:**
  ```bash
  ncr-print-qr "<URL_O_TEXTO>" "[TITULO_OPCIONAL]"
  ```
* **Ejemplo:**
  ```bash
  ncr-print-qr "https://github.com/jmrodev" "Mi Perfil GitHub"
  ```

### C. Impresión de Archivos y Pipes (`ncr-print`)
* **Ubicación:** `~/.local/bin/ncr-print`.
* **Uso:**
  ```bash
  # Imprimir texto rápido
  echo "Texto de prueba" | ncr-print

  # Imprimir un archivo
  ncr-print lista.txt

  # Ticket demo formateado
  ncr-print --demo
  ```

#!/usr/bin/env python3
import sys
import subprocess
import argparse
import os

# Comandos ESC/POS estándar y específicos para NCR 7197 / K590
ESC = b"\x1b"
GS = b"\x1d"

INIT = ESC + b"@"                   # Inicializar impresora (Reset)
ALIGN_LEFT = ESC + b"a\x00"        # Alineación izquierda
ALIGN_CENTER = ESC + b"a\x01"      # Alineación centro
ALIGN_RIGHT = ESC + b"a\x02"       # Alineación derecha

BOLD_ON = ESC + b"E\x01"           # Negrita ON
BOLD_OFF = ESC + b"E\x00"          # Negrita OFF

TXT_NORMAL = ESC + b"!\x00"        # Texto normal
TXT_BIG = ESC + b"!\x30"           # Texto doble ancho y alto

CUT_PAPER = ESC + b"i"             # Corte de papel completo (NCR 7197)

VENDOR_ID = 0x0404
PRODUCT_ID = 0x0310

def enviar_por_usb_directo(payload):
    """Envía los datos a través del puerto serie USB nativo (/dev/ttyUSB0) o PyUSB directo."""
    for port in ["/dev/serial/by-id/usb-NCR_7401-K59X-if00-port0", "/dev/ttyUSB0"]:
        if os.path.exists(port):
            try:
                import serial
                ser = serial.Serial(port, 115200, timeout=2)
                ser.dtr = True
                ser.rts = True
                ser.write(payload)
                ser.flush()
                ser.close()
                print("Impreso correctamente vía USB (/dev/ttyUSB0).")
                return True
            except Exception as e:
                pass

    try:
        import usb.core
        import usb.util
        dev = usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)
        if dev is None:
            print("Error: Impresora NCR USB (0404:0310) no detectada físicamente.", file=sys.stderr)
            return False
        
        try:
            if dev.is_kernel_driver_active(0):
                dev.detach_kernel_driver(0)
        except Exception:
            pass

        try:
            usb.util.claim_interface(dev, 0)
        except Exception:
            pass

        dev.write(0x01, payload, timeout=5000)
        
        try:
            usb.util.release_interface(dev, 0)
        except Exception:
            pass

        print("Impreso correctamente vía USB directo.")
        return True
    except Exception as e:
        print(f"Error escribiendo en puerto USB: {e}", file=sys.stderr)
        return False

def enviar_a_cups(datos, nombre_impresora="NCR71xx_80mm"):
    """Envía los bytes formateados a la cola RAW de CUPS (Servidor Debian / Red local)."""
    try:
        process = subprocess.Popen(
            ['lp', '-d', nombre_impresora, '-o', 'raw'],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        stdout, stderr = process.communicate(input=datos)
        if process.returncode != 0:
            print(f"Error al imprimir en CUPS ({nombre_impresora}): {stderr.decode('utf-8')}", file=sys.stderr)
            return False
        print(f"Impreso correctamente vía CUPS ({nombre_impresora}).")
        return True
    except Exception as e:
        print(f"Excepción al conectar con CUPS: {e}", file=sys.stderr)
        return False

def enviar_a_impresora(payload, modo="usb", nombre_impresora="NCR71xx_80mm"):
    if modo == "usb":
        return enviar_por_usb_directo(payload)
    else:
        return enviar_a_cups(payload, nombre_impresora)

def imprimir_texto_simple(texto, modo="usb"):
    payload = INIT + ALIGN_LEFT + TXT_NORMAL
    for linea in texto.splitlines():
        payload += linea.encode('latin1', errors='replace') + b"\r\n"
    payload += (b"\r\n" * 8) + CUT_PAPER
    return enviar_a_impresora(payload, modo=modo)

def imprimir_ticket_demo(modo="usb"):
    payload = INIT
    
    BIG_BOLD_STYLE = ESC + b"!\x38" + ESC + b"E\x01" + ESC + b"G\x01"
    NORMAL_STYLE = ESC + b"!\x00" + ESC + b"E\x00" + ESC + b"G\x00"

    payload += ALIGN_CENTER + BIG_BOLD_STYLE + b"PRUEBA DE IMPRESION\r\n" + NORMAL_STYLE
    payload += b"NCR 7197 / K590 - 80mm\r\n"
    payload += b"------------------------------------------\r\n"
    payload += ALIGN_LEFT
    payload += b"Cant.  Descripcion             Precio\r\n"
    payload += b"------------------------------------------\r\n"
    payload += b" 1     Modo Seleccionado      " + (b"USB DIRECTO" if modo == "usb" else b"DEBIAN CUPS") + b"\r\n"
    payload += b" 1     Cafe Expreso           $ 1.500,00\r\n"
    payload += b"------------------------------------------\r\n"
    payload += ALIGN_RIGHT + BIG_BOLD_STYLE + b"TOTAL: $ 1.500,00\r\n" + NORMAL_STYLE
    payload += ALIGN_CENTER + b"\r\nGracias por su compra!\r\n"
    payload += (b"\r\n" * 8) + CUT_PAPER
    return enviar_a_impresora(payload, modo=modo)

def imprimir_qr(url_o_texto, modo="usb"):
    if modo == "usb":
        try:
            from escpos.printer import Usb
            p = Usb(VENDOR_ID, PRODUCT_ID, in_ep=0x82, out_ep=0x01)
            p.set(align="center")
            p.text("\n" + url_o_texto + "\n\n")
            p.qr(url_o_texto, size=6)
            p.text("\n" * 8)
            p.cut()
            p.close()
            print("QR impreso correctamente vía USB.")
            return True
        except Exception as e:
            print(f"Error imprimiendo QR: {e}", file=sys.stderr)
            return False
    else:
        print("Impresión directa de QR nativo disponible únicamente en modo USB.", file=sys.stderr)
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Impresor de tickets para NCR 7197 (USB Directo / CUPS Debian)")
    parser.add_argument("-m", "--modo", choices=["usb", "debian"], default="usb", help="Modo de conexión: 'usb' (Directo USB local) o 'debian' (CUPS red Debian)")
    parser.add_argument("-t", "--texto", help="Texto plano a imprimir")
    parser.add_argument("-f", "--file", help="Ruta a archivo de texto a imprimir")
    parser.add_argument("-q", "--qr", help="Imprimir código QR a partir de texto o URL")
    parser.add_argument("--demo", action="store_true", help="Imprimir ticket de demostración")

    args = parser.parse_args()

    if args.demo:
        print(f"Imprimiendo ticket demo en modo {args.modo.upper()}...")
        imprimir_ticket_demo(modo=args.modo)
    elif args.qr:
        imprimir_qr(args.qr, modo=args.modo)
    elif args.texto:
        imprimir_texto_simple(args.texto, modo=args.modo)
    elif args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            imprimir_texto_simple(f.read(), modo=args.modo)
    else:
        if not sys.stdin.isatty():
            imprimir_texto_simple(sys.stdin.read(), modo=args.modo)
        else:
            parser.print_help()

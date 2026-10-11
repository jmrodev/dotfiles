#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import sys

# Comandos ESC/POS
ESC = b"\x1b"
INIT = b"\x1b@"
ALIGN_LEFT = b"\x1ba\x00"
ALIGN_CENTER = b"\x1ba\x01"
ALIGN_RIGHT = b"\x1ba\x02"
TXT_NORMAL = b"\x1b!\x00"
TXT_BIG = b"\x1b!\x30"
CUT_PAPER = b"\x1bi"

VENDOR_ID = 0x0404
PRODUCT_ID = 0x0310

class NCRPrinterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Impresor de Tickets NCR 7197 / K590")
        self.root.geometry("620x560")

        # Frame de selección de destino (USB Directo vs CUPS Debian)
        dest_frame = ttk.LabelFrame(root, text=" Conexión / Destino ")
        dest_frame.pack(fill="x", padx=10, pady=5)

        self.modo_var = tk.StringVar(value="usb")
        ttk.Radiobutton(dest_frame, text="USB Directo (PC Local)", variable=self.modo_var, value="usb").pack(side="left", padx=15, pady=5)
        ttk.Radiobutton(dest_frame, text="CUPS Red (Servidor Debian / Serial)", variable=self.modo_var, value="debian").pack(side="left", padx=15, pady=5)

        # Frame de controles de formato
        fmt_frame = ttk.LabelFrame(root, text=" Formato de Texto ")
        fmt_frame.pack(fill="x", padx=10, pady=5)

        self.bold_var = tk.BooleanVar()
        self.big_var = tk.BooleanVar()
        self.align_var = tk.StringVar(value="left")

        ttk.Checkbutton(fmt_frame, text="Negrita", variable=self.bold_var).pack(side="left", padx=5, pady=5)
        ttk.Checkbutton(fmt_frame, text="Letra Grande", variable=self.big_var).pack(side="left", padx=5, pady=5)

        ttk.Separator(fmt_frame, orient="vertical").pack(side="left", fill="y", padx=10)

        ttk.Radiobutton(fmt_frame, text="Izquierda", variable=self.align_var, value="left").pack(side="left", padx=5)
        ttk.Radiobutton(fmt_frame, text="Centrado", variable=self.align_var, value="center").pack(side="left", padx=5)
        ttk.Radiobutton(fmt_frame, text="Derecha", variable=self.align_var, value="right").pack(side="left", padx=5)

        # Área de edición de texto (Ancho estándar NCR 42 caracteres)
        text_frame = ttk.LabelFrame(root, text=" Contenido del Ticket (Ancho 42 caracteres) ")
        text_frame.pack(fill="both", expand=True, padx=10, pady=5)

        self.text_editor = tk.Text(text_frame, font=("Courier", 11), wrap="none", width=42)
        self.text_editor.pack(fill="both", expand=True, padx=5, pady=5)
        
        self.text_editor.insert("1.0", "=== TICKET DE PRUEBA NCR ===\n"
                                       "Producto 1                    $ 100.00\n"
                                       "Producto 2                    $ 250.00\n"
                                       "----------------------------------------\n"
                                       "TOTAL:                        $ 350.00\n\n"
                                       "Gracias por su compra!")

        # Botones de Acción
        btn_frame = ttk.Frame(root)
        btn_frame.pack(fill="x", padx=10, pady=10)

        ttk.Button(btn_frame, text="Limpiar", command=self.limpiar).pack(side="left", padx=5)
        ttk.Button(btn_frame, text="Auto-Alinear Cols", command=self.auto_alinear_columnas).pack(side="left", padx=5)
        ttk.Button(btn_frame, text="Cortar Papel", command=self.cortar_solo).pack(side="left", padx=5)
        
        btn_print = ttk.Button(btn_frame, text=" IMPRIMIR TICKET", command=self.imprimir)
        btn_print.pack(side="right", padx=5)

    def limpiar(self):
        self.text_editor.delete("1.0", tk.END)

    def auto_alinear_columnas(self):
        contenido = self.text_editor.get("1.0", tk.END).splitlines()
        nuevas_lineas = []
        for linea in contenido:
            if "\t" in linea:
                partes = linea.split("\t", 1)
            elif "  " in linea and not linea.strip().startswith("-") and not linea.strip().startswith("="):
                partes = linea.rsplit("  ", 1)
            else:
                partes = [linea]
            
            if len(partes) == 2:
                izq = partes[0].strip()
                der = partes[1].strip()
                espacios = 42 - len(izq) - len(der)
                if espacios > 0:
                    nuevas_lineas.append(izq + (" " * espacios) + der)
                else:
                    nuevas_lineas.append(linea)
            else:
                nuevas_lineas.append(linea)
        
        self.text_editor.delete("1.0", tk.END)
        self.text_editor.insert("1.0", "\n".join(nuevas_lineas))

    def construir_bytes(self, texto):
        payload = INIT
        align = self.align_var.get()
        if align == "center":
            cmd_align = ALIGN_CENTER
        elif align == "right":
            cmd_align = ALIGN_RIGHT
        else:
            cmd_align = ALIGN_LEFT

        is_bold = self.bold_var.get()
        is_big = self.big_var.get()

        font_byte = 0
        if is_bold:
            font_byte |= 0x08
        if is_big:
            font_byte |= 0x30

        cmd_font = ESC + b"!" + bytes([font_byte])
        cmd_bold_extra = (ESC + b"E\x01" + ESC + b"G\x01") if is_bold else (ESC + b"E\x00" + ESC + b"G\x00")
        cmd_style = cmd_font + cmd_bold_extra

        for linea in texto.splitlines():
            payload += cmd_align + cmd_style + linea.encode('latin1', errors='replace') + b"\r\n"

        payload += ALIGN_LEFT + ESC + b"!\x00" + ESC + b"E\x00" + ESC + b"G\x00" + b"\r\n\r\n\r\n\r\n" + CUT_PAPER
        return payload

    def enviar_por_usb(self, payload):
        try:
            import usb.core
            dev = usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)
            if dev is None:
                messagebox.showerror("Error USB", "Impresora NCR (0404:0310) no encontrada por USB.")
                return
            try:
                if dev.is_kernel_driver_active(0):
                    dev.detach_kernel_driver(0)
            except Exception:
                pass
            dev.write(0x01, payload, timeout=5000)
            messagebox.showinfo("Éxito", "Ticket enviado vía USB Directo.")
        except Exception as e:
            messagebox.showerror("Error de Impresión USB", str(e))

    def enviar_por_cups(self, payload):
        try:
            proc = subprocess.Popen(['lp', '-d', 'NCR71xx_80mm', '-o', 'raw'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
            _, stderr = proc.communicate(input=payload)
            if proc.returncode != 0:
                messagebox.showerror("Error CUPS Debian", stderr.decode('utf-8'))
            else:
                messagebox.showinfo("Éxito", "Ticket enviado a CUPS Debian.")
        except Exception as e:
            messagebox.showerror("Error CUPS", str(e))

    def imprimir(self):
        contenido = self.text_editor.get("1.0", tk.END).strip()
        if not contenido:
            messagebox.showwarning("Atención", "El ticket está vacío.")
            return
        payload = self.construir_bytes(contenido)
        if self.modo_var.get() == "usb":
            self.enviar_por_usb(payload)
        else:
            self.enviar_por_cups(payload)

    def cortar_solo(self):
        payload = INIT + b"\r\n\r\n\r\n\r\n" + CUT_PAPER
        if self.modo_var.get() == "usb":
            self.enviar_por_usb(payload)
        else:
            self.enviar_por_cups(payload)

if __name__ == "__main__":
    root = tk.Tk()
    app = NCRPrinterApp(root)
    root.mainloop()

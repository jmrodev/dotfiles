#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox, font as tkfont
import subprocess
import os
import sys

# Códigos ESC/POS
ESC = b"\x1b"
FS = b"\x1c"
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
        self.root.title("NCR 7197 - Ticket Studio & Editor")
        self.root.geometry("780x700")
        self.root.minsize(720, 620)

        self._configurar_estilos()
        self._construir_ui()

    def _configurar_estilos(self):
        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Header.TLabel", font=("Helvetica", 11, "bold"))
        style.configure("Action.TButton", font=("Helvetica", 10, "bold"), padding=5)
        style.configure("Print.TButton", font=("Helvetica", 11, "bold"), padding=8, background="#2e7d32", foreground="white")
        style.map("Print.TButton", background=[("active", "#1b5e20")])

    def _construir_ui(self):
        # 1. Barra Superior: Conexión y Destino
        top_bar = ttk.Frame(self.root, padding="10 10 10 5")
        top_bar.pack(fill="x")

        dest_group = ttk.LabelFrame(top_bar, text=" Conexión / Destino ", padding="8 5")
        dest_group.pack(side="left", fill="x", expand=True)

        self.modo_var = tk.StringVar(value="usb")
        ttk.Radiobutton(dest_group, text="USB Directo (/dev/ttyUSB0)", variable=self.modo_var, value="usb").pack(side="left", padx=10)
        ttk.Radiobutton(dest_group, text="CUPS Red (Debian)", variable=self.modo_var, value="debian").pack(side="left", padx=10)

        # 2. Barra de Herramientas: Formato de Texto y Alineación Interactiva
        tools_frame = ttk.LabelFrame(self.root, text=" Formato y Alineación (Afecta Selección / Línea Actual) ", padding="8 6")
        tools_frame.pack(fill="x", padx=10, pady=5)

        # Botones de estilo
        ttk.Button(tools_frame, text="Negrita (B)", width=11, command=self.toggle_negrita).pack(side="left", padx=4)
        ttk.Button(tools_frame, text="Texto Grande", width=13, command=self.toggle_grande).pack(side="left", padx=4)

        ttk.Separator(tools_frame, orient="vertical").pack(side="left", fill="y", padx=8)

        # Botones de alineación real en pantalla (párrafo/línea)
        ttk.Button(tools_frame, text="⫷ Izquierda", width=11, command=lambda: self.aplicar_alineacion("left")).pack(side="left", padx=4)
        ttk.Button(tools_frame, text="≡ Centro", width=10, command=lambda: self.aplicar_alineacion("center")).pack(side="left", padx=4)
        ttk.Button(tools_frame, text="Derecha ⫸", width=11, command=lambda: self.aplicar_alineacion("right")).pack(side="left", padx=4)

        ttk.Separator(tools_frame, orient="vertical").pack(side="left", fill="y", padx=8)

        # Utilidades de estructura
        ttk.Button(tools_frame, text="Auto-Alinear Cols", command=self.auto_alinear_columnas).pack(side="left", padx=4)
        ttk.Button(tools_frame, text="Separador (---)", command=self.insertar_separador).pack(side="left", padx=4)
        ttk.Button(tools_frame, text="Limpiar", command=self.limpiar).pack(side="left", padx=4)

        # 3. Área Central: Editor con Tags Visuales y Límites (42 columnas)
        editor_frame = ttk.LabelFrame(self.root, text=" Vista Previa / Editor WYSIWYG (42 Caracteres / 80mm) ", padding=8)
        editor_frame.pack(fill="both", expand=True, padx=10, pady=5)

        text_container = ttk.Frame(editor_frame)
        text_container.pack(fill="both", expand=True)

        scroll_y = ttk.Scrollbar(text_container, orient="vertical")
        scroll_y.pack(side="right", fill="y")

        self.font_normal = tkfont.Font(family="Courier 10 Pitch", size=12, weight="normal")
        self.font_bold = tkfont.Font(family="Courier 10 Pitch", size=12, weight="bold")
        self.font_big = tkfont.Font(family="Courier 10 Pitch", size=18, weight="normal")
        self.font_big_bold = tkfont.Font(family="Courier 10 Pitch", size=18, weight="bold")

        self.text_editor = tk.Text(
            text_container,
            font=self.font_normal,
            wrap="none",
            width=42,
            padx=12,
            pady=10,
            yscrollcommand=scroll_y.set,
            background="#ffffff",
            foreground="#1e1e1e"
        )
        self.text_editor.pack(side="left", fill="both", expand=True)
        scroll_y.config(command=self.text_editor.yview)

        # Configuración de Tags visuales en Tkinter
        self.text_editor.tag_configure("align_left", justify="left")
        self.text_editor.tag_configure("align_center", justify="center")
        self.text_editor.tag_configure("align_right", justify="right")
        self.text_editor.tag_configure("bold", font=self.font_bold)
        self.text_editor.tag_configure("big", font=self.font_big)
        self.text_editor.tag_configure("big_bold", font=self.font_big_bold)

        # Cargar plantilla inicial con formatos predefinidos
        self._cargar_plantilla_inicial()

        # 4. Panel de Funciones Especiales (QR, Logo Flash, Corte)
        adv_frame = ttk.LabelFrame(self.root, text=" Funciones Especiales de Hardware ", padding="8 8")
        adv_frame.pack(fill="x", padx=10, pady=5)

        ttk.Button(adv_frame, text=" Generar e Imprimir QR", command=self.abrir_dialogo_qr).pack(side="left", padx=6)
        ttk.Button(adv_frame, text=" Imprimir Logo NV (#1)", command=self.imprimir_logo_flash).pack(side="left", padx=6)
        ttk.Button(adv_frame, text=" Avanzar y Cortar", command=self.cortar_solo).pack(side="left", padx=6)

        # 5. Barra Inferior de Impresión y Estado
        bottom_bar = ttk.Frame(self.root, padding="10 8 10 12")
        bottom_bar.pack(fill="x")

        self.status_lbl = ttk.Label(bottom_bar, text="Listo para imprimir.", foreground="#555")
        self.status_lbl.pack(side="left")

        btn_print = ttk.Button(bottom_bar, text="🖨️ IMPRIMIR TICKET", style="Print.TButton", command=self.imprimir)
        btn_print.pack(side="right")

    def _cargar_plantilla_inicial(self):
        self.text_editor.delete("1.0", tk.END)
        self.text_editor.insert("1.0",
            "==========================================\n"
            "       TICKET DE VENTA / SERVICIO         \n"
            "==========================================\n"
            "Producto 1                        $ 150.00\n"
            "Servicio Tecnico                  $ 350.00\n"
            "------------------------------------------\n"
            "TOTAL                             $ 500.00\n\n"
            "      Muchas gracias por su compra!       \n"
        )
        # Aplicar estilos visuales a la plantilla
        self.text_editor.tag_add("align_center", "2.0", "2.end")
        self.text_editor.tag_add("bold", "2.0", "2.end")
        self.text_editor.tag_add("bold", "7.0", "7.end")
        self.text_editor.tag_add("align_center", "9.0", "9.end")

    def set_status(self, msg, error=False):
        self.status_lbl.config(text=msg, foreground="#b71c1c" if error else "#2e7d32")

    def limpiar(self):
        self.text_editor.delete("1.0", tk.END)
        self.set_status("Editor limpio.")

    def insertar_separador(self):
        self.text_editor.insert(tk.INSERT, "------------------------------------------\n")

    def aplicar_alineacion(self, align_type):
        """Aplica alineación (left, center, right) a las líneas seleccionadas o línea actual."""
        try:
            start = self.text_editor.index("sel.first linestart")
            end = self.text_editor.index("sel.last lineend")
        except tk.TclError:
            start = self.text_editor.index("insert linestart")
            end = self.text_editor.index("insert lineend")

        for tag in ["align_left", "align_center", "align_right"]:
            self.text_editor.tag_remove(tag, start, end)

        tag_name = f"align_{align_type}"
        self.text_editor.tag_add(tag_name, start, end)
        self.set_status(f"Alineación '{align_type}' aplicada.")

    def toggle_negrita(self):
        """Alterna negrita en la selección o palabra actual."""
        try:
            start = self.text_editor.index("sel.first")
            end = self.text_editor.index("sel.last")
        except tk.TclError:
            start = self.text_editor.index("insert linestart")
            end = self.text_editor.index("insert lineend")

        # Verificar si ya tiene negrita
        tags = self.text_editor.tag_names(start)
        if "bold" in tags or "big_bold" in tags:
            self.text_editor.tag_remove("bold", start, end)
            if "big_bold" in tags:
                self.text_editor.tag_remove("big_bold", start, end)
                self.text_editor.tag_add("big", start, end)
            self.set_status("Negrita removida.")
        else:
            if "big" in tags:
                self.text_editor.tag_remove("big", start, end)
                self.text_editor.tag_add("big_bold", start, end)
            else:
                self.text_editor.tag_add("bold", start, end)
            self.set_status("Negrita aplicada.")

    def toggle_grande(self):
        """Alterna tamaño grande en la selección o línea actual."""
        try:
            start = self.text_editor.index("sel.first")
            end = self.text_editor.index("sel.last")
        except tk.TclError:
            start = self.text_editor.index("insert linestart")
            end = self.text_editor.index("insert lineend")

        tags = self.text_editor.tag_names(start)
        if "big" in tags or "big_bold" in tags:
            self.text_editor.tag_remove("big", start, end)
            if "big_bold" in tags:
                self.text_editor.tag_remove("big_bold", start, end)
                self.text_editor.tag_add("bold", start, end)
            self.set_status("Tamaño normal restablecido.")
        else:
            if "bold" in tags:
                self.text_editor.tag_remove("bold", start, end)
                self.text_editor.tag_add("big_bold", start, end)
            else:
                self.text_editor.tag_add("big", start, end)
            self.set_status("Texto grande aplicado.")

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
        self.text_editor.insert("1.0", "\n".join(nuevas_lineas) + "\n")
        self.set_status("Columnas auto-alineadas a 42 caracteres.")

    def abrir_dialogo_qr(self):
        win = tk.Toplevel(self.root)
        win.title("Generador e Impresor de Código QR")
        win.geometry("450x230")
        win.resizable(False, False)
        win.transient(self.root)
        win.grab_set()

        ttk.Label(win, text="URL o Texto para el QR:", font=("Helvetica", 10, "bold")).pack(anchor="w", padx=15, pady=(15, 2))
        url_entry = ttk.Entry(win, width=45)
        url_entry.pack(fill="x", padx=15, pady=5)
        url_entry.insert(0, "https://github.com/jmrodev")
        url_entry.focus()

        ttk.Label(win, text="Título superior (opcional):", font=("Helvetica", 10)).pack(anchor="w", padx=15, pady=(8, 2))
        title_entry = ttk.Entry(win, width=45)
        title_entry.pack(fill="x", padx=15, pady=5)
        title_entry.insert(0, "ESCANEA ESTE QR:")

        btn_box = ttk.Frame(win)
        btn_box.pack(fill="x", padx=15, pady=15)

        def ejecutar():
            data = url_entry.get().strip()
            title = title_entry.get().strip()
            if not data:
                messagebox.showwarning("Atención", "El contenido del QR no puede estar vacío.", parent=win)
                return
            win.destroy()
            self._imprimir_qr_worker(data, title)

        ttk.Button(btn_box, text="Cancelar", command=win.destroy).pack(side="right", padx=5)
        ttk.Button(btn_box, text="🖨️ Imprimir QR Ahora", command=ejecutar).pack(side="right", padx=5)

    def _imprimir_qr_worker(self, data, title):
        qr_cmd = "/home/jmro/.local/bin/ncr-print-qr"
        if not os.path.exists(qr_cmd):
            qr_cmd = "ncr-print-qr"
        try:
            res = subprocess.run([qr_cmd, data, title], capture_output=True, text=True)
            if res.returncode == 0:
                self.set_status("QR impreso exitosamente.")
                messagebox.showinfo("Éxito", "Código QR impreso correctamente en la NCR 7197.")
            else:
                self.set_status(f"Error QR: {res.stderr}", error=True)
                messagebox.showerror("Error al Imprimir QR", res.stderr or "Fallo en ncr-print-qr")
        except Exception as e:
            self.set_status(f"Error: {e}", error=True)
            messagebox.showerror("Error", str(e))

    def imprimir_logo_flash(self):
        logo_cmd = "/home/jmro/.local/bin/ncr-flash-logo"
        if not os.path.exists(logo_cmd):
            messagebox.showwarning("Herramienta no encontrada", "El script ncr-flash-logo no está disponible.")
            return
        res = subprocess.run([logo_cmd, "print", "--logo-num", "1"], capture_output=True, text=True)
        if res.returncode == 0:
            self.set_status("Orden de impresión de Logo #1 enviada.")
            messagebox.showinfo("Éxito", "Orden de Logo #1 enviada a la memoria de la impresora.")
        else:
            self.set_status(f"Error Logo: {res.stderr}", error=True)
            messagebox.showerror("Error Logo Flash", res.stderr or "No se pudo imprimir el logo.")

    def construir_bytes(self):
        """
        Construye el payload binario ESC/POS analizando cada línea y sus tags visuales aplicados.
        """
        payload = INIT
        total_lines = int(self.text_editor.index("end-1c").split(".")[0])

        for line_num in range(1, total_lines + 1):
            line_start = f"{line_num}.0"
            line_end = f"{line_num}.end"
            texto_linea = self.text_editor.get(line_start, line_end)

            # Obtener tags en el inicio de la línea
            tags = self.text_editor.tag_names(line_start)

            # Alineación
            if "align_center" in tags:
                cmd_align = ALIGN_CENTER
            elif "align_right" in tags:
                cmd_align = ALIGN_RIGHT
            else:
                cmd_align = ALIGN_LEFT

            # Estilo de fuente (Grande / Negrita)
            is_bold = ("bold" in tags or "big_bold" in tags)
            is_big = ("big" in tags or "big_bold" in tags)

            font_byte = 0
            if is_bold:
                font_byte |= 0x08
            if is_big:
                font_byte |= 0x30

            cmd_font = ESC + b"!" + bytes([font_byte])
            cmd_bold_extra = (ESC + b"E\x01" + ESC + b"G\x01") if is_bold else (ESC + b"E\x00" + ESC + b"G\x00")
            cmd_style = cmd_font + cmd_bold_extra

            payload += cmd_align + cmd_style + texto_linea.encode('latin1', errors='replace') + b"\r\n"

        # Avance de seguridad para el módulo Presenter (8 líneas) y corte limpio
        payload += ALIGN_LEFT + ESC + b"!\x00" + ESC + b"E\x00" + ESC + b"G\x00" + (b"\r\n" * 8) + CUT_PAPER
        return payload

    def enviar_por_usb(self, payload):
        import serial
        for port in ["/dev/serial/by-id/usb-NCR_7401-K59X-if00-port0", "/dev/ttyUSB0"]:
            if os.path.exists(port):
                try:
                    ser = serial.Serial(port, 115200, timeout=3)
                    ser.dtr = True
                    ser.rts = True
                    ser.write(payload)
                    ser.flush()
                    ser.close()
                    self.set_status("Ticket impreso correctamente vía USB.")
                    return True
                except Exception as e:
                    self.set_status(f"Fallo en puerto {port}: {e}", error=True)
                    pass

        # Fallback PyUSB
        try:
            import usb.core
            dev = usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)
            if dev is None:
                messagebox.showerror("Error USB", "Impresora NCR (0404:0310) no detectada.")
                return False
            try:
                if dev.is_kernel_driver_active(0):
                    dev.detach_kernel_driver(0)
            except Exception:
                pass
            dev.write(0x01, payload, timeout=5000)
            self.set_status("Ticket impreso vía PyUSB.")
            return True
        except Exception as e:
            messagebox.showerror("Error de Impresión USB", str(e))
            return False

    def enviar_por_cups(self, payload):
        try:
            proc = subprocess.Popen(['lp', '-d', 'NCR71xx_80mm', '-o', 'raw'], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
            _, stderr = proc.communicate(input=payload)
            if proc.returncode != 0:
                messagebox.showerror("Error CUPS Debian", stderr.decode('utf-8'))
                return False
            else:
                self.set_status("Ticket enviado a CUPS Debian.")
                return True
        except Exception as e:
            messagebox.showerror("Error CUPS", str(e))
            return False

    def imprimir(self):
        contenido = self.text_editor.get("1.0", tk.END).strip()
        if not contenido:
            messagebox.showwarning("Atención", "El ticket está vacío.")
            return
        payload = self.construir_bytes()
        if self.modo_var.get() == "usb":
            if self.enviar_por_usb(payload):
                messagebox.showinfo("Éxito", "Ticket impreso correctamente.")
        else:
            if self.enviar_por_cups(payload):
                messagebox.showinfo("Éxito", "Ticket enviado a CUPS.")

    def cortar_solo(self):
        payload = INIT + (b"\r\n" * 8) + CUT_PAPER
        if self.modo_var.get() == "usb":
            self.enviar_por_usb(payload)
        else:
            self.enviar_por_cups(payload)

if __name__ == "__main__":
    root = tk.Tk()
    app = NCRPrinterApp(root)
    root.mainloop()

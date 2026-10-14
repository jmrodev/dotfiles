#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox, font as tkfont, filedialog
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
        self.root.title("NCR 7197 - Ticket Studio & Control Center")
        self.root.geometry("800x640")
        self.root.minsize(740, 540)

        self._configurar_estilos()
        self._construir_ui()

    def _configurar_estilos(self):
        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Header.TLabel", font=("Helvetica", 10, "bold"))
        style.configure("Print.TButton", font=("Helvetica", 10, "bold"), padding=6, background="#2e7d32", foreground="white")
        style.map("Print.TButton", background=[("active", "#1b5e20")])
        style.configure("TNotebook.Tab", padding=[14, 6], font=("Helvetica", 9, "bold"))

    def _construir_ui(self):
        # 1. Barra Inferior Fija (Impresión y Estado Global)
        bottom_bar = ttk.Frame(self.root, padding="10 6 10 8")
        bottom_bar.pack(side="bottom", fill="x")

        self.status_lbl = ttk.Label(bottom_bar, text="Listo para operar.", foreground="#555")
        self.status_lbl.pack(side="left")

        btn_print = ttk.Button(bottom_bar, text="🖨️ IMPRIMIR TICKET", style="Print.TButton", command=self.imprimir)
        btn_print.pack(side="right")

        # 2. Barra Superior: Conexión y Destino
        top_bar = ttk.Frame(self.root, padding="10 6 10 2")
        top_bar.pack(side="top", fill="x")

        dest_group = ttk.LabelFrame(top_bar, text=" Conexión / Destino de Impresora ", padding="6 3")
        dest_group.pack(fill="x")

        self.modo_var = tk.StringVar(value="usb")
        ttk.Radiobutton(dest_group, text="USB Directo (/dev/ttyUSB0)", variable=self.modo_var, value="usb").pack(side="left", padx=12)
        ttk.Radiobutton(dest_group, text="CUPS Red (Debian)", variable=self.modo_var, value="debian").pack(side="left", padx=12)

        # 3. Pestañas Principales Específicas
        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(side="top", fill="both", expand=True, padx=10, pady=4)

        # Tab 1: Editor de Ticket
        self.tab_editor = ttk.Frame(self.notebook, padding=6)
        self.notebook.add(self.tab_editor, text="  📝 Editor de Ticket  ")

        # Tab 2: Códigos QR
        self.tab_qr = ttk.Frame(self.notebook, padding=12)
        self.notebook.add(self.tab_qr, text="  📱 Generar QR  ")

        # Tab 3: Logos NV Flash
        self.tab_logos = ttk.Frame(self.notebook, padding=12)
        self.notebook.add(self.tab_logos, text="  🖼️ Logos Flash (320 KB)  ")

        # Tab 4: Cabezal y Kiosco
        self.tab_hardware = ttk.Frame(self.notebook, padding=12)
        self.notebook.add(self.tab_hardware, text="  ⚙️ Cabezal y Kiosco  ")

        # Construir contenido modular de cada tab
        self._construir_tab_editor()
        self._construir_tab_qr()
        self._construir_tab_logos()
        self._construir_tab_hardware()

    # =========================================================================
    # TAB 1: EDITOR DE TICKET WYSIWYG
    # =========================================================================
    def _construir_tab_editor(self):
        tools_frame = ttk.LabelFrame(self.tab_editor, text=" Formato y Estructura ", padding="6 4")
        tools_frame.pack(side="top", fill="x", pady=(0, 4))

        ttk.Button(tools_frame, text="Negrita", width=9, command=self.toggle_negrita).pack(side="left", padx=3)
        ttk.Button(tools_frame, text="Texto Grande", width=12, command=self.toggle_grande).pack(side="left", padx=3)

        ttk.Separator(tools_frame, orient="vertical").pack(side="left", fill="y", padx=6)

        ttk.Button(tools_frame, text="Izquierda", width=9, command=lambda: self.aplicar_alineacion("left")).pack(side="left", padx=2)
        ttk.Button(tools_frame, text="Centrar", width=9, command=lambda: self.aplicar_alineacion("center")).pack(side="left", padx=2)
        ttk.Button(tools_frame, text="Derecha", width=9, command=lambda: self.aplicar_alineacion("right")).pack(side="left", padx=2)

        ttk.Separator(tools_frame, orient="vertical").pack(side="left", fill="y", padx=6)

        ttk.Button(tools_frame, text="Alinear Columnas", command=self.auto_alinear_columnas).pack(side="left", padx=3)
        ttk.Button(tools_frame, text="Separador (---)", command=self.insertar_separador).pack(side="left", padx=3)
        ttk.Button(tools_frame, text="Limpiar", command=self.limpiar).pack(side="left", padx=3)

        # Contenedor centrado que emula la tira de 80mm
        paper_container = ttk.Frame(self.tab_editor)
        paper_container.pack(fill="both", expand=True)

        scroll_y = ttk.Scrollbar(paper_container, orient="vertical")
        scroll_y.pack(side="right", fill="y")

        self.font_normal = tkfont.Font(family="Courier 10 Pitch", size=11, weight="normal")
        self.font_bold = tkfont.Font(family="Courier 10 Pitch", size=11, weight="bold")
        self.font_big = tkfont.Font(family="Courier 10 Pitch", size=22, weight="normal")
        self.font_big_bold = tkfont.Font(family="Courier 10 Pitch", size=22, weight="bold")

        paper_body = tk.Frame(paper_container, bg="#dcdcdc", padx=2, pady=2)
        paper_body.pack(expand=True, fill="y")

        self.text_editor = tk.Text(
            paper_body,
            font=self.font_normal,
            wrap="char",
            width=42,
            height=13,
            padx=8,
            pady=8,
            yscrollcommand=scroll_y.set,
            background="#ffffff",
            foreground="#1e1e1e",
            highlightthickness=1,
            highlightbackground="#9e9e9e",
            highlightcolor="#2e7d32"
        )
        self.text_editor.pack(side="left", fill="both", expand=True)
        scroll_y.config(command=self.text_editor.yview)

        # Tags de formato visual
        self.text_editor.tag_configure("bold", font=self.font_bold, foreground="#0d47a1")
        self.text_editor.tag_configure("big", font=self.font_big, foreground="#1b5e20")
        self.text_editor.tag_configure("big_bold", font=self.font_big_bold, foreground="#b71c1c")

        # Eventos de tracking estricto de columna según tamaño
        self.text_editor.bind("<KeyRelease>", self._on_key_release)
        self.text_editor.bind("<ButtonRelease-1>", self._on_key_release)

        self._cargar_plantilla_inicial()

    # =========================================================================
    # TAB 2: GENERADOR QR
    # =========================================================================
    def _construir_tab_qr(self):
        qr_group = ttk.LabelFrame(self.tab_qr, text=" Generador e Impresor de Códigos QR ", padding=12)
        qr_group.pack(fill="x", pady=6)

        ttk.Label(qr_group, text="Impresión monocromática 1:1 mediante matriz compacta CP437 optimizada para el buffer de la NCR 7197.", foreground="#444").pack(anchor="w", pady=(0, 10))

        grid_f = ttk.Frame(qr_group)
        grid_f.pack(fill="x", pady=5)

        ttk.Label(grid_f, text="URL / Texto a codificar:", font=("Helvetica", 9, "bold")).grid(row=0, column=0, sticky="w", padx=4, pady=4)
        self.qr_url_entry = ttk.Entry(grid_f, width=45)
        self.qr_url_entry.grid(row=0, column=1, sticky="ew", padx=6, pady=4)
        self.qr_url_entry.insert(0, "https://github.com/jmrodev")

        ttk.Label(grid_f, text="Título en encabezado (opcional):").grid(row=1, column=0, sticky="w", padx=4, pady=4)
        self.qr_title_entry = ttk.Entry(grid_f, width=45)
        self.qr_title_entry.grid(row=1, column=1, sticky="ew", padx=6, pady=4)
        self.qr_title_entry.insert(0, "ESCANEA ESTE QR:")

        grid_f.columnconfigure(1, weight=1)

        ttk.Button(qr_group, text="📱 Imprimir Código QR Ahora", command=self._imprimir_qr_desde_tab).pack(anchor="e", pady=(12, 4))

    # =========================================================================
    # TAB 3: LOGOS FLASH (NV RAM)
    # =========================================================================
    def _construir_tab_logos(self):
        logo_group = ttk.LabelFrame(self.tab_logos, text=" Gestión de Almacenamiento NV Flash (320 KB) ", padding=12)
        logo_group.pack(fill="x", pady=6)

        ttk.Label(logo_group, text="Graba imágenes monocromáticas en la memoria permanente para imprimirlas instantáneamente sin saturar el bus.", foreground="#444").pack(anchor="w", pady=(0, 10))

        btns_f = ttk.Frame(logo_group)
        btns_f.pack(fill="x", pady=8)

        ttk.Button(btns_f, text="📂 Seleccionar y Flashear Imagen...", command=self._flashear_imagen_dialogo).pack(side="left", padx=6)
        ttk.Button(btns_f, text="🖨️ Probar Impresión de Logo NV (#1)", command=self.imprimir_logo_flash).pack(side="left", padx=6)

    # =========================================================================
    # TAB 4: CABEZAL Y KIOSCO
    # =========================================================================
    def _construir_tab_hardware(self):
        hw_group = ttk.LabelFrame(self.tab_hardware, text=" Diagnóstico y Control de Mecanismos ", padding=12)
        hw_group.pack(fill="x", pady=6)

        ttk.Label(hw_group, text="Comandos directos sobre la guillotina de corte, eyector del kiosco (Presenter) y autotest.", foreground="#444").pack(anchor="w", pady=(0, 10))

        btns_f = ttk.Frame(hw_group)
        btns_f.pack(fill="x", pady=8)

        ttk.Button(btns_f, text="✂️ Avanzar y Cortar Papel", command=self.cortar_solo).pack(side="left", padx=6)
        ttk.Button(btns_f, text="🧾 Imprimir Ticket Demostración", command=self._imprimir_ticket_demo).pack(side="left", padx=6)

    # =========================================================================
    # LOGICA DE FORMATO Y SALTO INTELIGENTE SEGUN FUENTE
    # =========================================================================
    def _get_max_cols_for_line(self, line_num):
        """Devuelve el límite físico real de columnas de la línea (21 si es grande, 42 normal)."""
        tags = self.text_editor.tag_names(f"{line_num}.0")
        return 21 if ("big" in tags or "big_bold" in tags) else 42

    def _on_key_release(self, event=None):
        cursor_pos = self.text_editor.index(tk.INSERT)
        line, col = cursor_pos.split(".")
        line_num = int(line)
        col = int(col)

        max_cols = self._get_max_cols_for_line(line_num)

        # Salto estricto de renglón si se supera el ancho físico de la fuente actual
        if event and event.char and event.char.isprintable() and col >= max_cols:
            self.text_editor.insert(tk.INSERT, "\n")
            line_num += 1
            col = 0

        self.status_lbl.config(
            text=f"Línea: {line_num} | Columna: {col}/{max_cols} {'(Fuente Grande)' if max_cols == 21 else '(Normal)'} {('⚠️ [LÍMITE ALCANZADO]' if col >= max_cols else '')}"
        )

    def _imprimir_qr_desde_tab(self):
        data = self.qr_url_entry.get().strip()
        title = self.qr_title_entry.get().strip()
        if not data:
            messagebox.showwarning("Atención", "El contenido del QR no puede estar vacío.")
            return
        self._imprimir_qr_worker(data, title)

    def _flashear_imagen_dialogo(self):
        path = filedialog.askopenfilename(
            title="Seleccionar Imagen para Memoria Flash",
            filetypes=[("Imágenes", "*.png *.jpg *.jpeg *.bmp"), ("Todos los archivos", "*.*")]
        )
        if not path:
            return
        logo_cmd = "/home/jmro/.local/bin/ncr-flash-logo"
        try:
            res = subprocess.run([logo_cmd, "flash", path, "--logo-num", "1"], capture_output=True, text=True)
            if res.returncode == 0:
                messagebox.showinfo("Éxito", "Imagen flasheada correctamente como Logo #1 en la memoria de la impresora.")
                self.set_status("Logo #1 grabado en Flash.")
            else:
                messagebox.showerror("Error al Flashear", res.stderr or "Fallo en ncr-flash-logo")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def _imprimir_ticket_demo(self):
        print_cmd = "/home/jmro/.local/bin/ncr-print"
        subprocess.run([print_cmd, "--demo"])
        self.set_status("Ticket demo enviado.")

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
        self.text_editor.tag_add("bold", "2.0", "2.end")
        self.text_editor.tag_add("bold", "7.0", "7.end")

    def set_status(self, msg, error=False):
        self.status_lbl.config(text=msg, foreground="#b71c1c" if error else "#2e7d32")

    def limpiar(self):
        self.text_editor.delete("1.0", tk.END)
        self.set_status("Editor limpio.")

    def insertar_separador(self):
        self.text_editor.insert(tk.INSERT, "------------------------------------------\n")

    def aplicar_alineacion(self, align_type):
        try:
            start_idx = self.text_editor.index("sel.first")
            end_idx = self.text_editor.index("sel.last")
            first_line = int(start_idx.split(".")[0])
            last_line = int(end_idx.split(".")[0])
        except tk.TclError:
            first_line = int(self.text_editor.index("insert").split(".")[0])
            last_line = first_line

        for line_num in range(first_line, last_line + 1):
            line_start = f"{line_num}.0"
            line_end = f"{line_num}.end"
            texto = self.text_editor.get(line_start, line_end)
            
            ancho_max = self._get_max_cols_for_line(line_num)
            limpio = texto.strip()
            if not limpio:
                continue

            if align_type == "center":
                nuevo_texto = limpio.center(ancho_max) if len(limpio) < ancho_max else limpio
            elif align_type == "right":
                nuevo_texto = limpio.rjust(ancho_max) if len(limpio) < ancho_max else limpio
            else:
                nuevo_texto = limpio

            self.text_editor.delete(line_start, line_end)
            self.text_editor.insert(line_start, nuevo_texto)

        self.set_status(f"Líneas alineadas a la {align_type.upper()}.")

    def toggle_negrita(self):
        try:
            start = self.text_editor.index("sel.first")
            end = self.text_editor.index("sel.last")
        except tk.TclError:
            start = self.text_editor.index("insert linestart")
            end = self.text_editor.index("insert lineend")

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
        try:
            start = self.text_editor.index("sel.first")
            end = self.text_editor.index("sel.last")
        except tk.TclError:
            start = self.text_editor.index("insert linestart")
            end = self.text_editor.index("insert lineend")

        tags = self.text_editor.tag_names(start)
        first_line = int(start.split(".")[0])
        last_line = int(end.split(".")[0])

        if "big" in tags or "big_bold" in tags:
            self.text_editor.tag_remove("big", start, end)
            if "big_bold" in tags:
                self.text_editor.tag_remove("big_bold", start, end)
                self.text_editor.tag_add("bold", start, end)
            self.set_status("Tamaño normal restablecido (42 columnas).")
        else:
            if "bold" in tags:
                self.text_editor.tag_remove("bold", start, end)
                self.text_editor.tag_add("big_bold", start, end)
            else:
                self.text_editor.tag_add("big", start, end)
            
            # Al pasar a grande, reajustar si alguna línea supera las 21 columnas
            for l in range(first_line, last_line + 1):
                txt = self.text_editor.get(f"{l}.0", f"{l}.end")
                if len(txt) > 21:
                    partes = [txt[i:i+21] for i in range(0, len(txt), 21)]
                    self.text_editor.delete(f"{l}.0", f"{l}.end")
                    self.text_editor.insert(f"{l}.0", "\n".join(partes))
            self.set_status("Texto grande aplicado (Límite ajustado a 21 columnas).")

    def auto_alinear_columnas(self):
        """Alinea columnas dividiendo texto con tabulaciones o espacios según el ancho de fuente de cada línea."""
        total_lines = int(self.text_editor.index("end-1c").split(".")[0])
        for line_num in range(1, total_lines + 1):
            line_start = f"{line_num}.0"
            line_end = f"{line_num}.end"
            linea = self.text_editor.get(line_start, line_end)
            
            ancho_max = self._get_max_cols_for_line(line_num)
            
            if "\t" in linea:
                partes = linea.split("\t", 1)
            elif "  " in linea and not linea.strip().startswith("-") and not linea.strip().startswith("="):
                partes = linea.rsplit("  ", 1)
            else:
                continue
            
            if len(partes) == 2:
                izq = partes[0].strip()
                der = partes[1].strip()
                espacios = ancho_max - len(izq) - len(der)
                if espacios > 0:
                    nueva_linea = izq + (" " * espacios) + der
                    self.text_editor.delete(line_start, line_end)
                    self.text_editor.insert(line_start, nueva_linea)

        self.set_status("Columnas auto-alineadas respetando el tamaño de fuente de cada línea.")

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
        Construye el payload binario ESC/POS dividiendo físicamente las líneas
        según el ancho de fuente (21 columnas para grande, 42 para normal)
        garantizando que la tira de papel impresa sea IDÉNTICA a la vista previa.
        """
        payload = INIT
        total_lines = int(self.text_editor.index("end-1c").split(".")[0])

        for line_num in range(1, total_lines + 1):
            line_start = f"{line_num}.0"
            line_end = f"{line_num}.end"
            texto_linea = self.text_editor.get(line_start, line_end)

            tags = self.text_editor.tag_names(line_start)
            is_bold = ("bold" in tags or "big_bold" in tags)
            is_big = ("big" in tags or "big_bold" in tags)

            font_byte = 0
            max_c = 42
            if is_bold:
                font_byte |= 0x08
            if is_big:
                font_byte |= 0x30
                max_c = 21

            cmd_font = ESC + b"!" + bytes([font_byte])
            cmd_bold_extra = (ESC + b"E\x01" + ESC + b"G\x01") if is_bold else (ESC + b"E\x00" + ESC + b"G\x00")
            cmd_style = cmd_font + cmd_bold_extra

            # División de seguridad si la línea excede el ancho físico
            if len(texto_linea) > max_c:
                sublineas = [texto_linea[i:i+max_c] for i in range(0, len(texto_linea), max_c)]
            else:
                sublineas = [texto_linea]

            for sub in sublineas:
                payload += ALIGN_LEFT + cmd_style + sub.encode('latin1', errors='replace') + b"\r\n"

        # Avance para módulo Presenter (8 líneas) y corte limpio
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

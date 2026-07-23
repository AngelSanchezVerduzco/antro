"""Genera PDFs desde los markdown de las prácticas."""
import base64
import mimetypes
import re
from pathlib import Path
from urllib.parse import unquote

import markdown
from xhtml2pdf import pisa

DOCS = Path(__file__).parent
FILES = [
    ("PRACTICA_9_WIDGET_SMART_TV.md", "PRACTICA_9_WIDGET_SMART_TV.pdf"),
    ("PRACTICA_10_BASE_DATOS.md", "PRACTICA_10_BASE_DATOS.pdf"),
    ("PRACTICA_12_SEGURIDAD_SMARTWATCH.md", "PRACTICA_12_SEGURIDAD_SMARTWATCH.pdf"),
    ("PRACTICA_13_CUENTAS_USUARIO.md", "PRACTICA_13_CUENTAS_USUARIO.pdf"),
]

CSS = """
@page { size: A4; margin: 2cm; }
body { font-family: Helvetica, Arial, sans-serif; font-size: 11pt; line-height: 1.45; color: #1a1a1a; }
h1 { font-size: 20pt; color: #5B21B6; border-bottom: 2px solid #5B21B6; padding-bottom: 6px; margin-top: 24px; }
h2 { font-size: 14pt; color: #5B21B6; margin-top: 20px; }
h3 { font-size: 12pt; color: #333; margin-top: 16px; }
code, pre { background: #f4f4f4; font-size: 9pt; }
pre { padding: 10px; white-space: pre-wrap; word-wrap: break-word; }
table { border-collapse: collapse; width: 100%; margin: 12px 0; font-size: 10pt; }
th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
th { background: #ede9fe; }
hr { border: none; border-top: 1px solid #ddd; margin: 20px 0; }
ul { margin: 8px 0; }
li { margin: 4px 0; }
img { width: 100%; height: auto; margin: 8px 0; }
.evidence { page-break-inside: avoid; margin: 14px 0 20px; }
.evidence p { font-size: 9pt; color: #555; margin-top: 4px; }
"""

def embed_local_images(html: str) -> str:
    """Convierte imágenes file:/// a data URI para que xhtml2pdf las incluya."""
    def replace(match: re.Match[str]) -> str:
        raw_path = unquote(match.group(1))
        image_path = Path(raw_path)
        if not image_path.exists():
            return match.group(0)

        mime = mimetypes.guess_type(image_path.name)[0] or "image/png"
        encoded = base64.b64encode(image_path.read_bytes()).decode("ascii")
        return f'src="data:{mime};base64,{encoded}"'

    return re.sub(r'src="file:///([^"]+)"', replace, html)


def md_to_pdf(md_name: str, pdf_name: str) -> None:
    md_path = DOCS / md_name
    pdf_path = DOCS / pdf_name
    md_text = md_path.read_text(encoding="utf-8")
    html_body = markdown.markdown(md_text, extensions=["tables", "fenced_code"])
    html_body = embed_local_images(html_body)
    html = f"""<!DOCTYPE html>
<html lang="es">
<head><meta charset="utf-8"/><style>{CSS}</style></head>
<body>{html_body}</body>
</html>"""
    with open(pdf_path, "wb") as out:
        status = pisa.CreatePDF(html.encode("utf-8"), dest=out, encoding="utf-8")
    if status.err:
        raise RuntimeError(f"Error generando {pdf_name}")
    print(f"OK: {pdf_path}")


if __name__ == "__main__":
    for md, pdf in FILES:
        md_to_pdf(md, pdf)

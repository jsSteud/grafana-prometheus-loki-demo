# Verwenden des offiziellen Python-Images als Basis
FROM python:3.10-slim

# Setzen des Arbeitsverzeichnisses im Container
WORKDIR /app

# Kopieren der Abhängigkeitsdateien in das Container-Verzeichnis
COPY requirements.txt .

# Installieren der Python-Abhängigkeiten
RUN pip install --no-cache-dir -r requirements.txt

# Kopieren des Quellcodes in das Container-Verzeichnis
COPY . .

# Festlegen der Umgebungsvariablen
# Deaktiviert die Python-Pufferung, damit die Logs direkt in die Konsole fließen
ENV PYTHONUNBUFFERED=1

# Uvicorn für Produktionsumgebungen
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]

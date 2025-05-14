# Utiliser une image officielle Python
FROM python:3.11-slim

# Définir un dossier de travail
WORKDIR /app

# Copier seulement requirements.txt d'abord
COPY requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier tout sauf venv/
COPY . .

# Exposer le port
EXPOSE 8000

# Lancer le serveur Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Usar uma imagem base do Python
FROM python:3.8-slim

WORKDIR /app

# Instalar dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o código fonte
COPY python_app.py .

# Definir a variável de ambiente do Google Cloud (chave de autenticação)
ENV GOOGLE_APPLICATION_CREDENTIALS="/app/key.json"

# Comando de inicialização do aplicativo
CMD ["python", "python_app.py"]

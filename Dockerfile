FROM python:3.11-slim

# System dependencies required by SimpleITK / PyRadiomics / opencv-headless
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

COPY . .

# Runtime directories (mounted as volumes in docker-compose for persistence
# of logs only -- patient data is never persisted, see src/privacy).
RUN mkdir -p runtime/uploads runtime/results models data/raw data/processed data/metadata reports

EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s CMD \
    python -c "import urllib.request; urllib.request.urlopen('http://localhost:8501/_stcore/health')" || exit 1

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]

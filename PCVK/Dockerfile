FROM python:3.9-slim

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y \
    libgomp1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup User (Langsung di awal agar rapi)
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# 3. Set Workdir
WORKDIR $HOME/app

# 4. Copy & Install Requirements
# (Copy file saja dulu agar cache docker optimal)
COPY --chown=user ./requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copy Sisa Kode
COPY --chown=user . .

# 6. Jalankan
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
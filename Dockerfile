# ==========================================
# STAGE 1: Builder
# ==========================================
FROM python:3.10-slim AS builder

RUN apt-get update && apt-get install -y \
    gcc build-essential libxml2-dev libxslt1-dev libffi-dev \
    libpq-dev libssl-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY app/requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ==========================================
# STAGE 2: Final
# ==========================================
FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    libpq5 libxml2 \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --system status-page && adduser --system --ingroup status-page status-page

WORKDIR /opt/status-page

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY app/ .

RUN SECRET_KEY=dummy-key-for-build python statuspage/manage.py collectstatic --noinput

RUN chown -R status-page:status-page /opt/status-page

USER status-page

EXPOSE 8001

CMD ["gunicorn", "--chdir", "/opt/status-page/statuspage", "-b", "0.0.0.0:8001", "-c", "/opt/status-page/contrib/gunicorn.py", "statuspage.wsgi"]
	

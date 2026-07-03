FROM python:3.12-slim

# Prevents Python from buffering stdout/stderr — logs show up immediately in `docker logs`
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Bake static files into the image at build time
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Gunicorn is the production server — Django's runserver is dev-only
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2"]

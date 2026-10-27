FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=5000

WORKDIR /app
COPY app/app.py .

# Run as an unprivileged user
RUN useradd --system --uid 10001 --no-create-home appuser
USER 10001

EXPOSE 5000
CMD ["python", "app.py"]

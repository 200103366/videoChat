FROM python:3.9.5-slim as python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"
ENV WAIT_VERSION=2.7.2

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait /wait
RUN chmod +x /wait

FROM python-base as builder-base

RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    build-essential

WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

RUN pip install poetry
RUN poetry config virtualenvs.create false && poetry install --no-root

COPY . /app
WORKDIR /app

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000","python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

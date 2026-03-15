# prepare dependency
FROM python:3.11.10-bookworm AS stage1

##prepare poetry for dependency install
RUN pip install poetry==1.8.5

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY ["pyproject.toml", "poetry.lock", "./"]

## install runtime dependency only
RUN poetry install --only main --no-root && rm -rf $POETRY_CACHE_DIR


# build final image using slim version
FROM python:3.11.10-bookworm AS stage2

ENV VIRTUAL_ENV="/app/.venv" \
    PATH="/app/.venv/bin:${PATH}" \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /app

## copy runtime dependency from stage1
COPY --from=stage1 ["${VIRTUAL_ENV}", "${VIRTUAL_ENV}"]

## copy project python
COPY ["main.py", "./"]

## use CMD for future override when needed
CMD ["python", "main.py"]
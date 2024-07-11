ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim

# avoid .pyc and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# add non-root user
ARG UID=1000
RUN adduser \
    --disabled-password \
    --no-create-home \
    --uid "${UID}" \
    --home "/app" \
    bot

# prepare directories
RUN mkdir /config /app
RUN chown -R bot:bot /config /app
WORKDIR /app

# install requirements
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip install -r requirements.txt

# copy default configs
COPY config.toml config_env_mapping.toml /config
VOLUME /config

# copy sources and install project
COPY pyproject.toml .
COPY src src
RUN pip install .

# set defaults for bot configuration
ENV STATE_STORAGE_TYPE=memory

USER bot

CMD ["launch-polling", "-e", "-m", "/config/config_env_mapping.toml", "/config/config.toml"]

<br/><br/><br/>

# 容器映像檔(container image)
 - 定義靜態環境，包含:
   - 檔案
   - 環境變數
   - metadata: entrypoint, command(arguments of entrypoint), working directory, user, exposed ports, label, architecture
 - [Layered content](https://hub.docker.com/layers/library/nginx/1.27.4-bookworm-perl/images/sha256-968d95f36195ff25cbaaffba598bec1319b58bf3896415a50bdefab854e9abc1): 類似git log，但看起來像命令式(imperative)
 - 遵循[開放標準](https://specs.opencontainers.org/image-spec/)

<br/>

# Dockerfile
 - 誰負責維護? developer or devops ?
```yaml
# prepare dependency
FROM python:3.10.12-bookworm AS stage1

##prepare poetry for dependency install
RUN pip install poetry==2.1.1

## keep virtual environment directory '.venv' in project directory
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY ["pyproject.toml", "poetry.lock", "./"]

## install runtime dependency only
RUN poetry install --verbose && rm -rf $POETRY_CACHE_DIR



# build final image using cuda image
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04 AS stage2
ARG BUILD_BY=manual
LABEL build-by=${BUILD_BY}

ENV VIRTUAL_ENV="/app/.venv" \
    CUDA_HOME="/usr/local/cuda"

ENV PATH="${VIRTUAL_ENV}/bin:${CUDA_HOME}/bin:${PATH}" \
    LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

# Add build arguments for the custom APT repository and User-Agent
ARG APT_REPO_URL
ARG APT_USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

WORKDIR /app

## copy runtime dependency from stage1
COPY --from=stage1 ["${VIRTUAL_ENV}", "${VIRTUAL_ENV}"]

## copy project python
COPY ["OCRServer.py", "./"]

## Update the package index and install the required packages in a single layer
## Todo: change to install specific python version
RUN if [ -n "$APT_REPO_URL" ]; then \
        echo "deb ${APT_REPO_URL} jammy main restricted universe multiverse" > /etc/apt/sources.list && \
        echo "deb ${APT_REPO_URL} jammy-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    fi && \
    if [ -n "$APT_USER_AGENT" ]; then \
        echo "Acquire::http::User-Agent \"${APT_USER_AGENT}\";" > /etc/apt/apt.conf.d/99custom-user-agent; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python-is-python3 libgl1 libgomp1 libglib2.0-0 poppler-utils nano && \
    ln -sf /usr/bin/python /app/.venv/bin/python && \
    ln -sf /usr/lib/x86_64-linux-gnu/libcudnn.so.9 /usr/lib/x86_64-linux-gnu/libcudnn.so && \
    ln -sf /usr/local/cuda/lib64/libcublas.so.12 /usr/local/cuda/lib64/libcublas.so && \
    rm -rf /var/lib/apt/lists/*

## use CMD for future override when needed
CMD ["python", "OCRServer.py"]
```
 - 在執行 `docker build -t <image_name>:<image_tag> .` 前需注意 `.` 的部份
 - 盡量減少layer數量及大小
 - 加速image建置: multi-stages、將常變的部份往後移 

<br/><br/><br/>
<div style="display: flex; justify-content: space-between;">
  <a href="02_容器內外的雙重人格：容器看不到，本機說有.md">容器內外的雙重人格：容器看不到，本機說有</a>　　　　　　　　　　　　　　　　　　　　　　　　　　
  <a href="04_不要停：自從容器啟動的那天，我的CPU再也沒睡著過.md">不要停：自從容器啟動的那天，我的CPU再也沒睡著過</a>
</div>
ARG BUILDER_IMAGE
FROM ${BUILDER_IMAGE} as builder

FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ARG TZ
ARG USERNAME=hoge
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV TZ=${TZ}
ENV TERM=linux
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONUTF8=1 \
  PIP_NO_CACHE_DIR=on \
  PIP_DISABLE_PIP_VERSION_CHECK=on

RUN \
    if [ "$TZ" = "Asia/Tokyo" ]; then sed -i '/^deb/{s/ [^ ]*/ http:\/\/free.nchc.org.tw\/ubuntu\//1}' /etc/apt/sources.list ;fi \
    && apt-get update --fix-missing \
    && apt-get install -yq --no-install-recommends \
        google-perftools \
        python3 \
        python3-pip \
        libgl1 \
        libglib2.0-0 \
        git \
    && apt-get autoremove -yq \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* \
    && groupadd --gid $USER_GID $USERNAME \
       && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

COPY --chown=$USERNAME:$USERNAME --from=builder /usr/local/lib/python3.10/dist-packages/ /usr/local/lib/python3.10/dist-packages
# .local folder contains pip installed folder
COPY --chown=$USERNAME:$USERNAME --from=builder /home/$USERNAME/.local/ /home/$USERNAME/.local
COPY --chown=$USERNAME:$USERNAME cache/ /home/$USERNAME/.cache
COPY --chown=$USERNAME:$USERNAME --from=builder /home/$USERNAME/stable-diffusion-webui/ /home/$USERNAME/stable-diffusion-webui

WORKDIR /home/$USERNAME/stable-diffusion-webui
USER $USERNAME

ARG COMMANDLINE_ARGS
ARG venv_dir
ARG GCS_WEIGHT_ROOT_PATH
ARG GCS_WEIGHT_NAME
ENV COMMANDLINE_ARGS=${COMMANDLINE_ARGS} \
    venv_dir=${venv_dir} \
    GCS_WEIGHT_ROOT_PATH=${GCS_WEIGHT_ROOT_PATH} \
    GCS_WEIGHT_NAME=${GCS_WEIGHT_NAME}

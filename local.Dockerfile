FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

ARG TZ
ARG USERNAME=hoge
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV TZ ${TZ}
ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONUTF8=1 \
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
    && apt-get autoremove -yq \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* \
    && groupadd --gid $USER_GID $USERNAME \
       && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN \
    apt-get update --fix-missing \
    && apt-get install -yq --no-install-recommends git vim \
    && apt-get clean \
    && pip install packaging google-cloud-storage \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/*

COPY --chown=$USERNAME:$USERNAME . /home/$USERNAME/stable-diffusion-webui

WORKDIR /home/$USERNAME/stable-diffusion-webui
USER $USERNAME
ARG BUILD_COMMANDLINE_ARGS=""
RUN --mount=type=cache,target=/home/${USERNAME}/.cache,uid=${USER_UID},gid=${USER_GID} \
    mkdir .git \
    && COMMANDLINE_ARGS="${BUILD_COMMANDLINE_ARGS}" venv_dir="-" ./webui.sh \
    && rm -rf repositories/stable-diffusion-stability-ai/assets \
    /home/${USERNAME}/.local/lib/python3.10/site-packages/llvmlite \
    /home/${USERNAME}/.local/lib/python3.10/site-packages/triton \
    /home/${USERNAME}/.local/lib/python3.10/site-packages/torch/lib/libcublasLt.so.11 \
    /home/${USERNAME}/.local/lib/python3.10/site-packages/torch/lib/libtorch_cuda_linalg.so \
    /home/${USERNAME}/.local/lib/python3.10/site-packages/torch/lib/*train.so.8

#! /bin/bash
set -Ceu

declare -A arr

export $(cat .env| grep -vE "(#|ARGS|PROMPT)" | xargs)

if [[ ! -z "${CKPT_URL}" ]]; then
  # models
  arr["${CKPT_URL}"]="models/Stable-diffusion"

  if [[ ! -z "${EMBEDDINGS_URL}" ]]; then
    # embeddings
    arr+=(["${EMBEDDINGS_URL}"]="embeddings")
  fi

  for key in ${!arr[@]}; do
    mkdir -p "${arr[${key}]}"
    download_to="${arr[${key}]}"/$(basename "${key}")
    if [ ! -f "$download_to" ]; then
      echo "Download ${key} to ${arr[${key}]}"
      curl -Lo "$download_to" "${key}"
    fi
  done
fi

if [[ ! -z "$CONTROLNET_MODEL" ]]; then
  mkdir -p "controlnet"
  for c_model in $(echo $CONTROLNET_MODEL | sed "s/,/ /g"); do

    if [ "$c_model" = "ip2p" ] || [ "$c_model" = "shuffle" ]; then
      controlnet_name="control_v11e_sd15_${c_model}.pth"
    elif [ "$c_model" = "tile" ]; then
      controlnet_name="control_v11f1e_sd15_${c_model}.pth"
    elif [ "$c_model" = "depth" ]; then
      controlnet_name="control_v11f1p_sd15_${c_model}.pth"
    # if c_model in [tile, depth, canny, inpaint, lineart, mlsd, normalbae, openpose, scribble, seg, softedge]
    elif [ "$c_model" = "canny" ] || [ "$c_model" = "inpaint" ] || [ "$c_model" = "lineart" ] || [ "$c_model" = "mlsd" ] || [ "$c_model" = "normalbae" ] || [ "$c_model" = "openpose" ] || [ "$c_model" = "scribble" ] || [ "$c_model" = "seg" ] || [ "$c_model" = "softedge" ]; then
      controlnet_name="control_v11p_sd15_${c_model}.pth"
    elif [ "$c_model" = "lineart_anime" ]; then
      controlnet_name="control_v11p_sd15s2_${c_model}.pth"
    fi

    download_to="controlnet/${controlnet_name}"

    if [ ! -f "$download_to" ]; then
      echo "Download ${c_model} to controlnet/${c_model}"
      curl -Lo "$download_to" "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/${controlnet_name}"
    fi
  done
fi

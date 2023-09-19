import os
import time
from pathlib import Path

from google.cloud import storage

client = None
try:
    client = storage.Client()
except Exception:
    client = storage.Client.from_service_account_json(
        os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    )

gcs_bucket_name = os.environ.get("GCS_BUCKET_NAME")
gcs_weight_root_path = os.environ.get("GCS_WEIGHT_ROOT_PATH")
gcs_weight_name = os.environ.get("GCS_WEIGHT_NAME")
gcs_bucket = client.bucket(gcs_bucket_name)


def download_weight(name, destination_dir):
    start_time = time.time()
    print("download weight start: ", name)
    destination_file_path = Path(destination_dir) / f"{name}.safetensors"
    if destination_file_path.exists():
        return

    blob = gcs_bucket.blob(f"{gcs_weight_root_path}/{name.replace('_', '/')}/{gcs_weight_name}")
    if not blob.exists():
        raise FileNotFoundError('LoraNotFound: ', name)

    blob.download_to_filename(str(destination_file_path))
    print(f"{time.time() - start_time} [sec] elasped")

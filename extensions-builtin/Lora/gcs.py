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
gcs_file_max_count = int(os.environ.get("GCS_FILE_MAX_COUNT", 0))
print("GCS_BUCKET_NAME: ", gcs_bucket_name)
gcs_bucket = client.bucket(gcs_bucket_name)


def download_weight(name, destination_dir):
    start_time = time.time()
    print("download weight start: ", name)
    destination_file_path = Path(destination_dir) / f"{name}.safetensors"
    if destination_file_path.exists():
        return

    if gcs_file_max_count > 0:
        files = list(Path(destination_dir).glob("*.safetensors"))
        if len(files) >= gcs_file_max_count:
            files_sorted_by_mtime = sorted(files, key=lambda x: os.path.getmtime(x))
            os.remove(files_sorted_by_mtime[0])
            print("remove weight: ", files_sorted_by_mtime[0])

    blob = gcs_bucket.blob(
        f"{gcs_weight_root_path}/{name.replace('_', '/')}/{gcs_weight_name}"
    )
    if not blob.exists():
        raise FileNotFoundError("LoraNotFound: ", name)

    blob.download_to_filename(str(destination_file_path))
    print(f"{time.time() - start_time} [sec] elasped")

import base64
import io
import os

import requests
from PIL import Image, PngImagePlugin

url = f"http://127.0.0.1:{os.environ.get('PORT')}"

payload = {
    "prompt": os.environ.get("TEST_PROMPT"),
    "steps": 20,
}
print(url, payload)

response = requests.post(url=f"{url}/sdapi/v1/txt2img", json=payload)

r = response.json()

for i in r["images"]:
    image = Image.open(io.BytesIO(base64.b64decode(i.split(",", 1)[0])))
    png_payload = {"image": "data:image/png;base64," + i}
    response2 = requests.post(url=f"{url}/sdapi/v1/png-info", json=png_payload)

    pnginfo = PngImagePlugin.PngInfo()
    pnginfo.add_text("parameters", response2.json().get("info"))
    image.save("output.png", pnginfo=pnginfo)

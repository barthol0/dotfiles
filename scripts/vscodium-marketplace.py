import json
import os


# VSCodiumProductPath = "/usr/share/vscodium-bin/resources/app/product.json"
VSCodiumProductPath = "/opt/vscodium-bin/resources/app/product.json"
service_url = "https://marketplace.visualstudio.com/_apis/public/gallery"
item_url = "https://marketplace.visualstudio.com/items"

if not os.path.exists(VSCodiumProductPath) or not os.access(VSCodiumProductPath, os.W_OK):
    print(
        "ERROR: Insuficient permissions or did not find VSCode Product file:",
        VSCodiumProductPath,
    )
    exit(1)

with open(VSCodiumProductPath, "r") as f:
    data = json.load(f)
    data["extensionsGallery"]["serviceUrl"] = service_url
    data["extensionsGallery"]["itemUrl"] = item_url
os.remove(VSCodiumProductPath)

with open(VSCodiumProductPath, "w") as f:
    json.dump(data, f, indent=4)

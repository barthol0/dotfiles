import json
import os

# Installed via:

# Package manager - i.e. apt
VSCodiumProductPath = "/usr/share/codium/resources/app/product.json"

# Flatpak:
# VSCodiumProductPath = "~/.local/share/flatpak/app/com.vscodium.codium-insiders/x86_64/stable/1234567890/files/share/codium-insiders/resources/app/product.json"
# VSCodiumProductPath = "~/.local/share/flatpak/app/com.vscodium.codium/x86_64/stable/1234567890/files/share/codium/resources/app/product.json"

# Find product.json file
# sudo find ~/ -name product.json
# sudo find / -name product.json

service_url = "https://marketplace.visualstudio.com/_apis/public/gallery"
item_url = "https://marketplace.visualstudio.com/items"

if not os.path.exists(VSCodiumProductPath) or not os.access(
    VSCodiumProductPath, os.W_OK
):
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

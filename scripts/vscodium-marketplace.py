import json
import os

# Installed via:

# Package manager - i.e. apt
# VSCodiumProductPath = "/usr/share/codium/resources/app/product.json"
VSCodiumProductPath = "/opt/vscodium-bin/resources/app/product.json"

# Flatpak:
# VSCodiumProductPath = "~/.local/share/flatpak/app/com.vscodium.codium-insiders/x86_64/stable/1234567890/files/share/codium-insiders/resources/app/product.json"
# VSCodiumProductPath = "~/.local/share/flatpak/app/com.vscodium.codium/x86_64/stable/1234567890/files/share/codium/resources/app/product.json"

# Find product.json file
# sudo find ~/ -name product.json
# sudo find / -name product.json

# "extensionsGallery": {
# 		"nlsBaseUrl": "https://www.vscode-unpkg.net/_lp/",
# 		"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
# 		"itemUrl": "https://marketplace.visualstudio.com/items",
# 		"publisherUrl": "https://marketplace.visualstudio.com/publishers",
# 		"resourceUrlTemplate": "https://{publisher}.vscode-unpkg.net/{publisher}/{name}/{version}/{path}",
# 		"extensionUrlTemplate": "https://www.vscode-unpkg.net/_gallery/{publisher}/{name}/latest",
# 		"controlUrl": "https://main.vscode-cdn.net/extensions/marketplace.json"
# 	},


service_url = "https://marketplace.visualstudio.com/_apis/public/gallery"
item_url = "https://marketplace.visualstudio.com/items"
extension_url_template = "https://www.vscode-unpkg.net/_gallery/{publisher}/{name}/latest"

# OPEN-VSX 
# service_url = "https://open-vsx.org/vscode/gallery"
# item_url = "https://open-vsx.org/vscode/item"
# extension_url_template = (
#     "https://open-vsx.org/vscode/gallery/{publisher}/{name}/{version}"
# )

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
    data["extensionsGallery"]["extensionUrlTemplate"] = extension_url_template
os.remove(VSCodiumProductPath)

with open(VSCodiumProductPath, "w") as f:
    json.dump(data, f, indent=4)

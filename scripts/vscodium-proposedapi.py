import os
import json
from pprint import pprint

VSCodiumProductPath = "/usr/share/vscodium-bin/resources/app/product.json"

if not os.path.exists(VSCodiumProductPath) or not os.access(VSCodiumProductPath, os.W_OK):
    print(
        "ERROR: Insuficient permissions or did not find VSCode Product file:",
        VSCodiumProductPath,
    )
    exit(1)

VSCodeProduct = open(VSCodiumProductPath, "r")
data = json.load(VSCodeProduct)

# We need to ensure the extensionAllowedProposedApi has the following array:
extensionsToAdd = [
    # "ms-vsliveshare.vsliveshare",
    # "ms-vscode.node-debug",
    # "ms-vscode.node-debug2",
    "ms-toolsai.jupyter",
]
print("Before:")
pprint(data["extensionAllowedProposedApi"])

for extension in extensionsToAdd:
    if extension not in data["extensionAllowedProposedApi"]:
        data["extensionAllowedProposedApi"].append(extension)
print("------------------------------")
print("After:")
pprint(data["extensionAllowedProposedApi"])
print("Rewriting to file:", VSCodiumProductPath)

VSCodeProduct = open(VSCodiumProductPath, "w")
json.dump(data, VSCodeProduct, indent=4)

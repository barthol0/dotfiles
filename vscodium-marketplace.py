import json
import os


filename_path = '/usr/share/vscodium-bin/resources/app/product.json'
service_url = "https://marketplace.visualstudio.com/_apis/public/gallery"
item_url = "https://marketplace.visualstudio.com/items"

with open(filename_path, 'r') as f:
    data = json.load(f)
    data['extensionsGallery']['serviceUrl'] = service_url
    data['extensionsGallery']['itemUrl'] = item_url
os.remove(filename_path)

with open(filename_path, 'w') as f:
    json.dump(data, f, indent=4)
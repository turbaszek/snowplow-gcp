import os
from time import sleep
import requests

collector_uri = os.getenv("COLLECTOR_URI")
url = collector_uri if collector_uri.startswith("http") else f"http://{collector_uri}/i"
print(f"Checking collector state under: {url}")

for i in range(10):
    print("Ping: ", i + 1)
    response = requests.get(url)
    if response.status_code != 200:
        raise Exception(
            f"Request failed with code: {response.status_code}, {response.content}"
        )
    sleep(2)

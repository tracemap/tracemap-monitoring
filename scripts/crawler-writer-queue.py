#!/usr/bin/python3
import os
import json
import time
import datetime

input_dirpath = "/usr/local/bin/tracemap/tracemap-backend/crawler/temp/"
output_dirpath = "/usr/local/bin/tracemap/tracemap-monitoring/logs/"

while True:
    num_files = 0
    num_ids = 0

    for file in os.listdir(input_dirpath):
        if "save.txt" in file:
            try:
                num_files += 1
                with open(input_dirpath + file) as f:
                    content = f.readlines()
                    num_ids += (len(content) - 1) + content[-1].count(",") + 1
            except FileNotFoundError:
                continue

    response = {"service":"Crawler Writer Queue","num_files":num_files, "num_user_ids": num_ids, "datetime": datetime.datetime.now().isoformat()}

    with open(output_dirpath + "crawler-writer-queue.jsonl", "a") as output_file:
        output_file.write(json.dumps(response) + "\n")
    time.sleep(60)

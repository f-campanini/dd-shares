import json
import random
import datetime
from time import sleep
import submit_logs
import csv
import random

# log example
# [Fri, 29 Mar 2019 12:00:57 -0700] {some JSON} [user2]

FILENAME="export_data.csv"

log_string = "[{date}] {json_string} [{username}]"


def get_sec(time_str):
    """Get seconds from time."""
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + int(s)


def generate_timestamp():
	d = datetime.datetime.now(datetime.timezone.utc).astimezone()
	ts = d.strftime("%a, %d %b %Y %H:%M:%S %z")
	return ts


def read_csv_file(filename):
    with open(filename) as f:
        reader = csv.DictReader(f)
        csv_as_list = list(reader)
    # remove any unwanted keys from the list of dictionaries
    list_without_timestamp = [{k: v for k, v in d.items() if k != 'timestamp'} for d in csv_as_list]
    return list_without_timestamp


def read_json_file(filename):
    # Opening JSON file
    f = open(filename)
    # returns JSON object as 
    # a dictionary
    data = json.load(f)
    # Closing file
    f.close()
    return data


def generate_log(my_data):
    for key, value in my_data.items():
        if key == "TotalDuration":
            my_data[key] = get_sec(value)
        elif key == "saveDuration":
            my_data[key] = get_sec(value)
        elif key == "refreshDuration":
            my_data[key] = get_sec(value)
        elif key == "copyConfigDuration":
            my_data[key] = get_sec(value)
    ts = generate_timestamp()
    json_string = json.dumps(my_data)
    username = "user{0}".format(random.randint(1,15))
    return log_string.format(date=ts, json_string=json_string, username=username)

data = read_csv_file(FILENAME)

list_length = len(data)

max = random.randint(1, list_length)

print(max)

for count, value in enumerate(data):
    submit_logs.send_log(generate_log(value))
    sleep(5)
    if count > max:
        break

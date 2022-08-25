import os
import requests

DD_API_KEY = os.environ.get('DD_API_KEY')
if not DD_API_KEY:
	print('Must have DD_API_KEY set')
	exit()

DD_SOURCE = "myapp"

dd_url = "https://http-intake.logs.datadoghq.com/v1/input/{DD_API_KEY}".format(DD_API_KEY=DD_API_KEY)
HEADERS = {'Content-Type': 'text/plain'}

def send_log(log, source=DD_SOURCE):
	print('Sending log: %s' % log)
	url = dd_url + "?ddsource={source}".format(source=source)
	r = requests.post(url, data=log, headers=HEADERS)
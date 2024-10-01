from ddtrace import tracer
from flask import Flask
import logging

app = Flask(__name__)


@app.route('/')
def index():
    # logger.info("This log is from the index route Hello, world" + logger.name)
    return 'hello world!!'


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
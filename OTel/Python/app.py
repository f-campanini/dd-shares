import datetime
import opentracing
from ddtrace.opentracer import Tracer, set_global_tracer

# logging
import logging
from pythonjsonlogger import jsonlogger


class CustomJsonFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super(CustomJsonFormatter, self).add_fields(log_record, record, message_dict)
        if not log_record.get('timestamp'):
            now = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
            log_record['timestamp'] = now
        if log_record.get('level'):
            log_record['level'] = log_record['level'].upper()
        else:
            log_record['level'] = record.levelname


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
file_handler = logging.FileHandler('my-log.json')
formatter = CustomJsonFormatter('%(timestamp)s %(level)s %(name)s %(message)s')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


def init_tracer(service_name):
    config = {
      "agent_hostname": "localhost",
      "agent_port": 8126,
    }
    tracer = Tracer(service_name, config=config)
    set_global_tracer(tracer)
    return tracer


def my_operation():
  span = opentracing.tracer.start_span("my_operation")
  span.set_tag("my_tag", "OTel")
  logger.info("message", extra={'dd.span_id':str(span.context._dd_context.span_id), 'dd.trace_id':str(span.context._dd_context.trace_id)})
  span.finish()


init_tracer("my_python_OTel_test_service")

my_operation()

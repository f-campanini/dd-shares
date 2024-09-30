import os
from flask import Flask
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Set up OpenTelemetry Tracer
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Get the OpenTelemetry Collector endpoint from environment variables
otel_collector_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317")

# Create an OpenTelemetry exporter
otlp_exporter = OTLPSpanExporter(endpoint=otel_collector_endpoint, insecure=True)

# Add the exporter to the TracerProvider
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)

@app.route("/")
def hello():
    with tracer.start_as_current_span("hello-span"):
        return "Hello, OpenTelemetry!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

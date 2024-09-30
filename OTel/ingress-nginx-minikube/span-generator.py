import time
from opentelemetry import trace
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    ConsoleSpanExporter,
    BatchSpanProcessor
)
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.trace import Status, StatusCode

provider = TracerProvider(resource=Resource.create({
    "service.name": "testing_service",
    "datadog.host.use_as_metadata": True,
    "deployment.environment": "alex-having-some-fun",
    "cloud.provider": "aws",
    "host.name": "alex-host",
    "host.id": "alex-host-id"
}))
provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint="0.0.0.0:1000", insecure=True)))
tracer = trace.get_tracer("python", tracer_provider=provider)

with tracer.start_as_current_span("parent_span") as parent_span:
    parent_span.set_status(Status(StatusCode.OK))
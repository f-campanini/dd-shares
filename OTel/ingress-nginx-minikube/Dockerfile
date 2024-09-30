# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements and app files
COPY app.py /app/app.py

# Install necessary packages
RUN pip install flask opentelemetry-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-flask

# Expose port 8080
EXPOSE 8080

# Command to run the application
CMD ["python", "app.py"]
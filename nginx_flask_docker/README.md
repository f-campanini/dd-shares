# Purpose of this Sandbox
This is a sandbox running a Python Flask application with Nginx. This sandbox can be used to troubleshoot Nginx issues along with issues involving the Python tracer.

## Requirements: 
Need to have Docker installed on your machine. 

## Python Flask APM Sandbox
This is a sample Flask app with APM configurations in the `docker-compose.yaml` file.

## Nginx Configuration
The Datadog APM configuration for Nginx can be found in the following location `nginx/dd-config.json`. Meanwhile the global configurations for Nginx are in `nginx/nginx.conf`.

https://docs.datadoghq.com/tracing/setup_overview/proxy_setup/?tab=nginx  

Inside the file 'nginx.conf' I have added the following log formation that allows for log & trace correlation.

```
log_format with_trace_id '$remote_addr - $http_x_forwarded_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for" '
    '"$opentracing_context_x_datadog_trace_id" "$opentracing_context_x_datadog_parent_id"';
```

## STEPS:

1. Make sure you add your DD API key in the docker-compose.yaml file
2. Run `docker-compose build` to build the docker image
3. Run `docker-compose up` to spin up the containers
4. Open Chrome and hit `http://localhost:80`
5. Check if you see traces in your account


Remember to run `docker-compose down` to stop and remove the containers.

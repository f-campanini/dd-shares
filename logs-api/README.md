# Submit logs to Datadog through API

You can either submit random log entries or, provided you have a csv file with the first line containing the header, you can send it to Datadog as log through the API endpoint.

## Setup Pre-requisites

Export the Datadog API key or set it so the submit_logs.py script knows to which orgs 

## Send random log entries to Datadog

After exporting the DD API key, start the script create_random_log_entries.py

```bash
python3 create_random_log_entries.py
```

## Send logs entries from a CSV file to Datadog

After exporting the DD API key, look into the python script create_log_entries_from_file
set the FILENAME variable to the CSV file you want to push as logs
The CSV file may contain a timestamp column. In that case, it is better to ignore that column either when converting the CSV into a JSON object or during another step of the file preprocessing. Datadog will ignore any log entry which is 20 minute old.

```bash
python3 create_random_log_entries.py
```

In the sample CSV used there are some duration/intervals which are converted into amount of seconds before sending the data to Datadog API endpoint.

More changes can be done as preprocessing before handing the data to the submit method.

## References

Getting started with minikube
https://minikube.sigs.k8s.io/docs/start/

Spring Boot kubernetes
https://spring.io/guides/gs/spring-boot-kubernetes/

Dockerizing your Spring Boot app:
https://medium.com/geekculture/docker-basics-and-easy-steps-to-dockerize-spring-boot-application-17608a65f657

Docker-hub repository for the project:
https://hub.docker.com/r/dockerfradd/public-repo/tags

Base64 generator:
https://www.base64encode.org/

Test website URL
http://localhost:8080/actuator/

This README.md come from this repo:
https://github.com/f-campanini/dd-shares

Tracing JAVA apps:
https://docs.datadoghq.com/tracing/setup_overview/setup/java/?tab=containers

Metrics using statsd
https://docs.datadoghq.com/developers/dogstatsd/?tab=kubernetes#agent
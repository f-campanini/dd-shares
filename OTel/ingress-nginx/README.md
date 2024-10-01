# Purpose of this Sandbox
This setup will provide a fully functional EKS cluster with ingress-nginx, OpenTelemetry Collector with debug and Datadog exporters, and a simple test application.

I will guide you on how to built the lab and the tests/results.

# Requirements: 
1. aws-cli
2. aws-vault →  explained in a confluence doc
3. eksctl →  to build eks cluster from the command line (or interact with the related config)
4. kubectl
5. helm

You may find useful to create the following alias in the shell you will be using to reduce the typing:
alias av='aws-vault exec sso-sandbox-account-admin --'

# STEPS:

1. Make sure your Datadog agent is running on the local host
2. Create and activate a virtual environment
3. Install the required libraries
4. Execute the code with "python app.py" with the virtual environment activated
5. Check if you see traces in your account

# Notes to ingest the logs:

Logs are created in the same location where the python app is executed.
The Datadog agent needs to be instructed to tail the log file. You need to edit or create the file conf.yaml in the /etc/conf.d/python.d/ location and add the following:

```yaml
init_config:

instances:

##Log section
logs:

  - type: file
    path: "/code/dd-shares/OTel/Python/my-log.json"
    service: "my_application"
    source: python
    sourcecategory: sourcecode
```
# Purpose of this Sandbox
This is a sandbox running a Python application; the application only create a trace. This sandbox can be used to demonstrate how to instrument a Python app to generate traces through opentrace and send those to the Datadog agent.

# Requirements: 
Need to have Datadog agent installed on your machine (localhost).
Python 3.9 and the required libraries installed (as per requirements.txt)

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
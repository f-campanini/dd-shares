source $HOME/.sandbox.conf.sh

#Updates, install datadog
sudo apt update

echo api key ${DD_API_KEY}
echo "Installing Datadog IOT Agent 7 from api_key: ${DD_API_KEY} but not starting it yet"

DD_API_KEY=${DD_API_KEY} DD_SITE="datadoghq.com" DD_AGENT_MAJOR_VERSION=7 DD_AGENT_FLAVOR=datadog-iot-agent bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

echo "Start Datadog agent"
sudo systemctl start datadog-agent
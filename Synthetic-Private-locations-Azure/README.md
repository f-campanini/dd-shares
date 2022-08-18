# Deployment of Datadog Private locations over Azure

You should follow the below steps

## Requirements

access to az cli either using the az-cli tool or the online az bash shell within the AZ portal

## Steps

1. create the following environment variables:
Change these four parameters as needed

```bash
# ACI_PERS_STORAGE_ACCOUNT_NAME needs to be lowercase and contain only numbers and letters and between 3 and 24 characters
ACI_PERS_RESOURCE_GROUP=testResourceGroup
ACI_PERS_STORAGE_ACCOUNT_NAME=teststorageaccount$RANDOM
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=acishare
DD_PL_INSTANCE_NAME=dd-private-locations
```

2. create a resource group

```bash
# example: 
az group create --name ACI_PERS_RESOURCE_GROUP --location ACI_PERS_LOCATION
```

3. create a storage account

```bash
# example:
az storage account create \
--resource-group $ACI_PERS_RESOURCE_GROUP \
--name $ACI_PERS_STORAGE_ACCOUNT_NAME \
--location $ACI_PERS_LOCATION \
--sku Standard_LRS
```
4. create the storage

```bash
az storage share create \
--name $ACI_PERS_SHARE_NAME \
--account-name $ACI_PERS_STORAGE_ACCOUNT_NAME

# possible output (depends on your environment)
There are no credentials provided in your command and environment, we will query for account key for your storage account.
It is recommended to provide --connection-string, --account-key or --sas-token in your command as credentials.

In addition, setting the corresponding environment variables can avoid inputting credentials in your command. Please use --help to get more information about environment variable usage.
{
  "created": true
}
```

5. Check that the storage is available

```bash
az storage account list -g $ACI_PERS_RESOURCE_GROUP
```

6. Get your storage credentials

```bash
# you need 3 values: storage-account-name, share-name, storage-account-key
STORAGE_KEY=$(az storage account keys list --resource-group $ACI_PERS_RESOURCE_GROUP --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)

# now check that you actually have a key
echo $STORAGE_KEY
```

7. Access the storage through the Azure portal UI
Access the storage through the Azure UI:
- access the resource from the Azure portal
- upload the file from the storage view

8. Create the container instance

```bash
az container create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name $DD_PL_INSTANCE_NAME \
    --image gcr.io/datadoghq/synthetics-private-location-worker:latest \
    --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
    --azure-file-volume-mount-path /etc/datadog/ \
    --command-line "tail -f /dev/null"
```

9. connect into the running container instance and re-configure the datadog private locations agent

```bash
az container exec --exec-command "/bin/bash" --name $DD_PL_INSTANCE_NAME --resource-group $ACI_PERS_RESOURCE_GROUP
```

When connected you should see a bash prompt. The datadog private locations application is currently not running as the configuration file is not in the right location (/etc/datadog).

You need to execute the bash command to create the configuration file (which include the secret key) while in the /etc/datadog folder.

```bash
cd /etc/datadog
bash -c 'cat << "EOF" > worker-config-azure-test-39880fe5803fbb963d2b7275265a7204.json
{
  "datadogApiKey": "myDataDogKey",
  "id": "pl:azure-test-39880fe5803fbb963d2b7275265a7204",
  "site": "datadoghq.com",
  "accessKey": "myAccessKey",
  "secretAccessKey": "mySecretAccessKey",
  "privateKey": "-----BEGIN RSA PRIVATE KEY-----\mySuperSecretPrivateKey\n-----END RSA PRIVATE KEY-----",
  "publicKey": {
    "pem": "-----BEGIN PUBLIC KEY-----\myLessSecretPublicKey\n-----END PUBLIC KEY-----\n",
    "fingerprint": "sha256$base64$FingerPrint"
  }
}
EOF'
```

A json file will be created. You now need to rename the file into what is expected by the Datadog application (use mv to rename the file into /etc/datadog/synthetics-check-runner.json).

```bash
mv /etc/datadog/worker-config-azure-test-39880fe5803fbb963d2b7275265a7204.json /etc/datadog/synthetics-check-runner.json
```

As last step, you can execute the worker (Datadog private locations application):

```bash
cd ~
node dist/worker.js --config=/etc/datadog/synthetics-check-runner.json
```

10. if the Azure Shell disconnect (timeout), login again to Azure, connect to the right sandbox, and open the bash CLI then follow the below steps to start the worker again

```bash
ACI_PERS_RESOURCE_GROUP=testResourceGroup
DD_PL_INSTANCE_NAME=dd-private-locations

az container exec --exec-command "/bin/bash" --name $DD_PL_INSTANCE_NAME --resource-group $ACI_PERS_RESOURCE_GROUP

cd ~
node dist/worker.js --config=/etc/datadog/synthetics-check-runner.json
```

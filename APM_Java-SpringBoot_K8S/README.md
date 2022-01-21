# Kubernetes Java Sandbox

## Setup Pre-requisites

### Setup Minikube
If you haven't setup minikube yet follow the steps in the link in the reference section.

This should be a relatively quick setup to create a 1 Node Kubernetes Cluster running locally on your workstation. As well as install the kubelet client for interacting with the Kubernetes cluster.

## Setup Datadog Agent Resources
Run the following commands from the root folder of the current project.

We are using the Datadog Agent configuration gathered from our [Daemonset Installation docs](https://docs.datadoghq.com/agent/kubernetes/?tab=daemonset#installation). 


But this will require those steps in those Daemonset installation docs. Namely running the following

```bash
kubectl apply -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrole.yaml"
kubectl apply -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/serviceaccount.yaml"
kubectl apply -f "https://raw.githubusercontent.com/DataDog/datadog-agent/master/Dockerfiles/manifests/rbac/clusterrolebinding.yaml"
```

Then creating the secret with respect to your API Key.
```bash
kubectl create secret generic datadog-agent --from-literal api-key="<DATADOG_API_KEY>" --namespace="default"
```

In the manifest file, take care of replacing the following strings with appropriate values:
**PUT_YOUR_BASE64_ENCODED_API_KEY_HERE**
**PUT_A_BASE64_ENCODED_RANDOM_STRING_HERE**

### Deploy Standard Agent
You can deploy the standard Agent with respect to the `datadog-agent-all-features.yaml` file. Remember to set the appropriate keys.

```bash
kubectl apply -f datadog-agent-all-features.yaml 
```

Check that the agent (5 pods) and the agent-cluster-agent (1 pod) are running in the default namespace.

```bash
kubectl get pods --all-namespaces               
NAMESPACE              NAME                                          READY   STATUS    RESTARTS   AGE
default                datadog-agent-cluster-agent-786b8cb8f-6dxr2   1/1     Running   0          23m
default                datadog-agent-j7vw8                           5/5     Running   0          23m
kube-system            coredns-78fcd69978-jd5r5                      1/1     Running   0          47d
kube-system            etcd-minikube                                 1/1     Running   0          47d
kube-system            kube-apiserver-minikube                       1/1     Running   0          47d
kube-system            kube-controller-manager-minikube              1/1     Running   0          47d
kube-system            kube-proxy-9f46m                              1/1     Running   0          47d
kube-system            kube-scheduler-minikube                       1/1     Running   0          47d
kube-system            storage-provisioner                           1/1     Running   0          47d
kubernetes-dashboard   dashboard-metrics-scraper-5594458c94-7dx48    1/1     Running   0          6h38m
kubernetes-dashboard   kubernetes-dashboard-654cf69797-c9xhg         1/1     Running   0          6h38m
```

## Building the Spring Boot app
I have used the following example:
https://spring.io/guides/gs/spring-boot-kubernetes/

More info in the reference section.

#### step by step building the image
You can create an application from scratch by using start.spring.io:
```bash
curl https://start.spring.io/starter.tgz -d dependencies=webflux,actuator | tar -xzvf -
```

You can then build the application:
```bash
./mvnw install
```

Download dd-java-agent.jar that contains the Agent class files
```bash
wget -O dd-java-agent.jar 'https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=com.datadoghq&a=dd-java-agent&v=LATEST'
```

To test, add the following JVM argument -javaagent:/path/to/the/dd-java-agent.jar
```bash
java -javaagent:./dd-java-agent.jar -jar target/demo-0.0.1-SNAPSHOT.jar
```

Build the image using docker build (from the root directory of this project)
```bash
docker build  ./
```

Test the image (replace with the correct image-id that you find at the end of the building process):
```bash
docker run -p 8080:8080 1bb9403f903b5a1327075e8311557cdca9f0f2448de235f54291b9c805d2a3b2
```

### Push the image to docker-hub
Continue with docker-login then tag and push the image in docker-hub (replace with the correct image-id):
```bash
docker login
docker tag 1bb9403f903b5a1327075e8311557cdca9f0f2448de235f54291b9c805d2a3b2 dockerfradd/public-repo
docker push dockerfradd/public-repo
```

### Deploying the application to kubernetes
We will use the image I built and publish on docker-hub:
https://hub.docker.com/r/dockerfradd/public-repo


```bash
kubectl create deployment demo --image=dockerfradd/public-repo --dry-run -o=yaml > deployment.yaml
echo --- >> deployment.yaml
kubectl create service clusterip demo --tcp=8080:8080 --dry-run -o=yaml >> deployment.yaml
```

You can take the YAML generated above (deployment.yaml) and edit it if you like, or you can apply it as is:

```bash
kubectl apply -f deployment.yaml
deployment.apps/demo created
service/demo created
```

Check that the application is running
```bash
kubectl get all
NAME                                              READY   STATUS    RESTARTS   AGE
pod/datadog-agent-cluster-agent-786b8cb8f-6dxr2   1/1     Running   0          74m
pod/datadog-agent-j7vw8                           5/5     Running   0          74m
pod/demo-788df544fc-knhnd                         1/1     Running   0          22s

NAME                                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/datadog-agent                 ClusterIP   10.102.17.244   <none>        8125/UDP,8126/TCP   74m
service/datadog-agent-cluster-agent   ClusterIP   10.109.99.235   <none>        5005/TCP            74m
service/demo                          ClusterIP   10.110.43.63    <none>        8080/TCP            22s
service/kubernetes                    ClusterIP   10.96.0.1       <none>        443/TCP             47d

NAME                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/datadog-agent   1         1         1       1            1           kubernetes.io/os=linux   74m

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/datadog-agent-cluster-agent   1/1     1            1           74m
deployment.apps/demo                          1/1     1            1           22s

NAME                                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/datadog-agent-cluster-agent-786b8cb8f   1         1         1       74m
replicaset.apps/demo-788df544fc                         1         1         1       22s
```

To be able to connect to the app through localhost, create an SSH tunnel:
```bash
kubectl port-forward svc/demo 8080:8080
```

Check that the application is working from another terminal:
```bash
curl localhost:8080/actuator/health
{"status":"UP","groups":["liveness","readiness"]}%       
```

## Useful kubernetes commands

If you need to route the port 8080 from the demo-pod to localhost you can use the following command:
```bash
kubectl port-forward svc/demo 8080:8080
```

If you need to pull a new image from docker-hub:
```bash
kubectl rollout restart deployment
```

To view the logs from the app, collect the pod name and run the kubectl logs command:
```bash
kubectl get pod
kubectl logs demo-58ff54cf65-d4cdl
```

To edit the datagod pod live:
```bash
# list all the resources type daemonset with namespace default:
kubectl get ds -n default

# edit the correct daemonset:
kubectl edit ds datadog-agent -n default
```
Save and close it. The daemonset will restart. And the application will start getting traced.

If you are using minikube, when you are done you can stop it:
```bash
minikube stop
```

## References

Getting started with minikube
https://minikube.sigs.k8s.io/docs/start/

Spring Boot kubernetes
https://spring.io/guides/gs/spring-boot-kubernetes/

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

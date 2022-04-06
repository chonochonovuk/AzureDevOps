# 
# Part 1 (Azure CLI)
# 

#
# Kubernetes cluster creation
#

# Log in to Azure Portal if not working in the Cloud Shell
az login

# Select a subscription
az account set --subscription "<Subsription Name>"

# Create a resource group
az group create -n RG-K8S -l westeurope

# Create a container registry
az acr create -g RG-K8S -n azesucli --sku Basic

# Create a Kubernetes cluster with one node
az aks create -g RG-K8S -n k8s-demo --node-count 1 --node-vm-size Standard_B2s --enable-addons monitoring --generate-ssh-keys --attach-acr azesucli

#
# Cluster exploration (the one created within the Portal)
#

# Log in to Azure Portal if not working in the Cloud Shell
az login

# Select a subscription
az account set --subscription "<Subsription Name>"

# Get credentials for the cluster
az aks get-credentials --resource-group RG-Kubernetes --name aze-kubernetes

# Download kubectl from here: https://kubernetes.io/docs/tasks/tools/

# Retrieve information about the cluster
kubectl cluster-info

# Retrieve information about the nodes
kubectl get nodes

# List available namespaces
kubectl get namespaces

# List all pods in all namespaces
kubectl get pods --all-namespaces

#
# Build and test Docker container locally 
#

# Build the image
docker build . -t aze-web-app-php

# Run the container
docker run -d --name webapp -p 8000:80 aze-web-app-php

# Navigate to http://localhost:8000 to see the application working

# 
# Move the app to AKS
# 

# Login to the ACR
az acr login --name azesu

# Check the login server
az acr list --resource-group RG-Kubernetes --query "[].{acrLoginServer:loginServer}" --output table

# Tag our image
docker tag aze-web-app-php azesu.azurecr.io/aze-web-app-php:v1

# Push the image to our ACR
docker push azesu.azurecr.io/aze-web-app-php:v1

# List the images in our ACR
az acr repository list --name azesu --output table

# List all tags of an image
az acr repository show-tags --name azesu --repository aze-web-app-php --output table

# Integrate our existing ACR with our existing AKS cluster (if not done via the Portal)
az aks update -n aze-kubernetes -g RG-Kubernetes --attach-acr azesu

# Navigate to manifests folder
cd .\manifests

# Examine the content of both service.yaml and deployment.yaml 

# Deploy the service and the application
kubectl apply -f service.yaml -f deployment.yaml

# We can check periodically how it is going:
kubectl get svc,pod

# Use the external Load Balancer IP to check the application in a browser

# We can delete the application and the service with the following command (skip it for now)
kubectl delete -f service.yaml -f deployment.yaml

# 
# Scale an application
# 

# Let’s first check what do we have
kubectl get pods

# Get detailed information about the deployment
kubectl describe deployment phpapp-deployment

# Scale up the application to 5 replicas
kubectl scale --replicas=5 deployment.apps/phpapp-deployment

# Check what is going on with the pods
kubectl get pods

# Scale up once again, this time to 10 replicas
kubectl scale --replicas=10 deployment.apps/phpapp-deployment

# Check that the new pods are created
kubectl get pods

# Now, we can go to the app opened in the browser and refresh a few times to see that it is served by different pods

# Let’s scale down a bit
kubectl scale --replicas=2 deployment.apps/phpapp-deployment

# And check what is going on with the pods
kubectl get pods

# 
# Scale the cluster
#

# Add a node via the Portal and then return here

# You can ask for nodes’ status on the command line with
kubectl get nodes

# If we scale now to 5 replicas
kubectl scale --replicas=5 deployment.apps/phpapp-deployment

# We will notice that some of the pods are on the first node, and others on the second
kubectl get pods -o wide

# Let’s add one more node but this time on the command line
az aks scale --resource-group RG-Kubernetes --name aze-kubernetes --node-count 3 --nodepool-name agentpool

# After a while, a new node will appear
kubectl get nodes -o wide

# 
# Update and redeploy the application
# 

# Don't forget to remove the running container from the previous step
docker container rm webapp --force

# Modify the application's code (change the title to Top 10 cities in Bulgaria, change the H3 tag to H2, and add a border to the table)

# Build the new image
docker build . -t aze-web-app-php

# Test the app locally
docker run -d --name webapp -p 8000:80 aze-web-app-php

# Check the result in a browser by navigating to http://localhost:8000/

# Tag the image
docker tag aze-web-app-php azesu.azurecr.io/aze-web-app-php:v2

# Push the image to our ACR
docker push azesu.azurecr.io/aze-web-app-php:v2

# Check the list of images available on our ACR
az acr repository list --name azesu --output table

# And all tags for an image
az acr repository show-tags --name azesu --repository aze-web-app-php --output table

# Change the image version in the deployment.yaml file as well
# Change image: azesu.azurecr.io/aze-web-app-php:v1 to image: azesu.azurecr.io/aze-web-app-php:v2

# Deploy both the service and application simultaneously
kubectl apply -f service.yaml -f deployment.yaml

# We can check periodically how it is going
kubectl get svc,pod

# We will notice that extra replicas will be terminated and once, the new pod is up and running, the last of the old version will be terminated

# Use the external Load Balancer IP to check the application in a browser
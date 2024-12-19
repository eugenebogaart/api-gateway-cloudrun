# Terraform Modular approach for:
- Local docker build of an image
- Docker push to Google Artifact Repo
- Deploy Image on Cloud Run
- Create API Gateway
- Attach Cloud run service 
- Configure Gateway

### Notes:
This write up is mainly for myself, so I donot forget about the work I did. 
However you may use and learn from what I did.

Local docker build is triggered by a null_resource. This executes an oldstyle Unix/Linux make command.
The Makefile manages the build if any of the artifacts have changed.
Also the Makefile pushes the docker image to the Google Artifacts repo for Cloud_Run.
The applciation to dockerize is not in this repo, 
but I used a Python FastAPI that I have developed for other purposed.

## Bonus material

This Terraform also manages: 
- Create Google secrets in Google Secret Manager
- Cloud Run service is deployed with Env variables to pick up the secrets
- Google Credentials API key for API Gateway are also provisioned.
  

## Be Aware 
- Terraform Provider for Google API Gateway is still beta (as of December 2024)
- Could not find much about why? But one of the mising parts is API Gatway Configs.
- API Gatway Configs are immutable and changes must be in-place.
- This behaviour is to ensure config updates without downtime.
- Unfortunately in-place updates are not inline with Terraform.
  (looks like a chicken and egg problem)

## Todo
- Write a wrapper to mitigate this issue with gcloud commandline. 
  Below the gcloud commands that create a new config and update the gateway.
  
```
gcloud api-gateway api-configs create ${CONFIG_ID}-${NEW_VERSION} \
    --api=${API_ID} --openapi-spec=openapi2-run.yaml \
    --project=${PROJECT_ID} --backend-auth-service-account=${SERVICE_ACCOUNT_EMAIL}

gcloud api-gateway gateways update ${GATEWAY_ID} \
    --api=${API_ID} --api-config=${CONFIG_ID}-${NEW_VERSION} 
    --location=${LOCATION}
```

${NEW_VERSION} is increment for every new version that is deployed

- Add source code for a sample Docker service based on Python FastAPI 
- Build a process to convert FastAPI openapi (Swagger 3), 
  to Google API Gateway Configs (Swagger versie 2)

## SETUP instructions

- Create a new Google Project (if you donot have one!)
  - Add the projectId to: variable.tfvars
- Create a service account for Terraform
  - Grant Owner permission ()
  - Manage Keys  -> Create and download a json key 
  - Store the Key outside of this Terraform github repo
  - Edit credentials field to: variable.tfvars
  
```
   credentials = file(var.gcp_auth_file)
```

- Google Cloud Console  -> IAM
  - Edit just created service account
  - Edit Access
  - Add Role:  Secret Manager Admin   
    (Secret Manager Secret Accessor is not enough, we also need to create secret versions!)

- Google Cloud Console ->
  - Edit the default compute service account
    (something like:  98........13-compute@developer.gserviceaccount.com)
  - Edit Access
  - Add Role: Secret Manager Secret Accessor 
    (These are the permissions for the principle that executes Cloud-Run service.
    So it can access the Secrets. Environment Variable in this case)
- Setup Environment variables for the Secret to be provisioned
  See variables.tf for the naming
- Both the API Gateway and the Docker app service use different API Key.
  This is not best practice. The Docker app service should either use some Google IAM or 
  authenticate with an external service, or may be with a database.

## RUN instructions

%> terraform init

%> terraform apply

## TEST

Terraform output the API-Gateway configuration and its address.


```
gateway_address = "fast-api-ex-gw-9zhy91lf.nw.gateway.dev"
```

## Contact

Do you have suggestions?  Or did you made improvements?  Please let me know.
You can reach me [On linkedin](https://www.linkedin.com/in/eugenebogaart)

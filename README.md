# Hello World SpringBoot Application

This application is a demo app developed with Springboot, built for learning and testing CI/CD workflows.
It 
- Exposes a simple REST endpoint
- Outputs a sample string when accessed via `http://localhost:9090`

This project uses two separate repositories.
1. codebase (Current repo): Maintains the codebase including business logic, Jenkins workflow and ArgoCD application configuration
2. [manifest](https://github.com/vinukavinnath/demo-spring-app-manifest): Contains the helm chart of the deployment which is referred by ArgoCD (Helm chart is not packaged)

### Branches
- main: Maintains CI/CD workflow in Jenkinsfile
- gitops: Seperates the CD workflow to and ArgoCD application. Refer the `./app.yaml` for app configuration.

### Repository Structure (Branch: gitops)
HelloSpringBoot/      <br> 
├── `app.yaml`  : Contains the Argocd application configuration     <br> 
├── `Dockerfile`   : Defines the layers of the Image   <br>
├── `Jenkinsfile`  : Defines the CI workflow  <br>
├── `pom.xml`         <br>
├── `README.md`       <br>
└── `src`             <br>

### CI Workflow
![CI](https://imgur.com/UytkT9L.png)
- Developer pushes a new commit to remote repository (In this case GitHub)
- Builds the project
- Build the image referring the Dockerfile
- Perform a Vulnerability scan using Trivy
- Pushes the image to registry (Dockerhub)
- Deletes the previously built image in the Jenkins server (Since we don't need to stack up images in server each time developer push to repo)
- Updates the manifest repository which maintains the deployment

### CD Workflow
![CD](https://imgur.com/xFbQkvD.png)
- Clones the manifest repository to Jenkins server
- Replaces the placeholder for the docker image tag in `values.yaml` which will ultimately updates the source helm chart
- Commits and pushes the changes to manifest repo
Then ArgoCD detects the difference between source and destination and It will sync and rolls out the deployment

### Thanks!
##### Authored by [Vinuka Vinnath](https://www.linkedin.com/in/vinukavinnath/)


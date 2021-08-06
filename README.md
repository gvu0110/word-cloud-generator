# word-cloud-generator
It's a golang web app that takes a block of text and turns it into a word cloud. 

## Notice
This project is under active development. This project is being created as a sample app for an upcoming training class on Continuous Delivery with Lynda.com. You can see previous courses we have made at https://lynda.com/JamesWickett. Thanks!

## Prerequisites
1. Install go - https://golang.org/doc/install (Start learning go with the tour - http://tour.golang.org/)
2. Set $GOPATH `export GOPATH="${HOME}/go"`
3. Set $PATH `export PATH=$PATH:$(go env GOPATH)/bin`
5. Install goconvey - `go get github.com/smartystreets/goconvey`

## Git
We use git hooks to standardize development on the project. Please run `make git-hooks` to get started.

## Using Make

### Building Artifacts
This will pull down dependencies, run unit tests, and compile a linux, mac and windows binary into ./artifacts.

`make`

### Fiddling Around

You can build and install a copy in your local $GOPATH/bin directory with:

```
make install
```

### Clean up previous build files
```
make clean
```

### Test Coverage
```
make test
```

### Visual Test Coverage
```
make goconvey
```

### To Run
`make run` or just run the executable.  It will run as a daemon and bind to port 8888, and you can see it by going to http://localhost:8888 in your browser.

## Use API via Curl
```
$ curl -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://localhost:8888/api
```

## Setup example
Use this setup

aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

## Running Jenkins container
Build and run Jenkins container
```sh
docker build --tag cd_jenkins:latest jenkins/.
docker run -d -p 8080:8080 -p 50000:50000 --name jenkins cd_jenkins:latest
# View initAdminPassword
docker exec -it jenkins /bin/bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
```

The [Golang](https://plugins.jenkins.io/golang/) plugin and [Nexus Artifact Uploader](https://plugins.jenkins.io/nexus-artifact-uploader/) plugin should be automatically installed

Go to the Jenkins [Global Tool Configuration](http://localhost:8080/configureTools/) and add a go installation. Call it something with the version in it like `go1.16.6`

Go to the Jenkins [Script Console](http://localhost:8080/script) and run Groovy scripts:
- Create Nexus credentials
```groovy
import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope

instance = Jenkins.instance
domain = Domain.global()
store = instance.getExtensionList("com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "nexus_credentials", // Credentials ID
  "Nexus credentials", // Description
  "jenkins-user", // Username
  "P@ssW0rd!" // Password
)

store.addCredentials(domain, usernameAndPassword)
```
- Create pipeline job
```groovy
import hudson.plugins.git.*
import hudson.triggers.SCMTrigger
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition

// Define job parameters
def jobParameters = [
  name:          'word-cloud-generator',
  description:   'Word cloud generator job',
  repository:    'https://github.com/gvu0110/word-cloud-generator/',
  branch:        'master'
]

// Get Jenkins instance
def jenkins = Jenkins.instance

// Define repo configuration
def scm = new GitSCM(jobParameters.repository)
scm.branches = [new BranchSpec(jobParameters.branch)]

// Define SCM flow
def flowDefinition = new CpsScmFlowDefinition(scm, "Jenkinsfile")

// Define job
def job = new WorkflowJob(jenkins, jobParameters.name)

// Set job type
job.definition = flowDefinition

// Set job description
job.setDescription(jobParameters.description)

// Define build trigger
SCMTrigger trigger = new SCMTrigger("H/15 * * * *")
job.addTrigger(trigger)

// Save job
jenkins.add(job, job.name)
jenkins.save()
jenkins.reload()
```

## Running standalone Nexus container
Run Nexus container
```sh
docker run -d -p 8081:8081 --name nexus sonatype/nexus3:3.32.0
# View admin password
docker exec -it nexus /bin/bash -c "cat /nexus-data/admin.password"

curl -u admin:${NEXUS_PASSWORD} -X POST -H 'Content-Type: application/json' http://localhost:8081/service/rest/v1/security/users -d @nexus/createJenkinsUser.json
curl -u admin:${NEXUS_PASSWORD} -X POST -H 'Content-Type: application/json' http://localhost:8081/service/rest/v1/repositories/raw/hosted -d @nexus/createRawHostedRepository.json
curl -u admin:${NEXUS_PASSWORD} -X POST -H 'Content-Type: application/json' http://localhost:8081/service/rest/v1/repositories/raw/group -d @nexus/createRawGroupRepository.json
```

## Running standalone test fixture container
```
docker build -t test_fixture:latest test_fixture/.
```

## Building ansible image
```
docker build -t ansible:latest ansible/.
```
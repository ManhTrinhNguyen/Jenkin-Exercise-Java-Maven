## Deploy to EC2 Server from Jenkins Pipeline CI/CD 

#### Overview

- Connect to EC2 server Instance from Jenkins Server via SSH (ssh agent)

- Execute Docker command on that Server 

#### Install SSH Agent Plugin and Create SSH Credential Type 

- Go to Manage Jenkins -> Plugin -> SSH Agent

- Create SSH Credential

  - I need to make .pem file from local also available in Jenkin
 
  - Go to Multi Branch Pipeline -> Credentials -> Select SSH Username with Private Key -> Get the content from .pem file and add it into Private in Jenkin
 
#### Jenkinfile Syntax for a Plugin 

- There is a way in Jenkin of seeing pipeline syntax or Jenkinfile syntax : Go to Multi branch Pipeline -> Select Pipeline Syntax -> In the Sample Step I can choose diffent steps that I want to configure -> This case I choose ssh agent -> then I will have a list of credentials available for this project

#### Jenkinfile | Connect to EC2 and run Docker command 

 ```
 stage("deploy") {
    steps {
        script {
            echo 'deploying docker image to EC2...'

            dockerCMD = 'docker run -p 3000:3080 nguyenmanhtrinhrepo/demo-app:1.0'

            sshagent(['ec2-server-key']) {
              sh "ssh ec2-user@public-ip-address ${dockerCMD}"
            }
        }
    }               
}

 ```
- In deploy Step I will paste in the generated syntax from above example

  - SSH to the Instance: `sh 'ssh ec2-user@public-ip-address'` . In addition to that I need to depress the pop up bcs this is not a interactive mode: `sh 'ssh -o StrictHostKeyChecking=no ec2-user@public-ip-address'`
 
  - Passing on Docker command as a last Parameter -> Put docker run command into a variable `def dockerCMD = 'docker run -p 3000:3080 nguyenmanhtrinhrepo/demo-app:1.0'` -> And then put the var into the ssh command `sh "ssh ec2-user@public-ip-address ${dockerCMD}"` . Before this step I have to have `docker login` executed in EC2
 
#### Configure Firewall rule on EC2 

- I need to give Jenkins Server's IP address Permission to connect to EC2 Instances

- Go to Security -> Add Ip Address of Jenkins to Port 22 .

- Also Open the Port 3000 . This is the Port where Application will be accessible at so I can access it from the Browser

#### Executing complete Pipeline 

- I have a Jenkinsfile that

  - Using a Share Library : This Share Library contain all of the function for bulding the Jar of the Maven Application and then building the Docker Image
 
  ```
  library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://gitlab.com/twn-devops-bootcamp/latest/09-aws/jenkins-shared-library.git',
    credentialsID: 'gitlab-credentials'
    ]
  )
  ```

  - In the Pipeline I define an ENV with Image Name :

  ```
  environment {
    IMAGE_NAME = 'nguyenmanhtrinh/demo-app:java-maven-1.0'
  }
  ```

  - In Build Jar Stage I have `buildJar()` function from Share Lib to build the Jar file
 
  - In Build Image Stage I have Build image, dockerLogin, dockerPush function to build an Image
 
  - In the deploy Stage I have used ssh agent to ssh to EC2 . And Run the Docker Container from there
 
#### Notes 

- This approach using the ssh agent plugin is applicable for all the Servers (EC2, Digital, Linode ...)

- This just a basic simple step to run Docker container from Jenkins : For Smaller Project

- More complex set up to deploy Container I would use Kubernetes


#### Using docker-compse 

- Maybe I have 5 containers for my Applications and all of this define in Docker-compose file . In this case I could also use SSH-Agent, What I could do is basically from Git Repo that connected to Pipeline Job just take docker-compose file copy that to the Server once I ssh into it and then execute docker-compose command on the server

- Project Setup in my Repo I will have Docker Compose yaml file that define all the container need to run for the Application then I can start container with command `docker-compose -f docker-compose.yaml up`

- Step 1 : Install docker compose on EC2

  - Docker-compose is not in yum package . I will use `curl` command that I use which is gonna download the latest version of docker compose to the local file system : `sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose` . And then I make it executable : `sudo chmod +x /usr/local/bin/docker-compose` 

- Step 2 : Create Docker compose Yaml file for my Application

  ```
  version: '3.8'
  services:
     java-maven-app:
        image: ${IMAGE}
        ports:
          - 8080:8080
      postgres:
        image: postgres:15
        ports:
          - 5432:5432
        environment:
          - POSTGRES_PASSWORD=my-pwd
  ```

- Step 3 : Adjust Jenkinfile to execute docker-compose command on EC2 Instance

  - I need to have docker-compose file in EC2 Instance . I will copy docker-compose file from Git Repo to EC2 Instance
 
  - In sshAgent Block : `sh "scp docker-compose.yaml ec2-user@<public-ip-address>:/home/ec2-user"`. This is will execute on Jenkin and Jenkin before running all these Stages will check out the Repository so Jenkin Server has access to the file in the Repository   

    - ec2-user@<public-ip-address> : This is the remote server that docker-compose.yaml get copied to
   
    - :/home/ec2-user : This is where the docker-compse.yaml get copied to (inside the EC2)

  - I will set docker-compose command in a variable : `def dockerComposeCMD = docker-compose -f docker-compose.yaml up --detach` . Then I will set it in the sshAgent where the ssh connect to EC2 : `"ssh ec2-user@public-ip-address ${dockerComposeCMD}"`


  - The whole set up look like this  

  <img width="600" alt="Screenshot 2025-03-29 at 11 24 23" src="https://github.com/user-attachments/assets/b216cdc5-304b-4a8a-8407-d71a9cae6a08" />


#### Extract to Shell Script 

- What if I want to execute multiple command once I connect to EC2 Server . What if I need to set some variable before execute docker-compose command or what if I have other command to execute before

- I Can execute multiple Command by grouping them into a shell script and execute the shell script from Jenkin

- I will create shell file `server-cmds.sh`

 ```
 #!/usr/bin/env bash

 docker-compose -f docker-compose.yaml up --detach
 echo "Success"
 ```

- In Jenkinfile I will put execute shell command into Variable : `def shellCMD = 'bash ./server-cmds.sh'`

- I will copy the script file to EC2 : Inside sshAgent block : `sh "scp server-cmds.sh ec2-user@<public-ip-address>:/home/ec2-user"` and then run it on EC2 : `"ssh ec2-user@public-ip-address ${shellCMD}"`

- The whole code look like this :

<img width="600" alt="Screenshot 2025-03-29 at 11 42 18" src="https://github.com/user-attachments/assets/ac0d55d4-9a54-4425-bc6d-67b5cec16380" />

#### Replace Docker Image with newly built Version

- In Docker-compose the Image is hardcode . However when I produce Application I alway produce a new Version

- Suppose I am bulding another version of Image and I need to pass that Information or the Image Name to the Docker-Compose and replace the whole Image name in Docker Compose . In Docker Compose instead of hardcode image I will set it as a Variable : `${IMAGE_NAME}` . This Docker-compose file is actually called by server command shell script . In the Shell Script file before I execute Docker-compose CMD I will export the Image variable as a ENV `export IMAGE=xxx` and set it to a value that represent the Image name in Jenkinfile.

- So how do the Image variable in shell script file get Image Name value in Jenkinfile ?

  - I will pass the value to shell script file as a Parameter. I can set a parameter after Shell Script cmd and I can pass multiple Parameter to a shell script by just listing them and read those Parameter . In this case the Parameter I want to set is IMAGE variable . In Jenkinsfile I will pass value like this : `def shellCMD = "bash ./server-cmds.sh ${IMAGE_IMAGE}"` and in Shell script file I set : `export IMAGE=$1` (1 for the first parameter) .
 
----Wrap up----

- I have the Image as a ENV in Jenkinfile and passing on to Shell Script via Parameter . And a Shell Script read that Parameter via $1 and set the variable as Image and export ENV on EC2 . Now this ENV will be set on EC2 Server bcs this whole shell script get execute on the EC2 remote Server And then execute the docker-compse cmd with the ENV set in EC2

- This is what Jenkinfile look like :

 <img width="600" alt="Screenshot 2025-03-29 at 12 11 31" src="https://github.com/user-attachments/assets/eaf41bbc-f3e1-48cc-9245-ea3093c05812" />

- This is what Docker-compose Look like :

<img width="600" alt="Screenshot 2025-03-29 at 12 12 12" src="https://github.com/user-attachments/assets/2502f2ca-b282-441f-9cae-9cbd40f1460b" />

- This is what shell script look like :

<img width="600" alt="Screenshot 2025-03-29 at 12 13 17" src="https://github.com/user-attachments/assets/3a630417-c650-495f-9f75-a3802298b668" />


#### Set Image Name dynamically in Jenkinfile 

- Add the Increment Version Stage

- I will call this mvn command : `sh 'mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit'` . That increment the version in Pom.xml

- and then I will read that version from pom.xml and extract that value and set it in a variable :
  
  ```
  def matcher = readFile('pom.xml') =~ <version>(.+)</version>
  def version = matcher[0][1]
  ```

- and then I will set Image name from that version as a  ENV : `env.IMAGE_NAME = "nguyenmanhtrinh/demo-app:$version-$BUILD_NUMBER"`

#### Commit version update Stage 

- Add commit version update Stage right after the deploy stage .

- This step the same in Jenkins module 

```
stage('commit version update'){
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]){
                sh 'git remote set-url origin https://$USER:$PASS@github.com/nguyenmanhtrinh/java-maven-app.git'
                sh 'git add .'
                sh 'git commit -m "ci: version bump"'
                sh 'git push origin HEAD:jenkins-jobs'
            }
        }
    }
}
```

#### This is how real project are built 

<img width="600" alt="Screenshot 2025-03-29 at 12 55 36" src="https://github.com/user-attachments/assets/c1372ac6-92a6-42b4-818a-b5d8cea6790e" />

----Summary----

- First Increment the Version which give me a new (or next) version Docker Image -> Then Build Application Jar using that Version -> Then I will use Jar file the build Docker Image with the Image set in the Increment version stage and push that Image to Repository -> And then will deploy Docker-Compose file the new Image version set dynamically -> Then I connect to EC2 using sshagent, copy docker-compose to ec2 and execute docker-compose on the server -> Once success Deploy I will committing the change with the change of version increment


- !!!NOTE : If the Stage fail the rest will be skip

- For more advance use case is Docker-compose isn't enough to manage my container . I gonna need to container Orchestration tools and deploy to that Orchestration tool then will look different than just using sshagent plugin 


library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/ManhTrinhNguyen/Share_Library_Exercise.git',
     credentialsId: 'Github_Credential'
    ]
)

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    parameters {
        choice(name: "ENVIRONMENT", choices: ["dev", "staging", "production"], description: "Where do I want to deploy ?")
    }
    environment {
        DOCKER_REPO = 'nguyenmanhtrinh/demo-app'
    }
    stages {
        stage("Version Increment Dynamic"){
            steps {
                script {
                    echo 'Increment App Version ...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'

                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "java-maven-$version-$BUILD_NUMBER"
                }
            }
        }

        stage("test") {
            steps {
                script {
                    echo "testing"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    Build_Maven_Jar()
                }
            }
        }

        stage("build docker image") {
            steps {
                script {
                    echo "build Image"
                    sh "docker build -t ${DOCKER_REPO}:${IMAGE_NAME} ."
                }
            }
        }

        stage("Login to Docker Hub") {
            steps {
                script {
                     echo "Login to Docker Hub"

                    withCredentials([
                        usernamePassword(credentialsId: 'Docker_Hub_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')
                    ]){
                        sh "echo ${PWD} | docker login -u ${USER} --password-stdin"
                    }
                }
            }
        }

        stage("Push Image to Docker Hub"){
            steps {
                script {
                    echo "Push Image to Docker Hub"
                    sh "docker push ${DOCKER_REPO}:${IMAGE_NAME}"
                    echo "Push image to ${params.ENVIRONMENT}"
                }
            }
        }

        stage("deploy") {

            when {
                expression {
                    BRANCH_NAME == "main"
                }
            }

            steps {
                script {
                    echo "Deploying Image to EC2"

                    shellCmd = "bash ./server-script.sh ${DOCKER_REPO}:${IMAGE_NAME} ${USER} ${PWD}"

                    sshagent(['AWS_Credential']) {
                        
                        // With this step Instead of I manually use docker login on the Server . I can do it here
                        withCredentials([
                        usernamePassword(credentialsId: 'Docker_Hub_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')])
                        {
                            sh """
                        scp server-script.sh ec2-user@18.144.49.131:/home/ec2-user
                        scp docker-compose.yaml ec2-user@18.144.49.131:/home/ec2-user
                        ssh -o StrictHostKeyChecking=no ec2-user@18.144.49.131 <<EOF
${shellCmd}
EOF
                    """
                            
                        }
                        
                    }
                }
            }
        } 

        stage("Commit to Git Repo") {
            when {
                expression {
                    BRANCH_NAME == "main"
                }
            }

            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: 'Github_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')
                    ]) {
                        sh 'git config --global user.email "jenkin@gmail.com"'
                        sh 'git config --global user.name "Jenkin"'

                        sh "git remote set-url origin https://${USER}:${PWD}@github.com/ManhTrinhNguyen/Jenkin-Exercise-Java-Maven.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh 'git push origin HEAD:Deploy-to-EC2-sshagent'
                    } 
                }
            }
        }              
    }
} 

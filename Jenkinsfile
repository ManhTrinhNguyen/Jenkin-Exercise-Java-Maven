// library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
//     [$class: 'GitSCMSource',
//      remote: 'https://github.com/ManhTrinhNguyen/Share_Library_Exercise.git',
//      credentialsId: 'Github_Credential'
//     ]
// )

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    environment {
        DOCKER_REPO = 'nguyenmanhtrinh/demo-app'
        APP_NAME = 'java-maven'
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
                    env.IMAGE_NAME = "${APP_NAME}-$version-$BUILD_NUMBER"
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
                    echo "build Jar"
                    sh "mvn clean package"
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
                }
            }
        }

        stage("deploy") {
            environment {
                AWS_ACCESS_KEY_ID = credentials('Aws_Access_Key_Id')
                AWS_SECRET_ACCESS_KEY = credentials('Aws_Secret_Access_Key')
            }
            steps {
                script {
                    echo "deploy docker images ...."
                    sh 'envsubst < Kubernetes/java-maven-deployment.yaml | kubectl apply -f -'
                    sh 'envsubst < Kubernetes/java-maven-service.yaml | kubectl apply -f -'
                }
            }
        } 

        stage("Commit to Git Repo") {
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
                        sh 'git push origin HEAD:Deploy-With-AWS-EKS'
                    } 
                }
            }
        }              
    }
} 

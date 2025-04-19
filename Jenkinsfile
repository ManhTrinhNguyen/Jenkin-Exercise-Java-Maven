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
                }
            }
        }

        stage("Provison Server") {
            environment {
                AWS_ACCESS_KEY_ID = credentials('Aws_Access_Key_Id')
                AWS_SECRET_ACCESS_KEY = credentials('Aws_Secret_Access_Key')
                TF_VAR_env_prefix = "test"
            }

            steps {
                script {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                        def EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()

                        env.EC2_PUBLIC_IP = EC2_PUBLIC_IP
                    }
                }
            }
        }

        stage("deploy") {
            environment {
                DOCKER_HUB_CRED = credentials('Docker_Hub_Credential')
            }
            steps {
                script {
                    echo "Initializing EC2 Instance"

                    sleep(time: 90, unit: "SECONDS")

                    echo "Deploying Image to EC2"
                    echo "EC2 Public IP ${EC2_PUBLIC_IP}"

                    def shellCmd = "bash ./entry-script.sh ${DOCKER_REPO}:${IMAGE_NAME} ${DOCKER_HUB_CRED_USR} ${DOCKER_HUB_CRED_PSW}"
                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                    sshagent(['AWS_Credential']) {
                        sh "scp docker-compose.yaml -o StrictHostKeyChecking=no ${ec2Instance}:/home/ec2-user"
                        sh "scp entry_script -o StrictHostKeyChecking=no ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
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
                        sh 'git push origin HEAD:Deploy-Provisoning-with-Terraform'
                    } 
                }
            }
        }              
    }
} 

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
        ANSIBLE_SERVER = '209.38.76.13'
    }

    
    stages {
        // stage("Version Increment Dynamic"){
        //     steps {
        //         script {
        //             echo 'Increment App Version ...'
        //             sh 'mvn build-helper:parse-version versions:set \
        //                 -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
        //                 versions:commit'

        //             def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
        //             def version = matcher[0][1]
        //             env.IMAGE_NAME = "java-maven-$version-$BUILD_NUMBER"
        //         }
        //     }
        // }

        stage("Copy files to Ansible Server") {
            steps {
                script {
                    sshagent(['Ansbile_Server_Credentials']) {
                        sh "scp -o StrictHostKeyChecking=no ansible/* root@${ANSIBLE_SERVER}:/root"
                        withCredentials([sshUserPrivateKey(credentialsId: 'EC2_Server_Key', keyFileVariable: 'keyfile', usernameVariable: 'user')]){
                            sh ''' 
                                scp $keyfile root@$ANSIBLE_SERVER:/root/.ssh/ansible.pem
                            '''
                        }
                    }
                }
            }
        }

        stage("ansible") {
            steps {
                script {
                    def remote = [:]
                    remote.name = "ansible-server"
                    remote.host = ANSIBLE_SERVER
                    remote.allowAnyHosts = true
                    
                    // I will use withCredentials to get username and private key for the remote object .

                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'Ansbile_Server_Credentials', keyFileVariable: 'keyfile', usernameVariable: 'user')
                    ]){
                        remote.user = "root"
                        remote.identityFile = keyfile

                        // Execute the command 
                        sshCommand remote: remote, command: "ls -l"
                        sshCommand remote: remote, command: "bash prepare-ansible-server.yaml"
                        sshCommand remote: remote, command: "ansible-playbook -i hosts deploy-docker-ec2-user.yaml"

                    }
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    echo "Build Jar"
                }
            }
        }

        stage("build docker image") {
            steps {
                script {
                    echo "Build Image"
                }
            }
        }

        stage("Login to Docker Hub") {
            steps {
                script {
                    echo "Docker Login"
                    sh "docker ps"
                }
            }
        }

        stage("Push Image to Docker Hub"){
            steps {
                script {
                    echo "Push image"
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "deploy ....."
                }
            }
        } 

        // stage("Commit to Git Repo") {
        //     steps {
        //         script {
        //             withCredentials([
        //                 usernamePassword(credentialsId: 'Github_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')
        //             ]) {
        //                 sh 'git config --global user.email "jenkin@gmail.com"'
        //                 sh 'git config --global user.name "Jenkin"'

        //                 sh "git remote set-url origin https://${USER}:${PWD}@github.com/ManhTrinhNguyen/Jenkin-Exercise-Java-Maven.git"
        //                 sh 'git add .'
        //                 sh 'git commit -m "ci: version bump"'
        //                 sh 'git push origin HEAD:main'
        //             } 
        //         }
        //     }
        // }              
    }
} 

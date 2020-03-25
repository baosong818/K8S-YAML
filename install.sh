#!/bin/bash
echo "生成ssh公钥、密钥"
sleep 3
ssh-keygen -t rsa -f ./id_rsa -C "ops@bochtec.com"

echo "创建Gerrit服务"
sleep 3
kubectl apply -f ./1-Gerrit/gerrit-nginx.yaml
kubectl apply -f ./1-Gerrit/gerrit-storage.yaml
kubectl apply -f ./1-Gerrit/postgresql-gerrit-deployment.yaml
kubectl apply -f ./1-Gerrit/postgresql-gerrit-storage.yaml
kubectl apply -f ./1-Gerrit/gerrit-configmap.yaml
kubectl apply -f ./1-Gerrit/gerrit-deployment.yaml

Gerrit_POD=`kubectl get pod -n kube-ops | grep "gerrit" | egrep -v "nginx|postgres" | awk '{print $1}'`
kubectl -n kube-ops exec -it ${Gerrit_POD} -- mkdir /var/gerrit/.ssh
kubectl -n kube-ops cp ./id_rsa ${Gerrit_POD}:/var/gerrit/.ssh/id_rsa
kubectl -n kube-ops cp ./id_rsa.pub ${Gerrit_POD}:/var/gerrit/.ssh/authorized_keys
kubectl -n kube-ops exec -it ${Gerrit_POD} -- chmod 700 /var/gerrit/.ssh
kubectl -n kube-ops exec -it ${Gerrit_POD} -- chmod 600 /var/gerrit/.ssh/id_rsa /var/gerrit/.ssh/authorized_keys
kubectl -n kube-ops exec -it ${Gerrit_POD} -- chown 1000:1000 -R /var/gerrit/.ssh

echo "创建SonarQube服务"
sleep 3
kubectl apply -f ./2-SonarQube/postgresql-sonar-deployment.yaml
kubectl apply -f ./2-SonarQube/postgresql-sonar-storage.yaml
kubectl apply -f ./2-SonarQube/sonarqube-deployment.yaml
kubectl apply -f ./2-SonarQube/sonarqube-storage.yaml

echo "创建Gitlab服务"
sleep 3
kubectl apply -f ./3-Gitlab/gitlab-deployment.yaml
kubectl apply -f ./3-Gitlab/gitlab-storage.yaml

Gitlab_POD=`kubectl get pod -n kube-ops | grep "gitlab" | awk '{print $1}'`
kubectl -n kube-ops exec -it ${Gitlab_POD} -- mkdir /root/.ssh
kubectl -n kube-ops cp ./id_rsa.pub ${Gitlab_POD}:/root/.ssh/authorized_keys
kubectl -n kube-ops exec -it ${Gitlab_POD} -- chmod 700 /root/.ssh
kubectl -n kube-ops exec -it ${Gitlab_POD} -- chmod 600 /root/.ssh/authorized_keys

echo "创建Jenkins服务"
sleep 3
kubectl apply -f ./4-Jenkins/jenkins-rbac.yaml
kubectl apply -f ./4-Jenkins/jenkins-storage.yaml
kubectl apply -f ./4-Jenkins/jenkins-deployment.yaml

Jenkins_POD=`kubectl get pod -n kube-ops | grep "jenkins" | awk '{print $1}'`
kubectl -n kube-ops exec -it ${Jenkins_POD} -- mkdir /var/jenkins_home/.ssh
kubectl -n kube-ops cp ./id_rsa ${Jenkins_POD}:/var/jenkins_home/.ssh/id_rsa
kubectl -n kube-ops cp ./id_rsa.pub ${Jenkins_POD}:/var/jenkins_home/.ssh/authorized_keys
kubectl -n kube-ops exec -it ${Jenkins_POD} -- chmod 700 /var/jenkins_home/.ssh
kubectl -n kube-ops exec -it ${Jenkins_POD} -- chmod 600 /var/jenkins_home/.ssh/id_rsa /var/jenkins_home/.ssh/authorized_keys
kubectl -n kube-ops exec -it ${Jenkins_POD} -- chown 1000:1000 -R /var/jenkins_home/.ssh

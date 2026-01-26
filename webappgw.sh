#!/bin/bash
sudo apt update -y
sudo apt install sshpass -y
echo "Setting up helloPool VMs"
for i in {1..3}
do
j=$(($i + 3))
ip="10.0.1.$j"
sshpass -p "VMP@55w0rd" \
ssh -o StrictHostKeyChecking=no rithin@$ip bash -c
\
"'export VAR=$i
printenv | grep VAR
echo "Setting up hello-0$i VM"
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
mkdir /var/www/html/hello
echo "HelloPool wants to say hi from hello-0$i">
/var/www/html/hello/hello.html
exit
'"
done
echo "Setting up byePool VMs"
for i in {1..3}
do
j=$(($i + 3))
ip="10.0.2.$j"
sshpass -p "VMP@55w0rd" \
ssh -o StrictHostKeyChecking=no rithin@$ip bash -c
\

"'export VAR=$i
printenv | grep VAR
echo "Setting up bye-0$i VM"
sudo apt install apache2 -y
sudo chmod -R -v 777 /var/www/
mkdir /var/www/html/bye
echo "ByePool wants to say bye from bye-0$i">
/var/www/html/bye/bye.html
exit
'"
done

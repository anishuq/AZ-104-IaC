#!/bin/bash

# Pre-requisites on Jumpbox
sudo apt update -y
sudo apt install sshpass -y

PASSWORD="McIe@4-5WmFvM"

echo "Setting up helloPool VMs"
for i in {1..3}
do
    j=$(($i + 3))
    ip="10.0.1.$j"
    echo "Configuring HelloServer-vm0$i at $ip..."
    
    # We pipe the Heredoc into /bin/bash on the remote host
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no admanisulhuq@$ip /bin/bash <<EOF
        export VAR=$i
        printenv | grep VAR
        echo "Setting up HelloServer-vm0$i"
        
        sudo apt update -y
        sudo apt install apache2 -y
        sudo chmod -R -v 777 /var/www/
        sudo mkdir -p /var/www/html/hello
        echo "HelloPool wants to say hi from HelloServer-vm0$i" | sudo tee /var/www/html/hello/hello.html
EOF
done

echo "---"

echo "Setting up byePool VMs"
for i in {1..3}
do
    j=$(($i + 3))
    ip="10.0.2.$j"
    echo "Configuring ByeServer-vm0$i at $ip..."
    
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no admanisulhuq@$ip /bin/bash <<EOF
        export VAR=$i
        printenv | grep VAR
        echo "Setting up ByeServer-vm0$i"
        
        sudo apt update -y
        sudo apt install apache2 -y
        sudo chmod -R -v 777 /var/www/
        sudo mkdir -p /var/www/html/bye
        echo "ByePool wants to say bye from bye-0$i" | sudo tee /var/www/html/bye/bye.html
EOF
done
#! /bin/bash
sudo yum update
sudo yum install httpd -y
sudo systemctl start httpd
sudo chmod -R 777 /var/www/html/
sudo echo "<h1>Hello from terraform</h1>" /var/www/html/info.php
#!/bin/bash
apt-get install -y apache2 php

echo "Hello from <b><?php echo gethostname(); ?></b>" | tee /var/www/html/index.php

sed 's/80/8080/' /etc/apache2/ports.conf

systemctl restart apache2
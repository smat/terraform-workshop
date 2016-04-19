#!/bin/sh

yum -y install httpd
service httpd start

echo "OK" >/var/www/html/healthcheck.txt
cat >/var/www/html/index.html <<HTMLDOC
<html>
<head>
  <title>En artig webside</title>
</head>
<body>
  <h1>Ja, du har klart det</h1>
  <p>Webserveren er oppe og kjører</p>
</body>
</html>
HTMLDOC


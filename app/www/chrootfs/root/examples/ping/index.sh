#!/bin/sh
NAME="ping"
echo "<html><head>"
echo "<title>$NAME</title>"
echo '<meta name="description" content="'$NAME'">'
echo '<meta name="keywords" content="'$NAME'">'
echo '<meta http-equiv="Content-type" content="text/html;charset=UTF-8">'
echo '<meta name="ROBOTS" content="noindex">'
echo "</head><body><pre>"
echo "<p><strong>PING:</strong></p>"
echo "<pre>"
/bin/ping -c 1 google.com
echo "</pre>"
echo "</body>"
echo "</html>"
#!/bin/sh
NAME="example"
echo "<html><head>"
echo "<title>$NAME</title>"
echo '<meta name="description" content="'$NAME'">'
echo '<meta name="keywords" content="'$NAME'">'
echo '<meta http-equiv="Content-type"
content="text/html;charset=UTF-8">'
echo '<meta name="ROBOTS" content="noindex">'
echo "</head><body><pre>"
echo "date and time: "
date
echo "\n"
echo "docker run hello-world"
docker run hello-world
echo "</pre></body></html>"
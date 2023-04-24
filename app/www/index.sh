#!/bin/sh

NAME="uname"
BASEDIR=$(dirname "$0")

echo "<html><head>"
echo "<title>$NAME</title>"
echo '<meta name="description" content="'$NAME'">'
echo '<meta name="keywords" content="'$NAME'">'
echo '<meta http-equiv="Content-type" content="text/html;charset=UTF-8">'
echo '<meta name="ROBOTS" content="noindex">'
echo "</head><body>"
echo "<pre>"
echo "Welcome to the SHELL Website!"
echo "</pre>"
echo "example: "
for f in $BASEDIR/examples/*; do
  echo "<p><a href='../$f'>$f</a></p>"
done
sleep 2
echo "<p>did sleep for two seconds</p>"
echo "</body>"
echo "</html>"
#!/bin/sh

NAME="Welcome"
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
  echo "<p>$f</p>"
done
echo "<a href=\"./examples\">examples</a>"
echo "</body>"
echo "</html>"
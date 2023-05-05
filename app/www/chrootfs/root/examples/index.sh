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
echo "${NAME} to the SHELL Website!"
echo "basedir=${BASEDIR}"
echo "</pre>"
echo "<p><a href="/examples/ping">ping</a></p>"
echo "<p><a href="/examples/date">date</a></p>"
echo "<p><a href="/examples/cpuinfo">cpuinfo</a></p>"
echo "<p><a href="/examples/uname">uname</a></p>"
echo "</body>"
echo "</html>"
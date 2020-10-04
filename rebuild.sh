#!/usr/bin/env bash
VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\[')
PROJECT=$(mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.artifactId | grep -v '\[')
# Build first time
mvn clean verify artifact:buildinfo
mv target/$PROJECT-$VERSION.buildinfo .
mv target/$PROJECT-$VERSION.jar .
# Rebuild second time and compare builds
mvn clean verify artifact:buildinfo
diffoscope $PROJECT-$VERSION.buildinfo target/$PROJECT-$VERSION.buildinfo
diffoscope $PROJECT-$VERSION.jar target/$PROJECT-$VERSION.jar
exitCode=$?
mv $PROJECT-$VERSION.buildinfo target/$PROJECT-$VERSION.buildinfo.org
mv $PROJECT-$VERSION.jar target/$PROJECT-$VERSION.jar.org
if [[ "$exitCode" =~ (0) ]]
then
  echo "[SUCCESS] Build has been verified to be reproducible."
else
  echo "[FAILURE] Build was not reproducible check diffoscope output above."
fi
exit $exitCode

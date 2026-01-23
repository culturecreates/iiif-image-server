#!/bin/bash

export JAVA_OPTS="-Xms512m -Xmx2g -XX:+UseG1GC"

# Install Maven
apt-get update && apt-get install -y maven

echo "Build the application"
mvn clean package -DskipTests

echo "Run the application"
mvn clean compile exec:java -Dexec.jvmArgs="$JAVA_OPTS" -Dcantaloupe.config=cantaloupe.properties

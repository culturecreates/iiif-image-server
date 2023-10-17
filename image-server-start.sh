#!/bin/bash

# Install Maven
apt-get update && apt-get install -y maven

echo "Build the application"
mvn clean package -DskipTests

echo "Run the application"
mvn clean compile exec:java -Dcantaloupe.config=cantaloupe.properties
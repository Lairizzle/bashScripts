#!/bin/bash

# Exit on any error
set -e

echo "=== Maven Project Setup ==="

# Prompt user for inputs
read -p "Enter Group ID (e.g., com.example): " GROUP_ID
read -p "Enter Artifact ID (e.g., my-app): " ARTIFACT_ID
read -p "Enter Version (e.g., 1.0-SNAPSHOT): " VERSION
read -p "Enter Package Name (e.g., com.example.app): " PACKAGE
read -p "Enter Java Version (e.g., 17): " JAVA_VERSION

# === Create Maven Project ===
echo "Creating Maven project..."
mvn archetype:generate \
  -B \
  -DarchetypeGroupId=org.apache.maven.archetypes \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DarchetypeVersion=1.4 \
  -DgroupId="$GROUP_ID" \
  -DartifactId="$ARTIFACT_ID" \
  -Dversion="$VERSION" \
  -Dpackage="$PACKAGE"

cd "$ARTIFACT_ID"

# === Remove existing <properties> if any ===
xmlstarlet ed -L \
  -d "/project/properties" \
  pom.xml

# === Insert the correct Java version in <properties> ===
xmlstarlet ed -L \
  -s "/project" -t elem -n "propertiesTMP" -v "" \
  -s "/project/propertiesTMP" -t elem -n "project.build.sourceEncoding" -v "UTF-8" \
  -s "/project/propertiesTMP" -t elem -n "maven.compiler.source" -v "$JAVA_VERSION" \
  -s "/project/propertiesTMP" -t elem -n "maven.compiler.target" -v "$JAVA_VERSION" \
  -r "/project/propertiesTMP" -v "properties" \
  pom.xml

echo "✅ Project '$ARTIFACT_ID' configured with Java version $JAVA_VERSION using <properties>."


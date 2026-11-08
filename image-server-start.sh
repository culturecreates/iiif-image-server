#!/bin/sh
set -e

# Memory budget for the 3g container limit (docker-compose.yml mem_limit).
# The Java heap is only part of the process's footprint: metaspace, code cache,
# thread stacks, direct buffers and native image-codec allocations all live
# outside it, so the heap must stay well below the container limit.
#
# - Xmx1g:                 live heap in production is ~100 MB; 1g leaves room
#                          for decoding large images.
# - MaxMetaspaceSize /
#   MaxDirectMemorySize:   cap the other JVM-managed off-heap pools.
# - ExitOnOutOfMemoryError: exit (and let Docker restart us) instead of
#                          limping along after a heap OOM.
# - NativeMemoryTracking:  lets us inspect off-heap usage in production with
#                          `jcmd <pid> VM.native_memory summary`.
JAVA_OPTS="-Xms512m -Xmx1g -XX:+UseG1GC \
  -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=256m \
  -XX:+ExitOnOutOfMemoryError -XX:NativeMemoryTracking=summary"

# glibc creates up to 8 malloc arenas per core for multi-threaded processes,
# which fragments native memory used by the image codecs and lets the
# process's RSS grow far beyond the heap. Limit the number of arenas.
export MALLOC_ARENA_MAX=2

# Install Maven
apt-get update && apt-get install -y maven

echo "Build the application"
mvn clean package -DskipTests

# Run the packaged JAR in its own JVM. (Previously the app ran via
# `mvn exec:java`, which runs inside Maven's JVM and silently ignores
# -Dexec.jvmArgs, so none of the options above were ever applied.)
JAR=$(ls target/cantaloupe-*.jar | head -n 1)

echo "Run the application ($JAR)"
# shellcheck disable=SC2086 # JAVA_OPTS is intentionally word-split
exec java $JAVA_OPTS -Dcantaloupe.config=cantaloupe.properties -jar "$JAR"

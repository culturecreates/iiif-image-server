FROM eclipse-temurin:11-jdk-jammy

ENV JAVA_TOOL_OPTIONS="-Xms512m -Xmx2g -XX:+UseG1GC"

WORKDIR /usr/src/app

COPY image-server-start.sh ./image-server-start.sh
RUN chmod +x ./image-server-start.sh

COPY . .

EXPOSE 8181

ENTRYPOINT ["sh","./image-server-start.sh"]

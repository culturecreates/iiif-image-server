FROM openjdk:11-slim

WORKDIR /usr/src/app

COPY image-server-start.sh ./image-server-start.sh
RUN chmod +x ./image-server-start.sh

COPY . .

EXPOSE 8181

ENTRYPOINT ["sh","./image-server-start.sh"]

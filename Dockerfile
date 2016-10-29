FROM openjdk:8-jdk-alpine
MAINTAINER rainu <rainu@raysha.de>

ENV INTELLIJ_LINK http://download.jetbrains.com/idea/ideaIU-2016.2.5.tar.gz
ENV GOLANG http://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz

ENV uid 1000
ENV gid 1000

#make home directory for intellij user
RUN mkdir -p /home/intellij && \
    mkdir -p /home/intellij/bin &&\
    mkdir -p /home/intellij/.m2 && \
    echo "intellij:x:${uid}:${gid}:IntelliJ User,,,:/home/intellij:/bin/bash" >> /etc/passwd && \
    echo "intellij:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /home/intellij

#download and extract intelliJ-Ultimate
RUN wget $INTELLIJ_LINK -O /tmp/intellij.tar.gz &&\
	mkdir /opt/ &&\
	tar -xzvf /tmp/intellij.tar.gz -C /opt/ && mv /opt/$(ls /opt/) /opt/intellij/ &&\
	chown ${uid}:${gid} -R /opt/intellij &&\
	rm /tmp/intellij.tar.gz &&\
	rm -rf /opt/intellij/jre/jre && ln -s $JAVA_HOME/jre /opt/intellij/jre/jre

#download and extract golang
RUN wget $GOLANG -O /tmp/golang.tar.gz &&\
	tar -xzvf /tmp/golang.tar.gz -C /usr/local/ &&\
	chown ${uid}:${gid} -R /usr/local/go &&\
	rm /tmp/golang.tar.gz

COPY ./start.sh /home/intellij/start.sh

ENTRYPOINT ["/home/intellij/start.sh"]

FROM java:openjdk-8-jdk
MAINTAINER rainu <rainu@raysha.de>

ENV INTELLIJ_LINK https://download.jetbrains.com/idea/ideaIU-2016.1.3.tar.gz

RUN wget $INTELLIJ_LINK -O /tmp/intellij.tar.gz &&\
	tar -xzvf /tmp/intellij.tar.gz -C /opt/ && mv /opt/$(ls /opt/) /opt/intellij/ &&
	rm -rf /opt/intellij/jre/jre && ln -s $JAVA_HOME/jre /opt/intellij/jre/jre

#make home directory for intellij user
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/intellij && \
    echo "intellij:x:${uid}:${gid}:IntelliJ User,,,:/home/intellij:/bin/bash" >> /etc/passwd && \
    echo "intellij:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /opt/intellij &&\
    chown ${uid}:${gid} -R /home/intellij

COPY ./start.sh /home/intellij/start.sh

ENTRYPOINT ["/home/intellij/start.sh"]
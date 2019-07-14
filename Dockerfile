FROM openjdk:7

RUN apt-get update && \
   apt-get install -y wget unzip pwgen && \
   wget http://download.oracle.com/glassfish/3.1.2/release/glassfish-3.1.2.zip && \
   unzip glassfish-3.1.2.zip -d /opt && \
   rm glassfish-3.1.2.zip && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*

ENV GLASSFISH_CONFIG /gf_config
ENV GLASSFISH_DEPLOY /gf_deploy
ENV PATH /opt/glassfish3/bin:$PATH   

ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 4848 8080 8181

ENTRYPOINT [ "/docker-entrypoint.sh" ]
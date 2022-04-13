# main
FROM ubuntu:20.04
MAINTAINER wlados

# for servers
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# for confguring image
COPY --chmod=777 ./setup.sh /home/setup.sh
RUN ./home/setup.sh

# for PostgreSQL connection
COPY --chmod=640 --chown=postgres:postgres ./pg_hba.conf /etc/postgresql/12/main/pg_hba.conf
COPY --chmod=777 ./postgres_custom.sh /usr/local/bin/postgres_custom.sh

# for configuring supervisor daemon
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# for storing
COPY ./geocit134.sh /home/geocit134.sh

# for deploying Geo Citizen
COPY ./citizen.war /opt/tomcat/latest/webapps/citizen.war

# for supervisord web interface
COPY --chmod=644 ./supervisord_main.conf /etc/supervisor/supervisord.conf

# for PostgreSQL, Tomcat, Supervisord Web interface, Apache2
EXPOSE 5432 8080 9001 80

# for multiservicing by supervisor daemon
CMD ["/usr/bin/supervisord"]

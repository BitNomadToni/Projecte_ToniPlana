FROM docker.elastic.co/logstash/logstash:8.12.0

# Instal·lem el plugin CSV
RUN bin/logstash-plugin install logstash-codec-csv

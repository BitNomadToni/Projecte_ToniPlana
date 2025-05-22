Pasos:
	1.Ens situem en la carpeta on estiga el dockerfile i executem el segúent: "docker build -t logstash-custom:8.12.0 ." Imatge per a que logstash instale plugin per a csv automàticament.
	2.Creem la xarxa: "docker network create valldigna_net"
	3.Permisos al wait-for-it.sh que s'encarrega de que kafka espere a que zookeeper estiga escoltant pel port corresponent per a arrancar:"chmod 755 wait-for-it.sh"
	4.Executar el .yml: "docker compose up -d"










Estructura de directoris:
	\___docker-compose.yml
	 \__wait-for-it.sh
	  \_logstash
	            \_pipeline
	                      \__netflow_to_kafka.conf
	                       \_kafka_to_elastic_and_csv.conf
                       
                       
                       
Tenir en compte:
	1. Ruta on es guarda el csv amb el trafic al contenidor logstash: /tmp/sortida.csv comanda per a acedir al contenidor. "docker exex -it logstash /bin/bash"
	2.

Guia de monitorage de xarxa.
Pasos:
	1.Ens situem en la carpeta on estiga el dockerfile i executem el segúent: "docker build -t logstash-custom:8.12.0 ." Imatge per a que logstash instale plugin per a csv automàticament.
	2.Creem la xarxa: "docker network create valldigna_net"
	3.Permisos al wait-for-it.sh que s'encarrega de que kafka espere a que zookeeper estiga escoltant pel port corresponent per a arrancar:"chmod 755 wait-for-it.sh"
	4.Executar el .yml: "docker compose up -d"
	5.Configurem el router Mikrotik per enviar les dades de Netflow pel port UDP 2055 (port per defecte).
	6.Creació dels pipeline: 
		
		Pipeline 1: Ingressar dades de Netflow a Kafka.

		Pipeline 2: Transferir dades de Kafka a Elasticsearch.
	
		Pipeline 3 (opcional): Guardar dades en CSV per a anàlisi offline o backup.

	7.Observem l’entrada de dades als tòpics Kafka (els tòpics es creen automàticament si no existeixen).
	8.Configuració del dashboard Kibana








Estructura de directoris:
	\____docker-compose.yml
	 \___dades
	  \       \_sortida.csv
	   \__wait-for-it.sh
	    \_logstash
	              \_pipeline
	                        \___netflow_to_kafka.conf
	                         \__kafka_to_elastic.conf
	                          \_kafka_to_csv.conf
                       
                       
Comandes útils:

	1. Ruta on es guarda el csv amb el trafic al contenidor logstash: "/tmp/sortida.csv" comanda per a acedir al contenidor: "docker exex -it logstash /bin/bash"
	2. Comanda per a copiar les dades del csv a la carpeta dades: "docker cp logstash:/tmp/csv ./dades"
	
	
	
	
Notes addicionals:

El pipeline CSV és opcional, es pot activar o desactivar segons necessitat.

El wait-for-it.sh ajuda a gestionar l'ordre d'arrencada dels serveis perquè Kafka no intente connectar a Zookeeper abans que estiga llest.

Hi ha que tenir en compte els firewalls tant del router mikrotik com de la nostra màquina.

És recomanable revisar que la xarxa valldignalive_net estiga creada i que tots els contenidors la utilitzen per comunicar-se entre ells.

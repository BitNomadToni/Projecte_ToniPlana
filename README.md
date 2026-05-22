
# Guia de monitoratge de xarxa

## Passos

1. Ens situem a la carpeta on està el `Dockerfile` i executem el següent:  
   ```bash
   docker build -t logstash-custom:8.12.0 .
   ```  
   Aquesta imatge permet que Logstash instal·le automàticament el plugin per a CSV.

2. Creem la xarxa Docker:  
   ```bash
   docker network create valldigna_net
   ```

3. Assignem permisos d'execució al script `wait-for-it.sh`, que s'encarrega que Kafka espere que Zookeeper estiga escoltant pel port corresponent abans d'arrancar:  
   ```bash
   chmod 755 wait-for-it.sh
   ```

4. Executem el fitxer `.yml` amb Docker Compose:  
   ```bash
   docker compose up -d
   ```

5. Configurem el router Mikrotik per enviar les dades de Netflow pel port UDP 2055 (port per defecte).

6. Creació dels pipelines personalitzats (en cas de no voler fer ús dels que proporcionem al Git-hub):

   - **Pipeline 1:** Ingressar dades de Netflow a Kafka.  
   - **Pipeline 2:** Transferir dades de Kafka a Elasticsearch.  
   - **Pipeline 3 (opcional):** Guardar dades en CSV per a anàlisi offline o backup.

7. Observem l’entrada de dades als tòpics Kafka (els tòpics es creen automàticament si no existeixen).

8. Configuració del dashboard Kibana.

---

## Estructura de directoris

```
\____docker-compose.yml
 \___dades
  \       \_sartida.csv
   \__wait-for-it.sh
    \_logstash
              \_pipeline
                        \___netflow_to_kafka.conf
                         \__kafka_to_elastic.conf
                          \_kafka_to_file.conf
```

---

## Comandes útils

1. Ruta on es guarda el CSV amb el tràfic dins del contenidor Logstash:  
   `/tmp/sortida.csv`  
   Comanda per accedir al contenidor:  
   ```bash
   docker exec -it logstash /bin/bash
   ```

2. Comanda per copiar les dades del CSV a la carpeta local `dades`:  
   ```bash
   docker cp logstash:/tmp/sortida.csv ./dades
   ```
   
3. Comanda per a comprovar que arriben paquets desde el port per defecte de Netflow `2055`:  
   ```bash
   tcpdump -n -i any udp port 2055
   ```

4. Comanda per a inspeccionar la xarxa:  
   ```bash
   docker network inspect valldigna_net
   ```

5. Comanda per a reiniciar un contenidor:  
   ```bash
   docker restart <nom del contenidor>
   ```
---

## Notes addicionals

- El pipeline per al fitxer CSV és opcional i es pot activar o desactivar segons necessitat.
- Pots desactivar piplines de Logstash ocultant el fitxer (recorda fer un restart a Logstash).
- El script `wait-for-it.sh` ajuda a gestionar l'ordre d'arrencada dels serveis perquè Kafka no intente connectar a Zookeeper abans que estiga llest.
- Cal tenir en compte els firewalls tant del router Mikrotik com de la nostra màquina.
- És recomanable revisar que la xarxa `valldigna_net` estiga creada i que tots els contenidors la utilitzen per comunicar-se entre ells.
- Recorda que si fas ús de Node-Red per a insertar dades, has de tenir instal·lat els nodes `node-red-contrib-kafkajs` i `node-red-node-data-generator`.
- Revisa que el kafkajs-producer tinga assignada la IP que corresponga a kafka. Ho pots revisar amb l'apartat 4 de comandes útils (si la IP no es correcta Node-Red pot donar problemes).

---

## Portabilitat dels Dashboards (Kibana)

Quan clones o muntes el projecte en una nova màquina, Elasticsearch s'inicialitza buit i perds els dashboards i visualitzacions que tenies configurats a Kibana. 

Per solucionar-ho de forma totalment automatitzada i opcional, hem afegit el fitxer `netflow_dashboards.ndjson` al repositori i una configuració comentada al `docker-compose.yml`.

### Com importar automàticament els dashboards en una instal·lació neta:

1. Assegura't de tenir el fitxer `netflow_dashboards.ndjson` a la carpeta del projecte.
2. Obre el fitxer `docker-compose.yml` i cerca el servei comentat `kibana-import-dashboards` (al final del servei `kibana`).
3. Descomenta el servei sencer (traient el caràcter `#` al principi de cada línia).
4. Executa Docker Compose normalment:
   ```bash
   docker compose up -d
   ```
5. Aquest contenidor auxiliar (basat en `curlimages/curl`):
   * Esperarà activament a que Kibana estiga completament aixecat i escoltant en el port `5601`.
   * Farà una petició POST automàtica a la API d'objectes desats de Kibana (`/api/saved_objects/_import`) per carregar les visualitzacions, mapes i quadres de comandament de forma nativa.
   * Un cop finalitzat el procés, s'aturarà de forma neta i podràs veure el resultat de la importació als logs del contenidor:
     ```bash
     docker logs kibana-import-dashboards
     ```

Aquesta és una alternativa ideal per a desplegar el projecte ràpidament a GitHub o en entorns de producció nets, assegurant que els mapes GeoIP i les estadístiques es mantinguen sense necessitat d'importar-los manualment.


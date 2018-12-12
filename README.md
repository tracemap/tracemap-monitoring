# tracemap-monitoring :computer:

> This repository tracks all confguration for our monitoring with a dockerized elastic stack.

## Table of contents

- [:clipboard: Project Structure](https://github.com/jonathanschlue/tracemap-monitoring#project-structure-clipboard)
- [:construction: Setup](https://github.com/jonathanschlue/tracemap-monitoring#setup-construction)
- [:hammer: Deployment](https://github.com/jonathanschlue/tracemap-monitoring#deployment-hammer)
- [:fist: Adding a new Beat](https://github.com/jonathanschlue/tracemap-monitoring#adding-a-new-beat-fist)
- [:chart_with_upwards_trend: Spooling arbitrary JSON logs into the system](https://github.com/jonathanschlue/tracemap-monitoring#spooling-arbitrary-json-logs-into-the-system-chart_with_upwards_trend)
- [:link: Further Readings](https://github.com/jonathanschlue/tracemap-monitoring#further-readings-link)
- [:crystal_ball: Dashboards Online](https://github.com/jonathanschlue/tracemap-monitoring#dashboards-online-crystal_ball)
- [:heavy_check_mark: Basic Health Checks (no dashboards)](https://github.com/jonathanschlue/tracemap-monitoring#basic-health-checks-no-dashboards-heavy_check_mark)

## Project Structure :clipboard:

```txt
.
├── config
│   ├── apm-server
│   │   └── netcup-apm-server-api.yml
│   ├── elasticsearch
│   │   ├── elasticsearch.yml
│   │   ├── jvm.options
│   │   └── log4j2.properties
│   ├── filebeat
│   │   ├── netcup-filebeat-cw-queue.yml
│   │   ├── netcup-filebeat-nginx.yml
│   │   └── netcup-filebeat-tm-gen.yml
│   ├── heartbeat
│   │   └── netcup-heartbeat.yml
│   ├── kibana
│   │   └── kibana.yml
│   ├── logstash
│   │   └── logstash.yml
│   ├── metricbeat
│   │   └── netcup-metricbeat-system.yml
│   └── packetbeat
│       └── netcup-packetbeat.yml
├── deploy.sh
├── docker-compose-netcup.yml
├── logs
├── README.md
├── scripts
│   ├── adjust-log-field-mappings.sh
│   ├── alert-server-status.sh
│   ├── chmod-nginx-logs-readable.sh
│   ├── crawler-writer-queue.py
│   ├── crawler-writer-queue.sh
│   ├── server-status.sh
│   └── update-config-permissions.sh
└── templates
    ├── filebeat-cw-queue-template.json
    └── filebeat-tm-gen-template.json
```

| **File**                  | **Description**                                                    |
| ------------------------- | ------------------------------------------------------------------ |
| config                    | Per docker configuration files                                     |
| deploy.sh                 | Deployment script to push this project to the netcup server        |
| docker-compose-netcup.yml | docker-compose file for the netcup server                          |
| logs                      | Holds manually genereated logs, e.g. the cw-queue data             |
| scripts                   | Contains utility and monitoring scripts in bash and python         |
| templates                 | Contains an elastic search index tepmlate for each custom filebeat |

## Setup :construction:

```sh
# deploy to remote
./deploy.sh

# logon to remote
ssh tm-ns

# switch to executive user
su -l tracemap

# change to project directory
core
cd tracemap-monitoring

# create docker-compose.yml shortcut ONCE for convenience
ln -s docker-compose-netcup.yml docker-compose.yml

# update config permissions to grant in-docker-access
cd scripts
./update-config-permissions.sh
cd ..

# optionally, switch to or create a monitoring tmux session
tmux new -s monitoring

# startup docker network
docker-compose up

# in a second terminal, restart startup-timed-out beats
docker-compose up -d
```

### Notes

- A `.env` file is needed for starting the script `alert-server-status.sh` and is not located in this project.
- The `nginx` logs need be accessable via the filebeat docker. To ensure that, run `scripts/chmod-nginx-logs-readable.sh` on a regular basis (e.g. via a cron job).

## Deployment :hammer:

On your development machine, run:

```sh
./deploy.sh
```

Then logon to the remote deployment target and enable docker-access to the config files:

```sh

# logon to remote server
ssh tm-ns

# switch to executive user
su -l tracemap

# switch to project directory
core
cd tracemap-monitoring

# update config permissions
cd scripts
./update-config-permissions.sh
cd ..
```

Then restart any docker inside the docker compose network, for which configuration changes should be applied.

## Adding a new Beat :fist:

1. Add entry to `docker-compose-netcup.yml` commenting out the config file mapping at first (example shows filebeat, any other beat is possible):

```config
...

netcup-filebeat-example:
    image: docker.elastic.co/beats/filebeat:6.4.2
    container_name: netcup-filebeat-example
    volumes:

      ...

      # add config file
      # - ./config/filebeat/netcup-filebeat-example.yml:/usr/share/filebeat/filebeat.yml

      ...

    networks:
      - elknet

...
```

2. Extract the default in-docker beat config via `docker cp`:

```sh
docker cp netcup-filebeat-example:/usr/share/filebeat/filebeat.yml ./config/filebeat/netcup-filebeat-example.yml
```

3. Update config file permissions on host:

```sh
cd scripts
./update-config-permissions.sh
```

4. Stop, restart and recreate the newly created docker:

```sh
# stop
docker stop netcup-filebeat-example

# restart and recreate
docker-compose up -d --force-recreate
```

Now the new docker should be adhearing to the specified config file. After changing and re-deploying a config file, make sure to restart the corresponding docker to apply the config changes.

## Spooling arbitrary JSON logs into the system :chart_with_upwards_trend:

1. Create JSON log entries in a one-log-per-line-fashion, essentially filling up a `.jsonl` file, preferrebly in the `logs` directory of the deployment of this project.
1. Create a custom filebeat docker (see above for details).
1. Update the new `filebeat.yml`. You can take `netcup-filebeat-cw-queue.yml` and `netcup-filebeat-tm-gen.yml` for reference.
1. Create a new index template file in `templates`. Again, take the already created templates for reference. Under properties, you shouuld specify a type mapping.
1. Map the newly created index template into your docker via the docker-compose file.
1. Restart and recreate the created docker (see above).
1. In kibana, create a index pattern to view the date under the _Discover_ section.

Now, for each log entry in your `.jsonl` file there should be a document created, retrievable via the above mentioned index pattern in kibana. You can proceed building vizualisations and dashboards from here on.

## Further Readings :link:

- [All Elastic Products](https://www.elastic.co/de/products)
- [Elasticsearch](https://www.elastic.co/de/products/elasticsearch)
- [Kibana](https://www.elastic.co/de/products/kibana)
- [Beats](https://www.elastic.co/de/products/beats)
- [ElasticSerach Mapping](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html)
- [ElasticSearch Field datatypes](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html)

## Dashboards online :crystal_ball:

- [Montoring Home](https://monitoring.tracemap.info)
- [Monitoring Overview](<https://monitoring.tracemap.info/app/kibana#/dashboard/fde375d0-e7a6-11e8-871b-990b8fcafd04?_g=(refreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3A'2018-09-30T22%3A00%3A00.000Z'%2Cmode%3Aabsolute%2Cto%3A'2018-11-30T22%3A59%3A59.999Z'))>) (contains links to all relevant dashboards)
- [All Dashboards](<https://monitoring.tracemap.info/app/kibana#/dashboards?_g=(refreshInterval:(pause:!t,value:0),time:(from:'2018-09-30T22:00:00.000Z',mode:absolute,to:'2018-11-30T22:59:59.999Z'))>)

## Basic health checks (no dashboards) :heavy_check_mark:

### ElasticSearch status

- `curl http://127.0.0.1:9200/_cat/health`
- `curl "http://127.0.0.1:9200/_cluster/health?pretty=true"`.

### Kibana status

Open `https://monitoring.tracemap.info/status` in your preferred web browser.

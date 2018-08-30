# Installation Guide

## Configuring Environment Variables

Open `kube-openmon.yaml` file and set the following variables:

* `spec > template > spec > containers > env > MONITORING_INTERVAL`: The time interval between reading cadvisor logs and storing them into ifnluxdb. Default every 1 seconds.

* `spec > template > spec > containers > env > LOG_LEVEL`: a number between 0 and 3. This is for debugging purposes.

* `spec > template > spec > containers > env > ENABLED`: to disable gathering logs, set to 0. Otherwise 1.

* `spec > template > spec > containers > env > INFLUXDB_ADDRESS`: the InfluxDB server address

* `spec > template > spec > containers > env > INFLUXDB_PORT`: the InfluxDB server port

* `spec > template > spec > containers > env > INFLUXDB_USERNAME`: the InfluxDB username (if any).

* `spec > template > spec > containers > env > INFLUXDB_PASSWORD`: the InfluxDB password (if any).

* `spec > template > spec > containers > env > INFLUXDB_DATABASE`: the InfluxDB database name.

* `spec > template > spec > containers > env > KUBERNETES_CUSTOM_TOKEN`: Kubernetes token (if a custom token is being used)

* `spec > template > spec > containers > env > KUBERNETES_CUSTOM_ADDRESS`: Kubernetes custom address (if any)

* `spec > template > spec > containers > env > KUBERNETES_CUSTOM_PORT`: Kubernetes custom port (if not 6443)

## Deployment

To deploy, run following:
   kubectl apply -f kube-openmon.yaml

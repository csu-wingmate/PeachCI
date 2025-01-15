# How to use Prometheus and Grafana

## Step-0 Installation
After downloading PeachCI to your local machine, run the setup.sh script to install Prometheus and Grafana locally.

## Step-1 Starting and Stopping Services
To manage Prometheus and Grafana services, use the following commands:

For Prometheus:
```bash
sudo systemctl start prometheus
sudo systemctl stop prometheus
sudo systemctl restart prometheus
sudo systemctl status prometheus
```

For Grafana (installed via Snap):
```bash
sudo snap start grafana
sudo snap stop grafana
sudo snap restart grafana
sudo snap services grafana
```

## Step-2 Accessing Prometheus and Grafana
Once Prometheus and Grafana are started, you can access them directly through the following URLs:
```bash
Prometheus: http://localhost:9090
Grafana: http://localhost:3000
The localhost can be replaced with the IP address obtained by running the hostname -I command.
```

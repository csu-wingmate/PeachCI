#!/bin/bash

# Prometheus 安装步骤
wget https://github.com/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz
tar -zxvf prometheus-2.49.1.linux-amd64.tar.gz
mv prometheus-2.49.1.linux-amd64 prometheus
cd prometheus/
mkdir bin conf data
mv prometheus bin/
mv prometheus.yml conf/

useradd -r -s /sbin/nologin prometheus
chown -R prometheus.prometheus $CIPATH/scripts/analysis/prometheus

# 设置环境变量
echo 'export PROMETHEUS_HOME=$CIPATH/scripts/analysis/prometheus' >> /etc/profile.d/prometheus.sh
echo 'export PATH=${PROMETHEUS_HOME}/bin:$PATH' >> /etc/profile.d/prometheus.sh
source /etc/profile.d/prometheus.sh


# 创建并启动 Prometheus 服务
cat > /lib/systemd/system/prometheus.service <<EOF
[Unit]
Description=prometheus
Documentation=prometheus
After=network.target

[Service]
User=root
WorkingDirectory=$CIPATH/scripts/analysis/prometheus
ExecStart=$CIPATH/scripts/analysis/prometheus/bin/prometheus --config.file=$CIPATH/scripts/analysis/prometheus/conf/prometheus.yml
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Grafana 安装步骤
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

# 使用 Snap 安装 Grafana
snap install grafana


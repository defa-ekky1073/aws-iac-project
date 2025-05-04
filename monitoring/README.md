# Monitoring Stack Documentation

This directory contains configuration for the monitoring stack consisting of Prometheus and Grafana.

## Overview

The monitoring stack is deployed automatically as part of the infrastructure using Ansible. It consists of:

1. **Prometheus** - For metrics collection and storage
2. **Node Exporter** - For collecting system metrics from the EC2 instance
3. **Grafana** - For visualization and dashboarding

## Access Information

After deploying the infrastructure, you can access the monitoring tools:

- **Prometheus**: `http://<EC2_PUBLIC_IP>:9090`
- **Grafana**: `http://<EC2_PUBLIC_IP>:3000` (default credentials: admin/admin)

## Metrics Collected

- CPU usage
- Memory usage
- Disk I/O
- Network traffic
- System load
- Process information

## Adding Custom Metrics

### For Application Metrics:

1. Install a Prometheus client library for your application language.
2. Expose metrics on a `/metrics` endpoint.
3. Add the endpoint to Prometheus configuration in `ansible/roles/prometheus/templates/prometheus.yml.j2`.

### For Custom Dashboards:

1. Create the dashboard in Grafana UI
2. Export it as JSON
3. Add it to `ansible/roles/grafana/templates/` with a `.j2` extension
4. Update the Grafana role to include the new dashboard

## Alerting

To enable alerting:

1. Set up AlertManager (configuration templates available in `monitoring/prometheus/alertmanager`)
2. Configure alert rules in Prometheus
3. Configure notification channels in Grafana

## Customization

The monitoring stack can be customized:

- Modify retention periods in Prometheus
- Add more exporters for specialized metrics
- Configure advanced visualization in Grafana
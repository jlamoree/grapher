## Introduction

The Grapher project uses Raspberry Pi 4 SBCs installed at sites with flaky internet service. They run Promethus server locally and have two exporters gathering metrics on the network performance:

- [Smokeping Prober](https://github.com/SuperQ/smokeping_prober) runs every few seconds to ping Google and Cloudflare (the targets are configurable, of course). The metrics are available to Prometheus at `localhost:9374/metrics`
- [Speedtest](https://github.com/jeanralphaviles/prometheus_speedtest) runs on demand to perform a Speedtest assessment and report up/down/ping stats. The test is executed every few minutes using `localhost:9516/probe`

A publicly accessible server acts in a primary role and gathers the Prometheus timeseries data via federation from each of the sites for visualization in Grafana.

A single Grafana user is created using credentials in global vars (the password is stored in the Ansible vault).

The Prometheus and Grafana web interfaces are exposed from the VM, so care should be taken to apply the appropriate upstream network/firewall rules.

## Ansible Playbooks

See the Ansible Inventory for the logical hostnames defined and the mapped `ansible_host` values. For reference, you may wish to use the following SSH `config` template:

```text
Host grapher-primary
Hostname 142.250.217.142
User root
IdentityFile ~/.ssh/admin

Host grapher-site-node-01
Hostname 192.168.1.108
User pi
IdentityFile ~/.ssh/pi
```

### Grapher Primary

The primary Prometheus server is configured to allow all the site nodes to reverse SSH and expose their Prometheus data from behind whatever NAT is in place. The Ansible Playbook is `grapher-primary.yaml` and draws in host variables from `host_vars/grapher/vars`. The primary host could be Rocky 8 or Ubuntu 22.04 LTS, either of which use Podman as their container manager.

### Grapher Site Nodes

Each of the site nodes is declared in the inventory and placed into the `site_nodes` Ansible group. The `grapher-site-node.yaml` Ansible Playbook configures the Raspberry Pi 4 while it is directly accessible.

# k3s

## Table of Content
* [very quick start](#very-quick-start)
* [quick start](#quick-start)
  * [multipass installation](#multipass-installation)
  * [multipass visualization](#multipass-visualization)
  * [k3s clustering](#k3s-clustering)
  * [verify](#verify)
  * [resources](#resources)

## very quick start

```bash
brew cask reinstall multipass
curl https://raw.githubusercontent.com/superseb/multipass-k3s/master/multipass-k3s.sh | bash
```

## quick start

### multipass installation

```bash
brew cask reinstall multipass
```

### multipass visualization

```bash
# multipass launch --name k3s-master --cpus 1 --mem 512M --disk 3G
# multipass launch --name k3s-worker1 --cpus 1 --mem 512M --disk 3G
# multipass launch --name k3s-worker2 --cpus 1 --mem 512M --disk 3G
for i in master worker1 worker2 ; do
  multipass launch --name k3s-${i} --cpus 1 --mem 512M --disk 3G ;
done
# ... Send usage data (yes/no/Later)? n
```

### k3s clustering

```bash
# Deploy k3s on the master node
multipass exec k3s-master -- /bin/bash -c "curl -sfL https://get.k3s.io | sh -"

# Get the IP of the master node
K3S_NODEIP_MASTER="https://$(multipass info k3s-master | grep "IPv4" | awk -F' ' '{print $2}'):6443"

# Get the TOKEN from the master node
K3S_TOKEN="$(multipass exec k3s-master -- /bin/bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")"

# Deploy k3s on the worker node
multipass exec k3s-worker1 -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=${K3S_NODEIP_MASTER} sh -"

# Deploy k3s on the worker node
multipass exec k3s-worker2 -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=${K3S_NODEIP_MASTER} sh -"
```

### verify

```bash
multipass list
# Name         State    IPv4          Image
# k3s-worker2  Running  192.168.64.4  Ubuntu 18.04 LTS
# k3s-worker1  Running  192.168.64.3  Ubuntu 18.04 LTS
# k3s-master   Running  192.168.64.2  Ubuntu 18.04 LTS

multipass exec k3s-master kubectl get nodes

```

### resources

for details read [this](https://medium.com/@mattiaperi/kubernetes-cluster-with-k3s-and-multipass-7532361affa3) article!

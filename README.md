# GKE-dnscrypt-server
Google Kubernetes Engine scripts for dnscrypt-server-docker

## Google Kubernetes Engine scripts for dnscrypt-server-docker
### Other projects
[dnscrypt/dnscrypt-server-docker](https://github.com/dnscrypt/dnscrypt-server-docker) Upstream Project
[ianbashford/dnscrypt-server-docker](https://github.com/ianbashford/dnscrypt-server-docker) K8S tweaks to upstream...
[eanu/dnscrypt-server-docker](https://hub.docker.com/r/eanu/dnscrypt-server-docker/tags) docker hub tagged images

### Objectives
Setup a scalable GKE K8S Cluster.
encrypted-dns and unbound don't consume many resources, but it can be useful to scale the K8S cluster beyond one pod for deploying new releases.

### Solution Overview
GKE's basic persistent volume only supports ReadWriteOnce and ReadOnlyMany claims, which won't allow the cluster to scale (only one pod can use the PersistentVolumeClaim at one time) or function (encrypted-dns writes it state to the disk).
Using Google's FileStore would allow a ReadWriteMany claim, but the minimum size is 1TB, which is costly (and unnecessary).
The solution creates an nfs service with a small (1Gi) disk, and exposes that to the dnscrypt-server service - K8S can make a ReadWriteMany claim on the NFS mount, allowing the cluster to scale.
[A couple of small tweaks are made to the upstream [dnscrypt/dnscrypt-server-docker](https://github.com/dnscrypt/dnscrypt-server-docker) to allow it to work outside of a single docker deployment.]


### Before you start you need...
a GKE account (billing needs to be setup)
the gcloud sdk setup, and the kubectl component installed
To monitor easily, logon to the GKE console to watch the setup go through...


### How to
Each yaml script is run using ```kubectl apply -f <filename>```
First, create the cluster and setup kubectl with using
1createcluster.sh
Start with the nfs-server scripts
1nfsstorage.yml  creates the regular 1Gi storage
2nfsdeploy.yml deploys the nfs server
3nfsservice.yml will deploy the nfs service (internally to the cluster)
4claimonnfs.yml creates the ReadWriteMany claim that the dns cluster will use

Then, the scripts in dnscrypt-cluster
3exposeudp.yml will create the udp service and allocate an external ip which you can retrieve using
4getip.sh 
5exposetcp.yml should be modified to use the external ip address
6dnscrypt-init.yml should be modified to use the external ip address
7deploy.yml will properly deploy the pods behind the service

It should all be working now....

### Testing
Go to the logs for either the dnscrypt-init, or dnscrypt workloads -- the sdns stamp will be in the logs.  Put this into a static config in your dnscrypt-proxy.toml file, and test the service.
The workload is deployed with only one pod - you can scale it up to more.

If all is good, make the IP address static rather than ephemeral.


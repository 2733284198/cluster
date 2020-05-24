# Welcome to use

> Note: This version corresponds to v1.0.3 of vagrant box, Problems found during use, welcome issues

[中文](https://github.com/CoderMrPu/cluster/blob/master/README-ZH_CN.MD)

### Clone the project

```shell
git clone https://github.com/CoderMrPu/cluster.git
```

### Enter the project

```shell
cd cluster
```

### Initialization

```shell
# Windows
./init.bat

# Linux
./init.sh
```

### Configure the cluster.yaml file

> configure according to your needs

- type (Set the virtual machine type, nginx or apache or database, nginx must be used together with apache, apache and database can be used separately, apache contains php, database contains MySQL and Redis)
- name (Set the name of the virtual machine, can not be renamed)
- cpus (Set the number of virtual machine CPU)
- memory (Set the amount of virtual machine memory)
- networks (Set up a virtual machine network)
  - type (Network type: general default)
  - ip (Network ip: Configure according to your virtual machine, there must be no conflict)
- ports (Set up virtual machine port forwarding)
  - send (Virtual machine port)
  - to (Local port)
- proxys (Set up nginx proxy)
  - map (visit domain)
  - site(proxy site)
    - send (proxy domain name)
    - to (proxy ip,unique value required)
- folders (Set up folder sharing)
  - map (Local folder path)
  - to (The path of the virtual machine)
- sites (Set up the apache site)
  - map (Domain name)
  - to (Site path)
- databases （set up the database）
  - cluster （create a <cluster> database）

### start vagrant

```shell
vagrant up
```

### Set up the hosts file

```
192.168.10.20 www.cluster.com
192.168.10.21 www.domain1.com
192.168.10.22 www.domain2.com
```

### account information

- Linux (root:vagrant;vagrant:vagrant)
- MySQL (root:password;cluster:password)
- Redis (root:"")

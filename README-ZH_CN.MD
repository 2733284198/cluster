# 欢迎使用

> 注意：此版本对应 vagrant box 的 v1.0.3，使用中发现问题欢迎issues

### 克隆项目

```shell
git clone https://github.com/CoderMrPu/cluster.git
```

### 进入项目

```shell
cd cluster
```

### 初始化

```shell
# Windows
./init.bat

# Linux
./init.sh
```

### 配置Cluster.yaml文件

> 根据自己的需求来配置

- type （设置虚拟机类型，nginx或者apache或者database，nginx必须配合apache一起使用，apache和database可以单独使用，apache包含php，database包含MySQL和Redis）
- name （设置虚拟机的名称，不能重名）
- cpus （设置虚拟机cpu数）
- memory （设置虚拟机内存量）
- networks （设置虚拟机网络）
  - type （网络类型：一般默认）
  - ip （网络ip：根据自己虚拟机来配置，不能有冲突）
- ports （设置虚拟机端口转发）
  - send （虚拟机的端口）
  - to （本地端口）
- proxys （设置nginx代理）
  - map （访问域名）
  - site（代理站点）
    - send （代理域名）
    - to （代理ip，要求唯一值）
- folders （设置文件夹共享）
  - map （本地文件夹路径）
  - to （虚拟机的路径）
- sites （设置apache站点）
  - map （站点域名）
  - to （站点路径）
- databases （设置数据库）
  - cluster （创建《cluster》数据库）

### 启动vagrant

```shell
vagrant up
```

### 设置hosts文件

```
192.168.10.20 www.cluster.com
192.168.10.21 www.domain1.com
192.168.10.22 www.domain2.com
```

### 账户信息

- Linux （root：vagrant；vagrant：vagrant）
- MySQL （root：password；cluster：password）
- Redis （root：“”）


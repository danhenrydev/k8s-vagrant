<a name="readme-top"></a>
# K8S-VAGRANT

A configurable, flexible, and consistent local Kubernetes cluster (or clusters) with support for most things that you would expect in a cluster such as `LoadBalancer` and persistent storage out of the box.

<!-- ABOUT THE PROJECT -->
## About The Project

This uses [Vagrant](https://www.vagrantup.com/) and [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) to spin up a local Kuberentes cluster.  It then installs [metallb](https://metallb.universe.tf/) for a local LoadBalancer and [Longhorn](https://longhorn.io) for persistent volumes.  It exposes several of the more common things one might like to configure through the `settings.yaml` file such as Kubernetes version and the configuration of the virtual machines.

### KISS

This project is meant to follow the **K**eep **I**t **S**imple **S**tupid philosophy.  I want the project to be organized in a way and function in a way that it's dead easy for people to use and modify it in a way that works best for them.

**Why did I make this**:
* I needed a local Kubernetes cluster running on Virtual Machines instead of within containers because I needed `open-iscsi` and mount propagation which doesn't work properly within containers
* I wanted something simple that I understood instead of having to learn another tool exclusively for local development, and then figure out how to translate that to my homelab cluster.  Using Vagrant it's simply Virtual Machines.

**What about Minikube, KiND, etc.**

They're great, and may be the right fit for your needs.  I have used them and they work great, they just weren't what I was looking for.  Also, as mentioned earlier, I didn't want to learn another tool.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



## Built With

[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The whole point of the project is to spin up a Kubernetes cluster.

[![Vagrant](https://img.shields.io/badge/vagrant-%231563FF.svg?style=for-the-badge&logo=vagrant&logoColor=white)](https://www.vagrantup.com/)
<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Used to provision the virtual machines using [VirtualBox](https://www.virtualbox.org/)

[![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Makes heavy use of bash to provision the Virtual Machines after they are created.

### Cluster Specifics

The cluster is built using `kubeadm`, using containerd as a CRI, and Calico for pod networking.  It then adds the following additional software if configured to do so.

[metallb](https://metallb.universe.tf/)
<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Metallb is optionally installed to provide a local load balancer into the cluster. 

[Longhorn](https://longhorn.io)
<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Longhorn is optionally installed to provide persistent volumes with support for ReadWriteMany.

### Cluster Specifics

The cluster is built using `kubeadm`, using containerd as a CRI, and Calico for pod networking.
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

This project requires only that you have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed on your machine, and have enough resources available to run your configured number of machines with the amount of allocated resources.

With the default configuration it builds **1 master node and 1 worker** node each with **2Gb of RAM** and **2 cores** which is the suggested minimum from the Kubernetes project.

#### Software

Install [VirtualBox](https://www.virtualbox.org/) from their website, Chocolatey on Windows, from your package manager on Linux, or with Brew on Mac.

**Windows**
```
choco install virtualbox
```

**Linux (debian/ubuntu)**
```
apt install virtualbox
```

**Mac**
```
brew install virtualbox
```

Install [Vagrant](https://www.vagrantup.com/) using Chocolatey on Windows, from your package manager on Linux, or with Brew on Mac.

**Windows**
```powershell
choco install vagrant
```

**Linux (Debian/Ubuntu)**
```bash
apt install vagrant
```

**Mac**
```bash
brew install vagrant
```

### Building your local cluster.

1. Clone the repo
   ```bash
   git clone https://github.com/danhenrydev/k8s-vagrant.git
   ```
2. Modify the configuration file at `cluster-settings.yaml` to your liking.  It comes with sane defaults.
  
3. Change into the directory and run `vagrant up`
   ```bash
   cd k8s-vagrant
   vagrant up
   ```
4. Copy the kubectl config from `generated/config` into your local `.kube` or set the environment variable to access the cluster from your local machine.
   ```bash
   mkdir ~/.kube
   cp generated/config ~/.kube/config
   kubectl get nodes

   ### OR ###

   KUBECONFIG=generated/config
   kubectl get nodes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- ROADMAP -->
## Future Changes

Although the project seems to be working well for me as is, there are some things that I would like to add in the future that I haven't gotten around to yet.

- [ ] Add a Traefik Ingress option
- [ ] Add support for VmWare Workstation
- [ ] Add support for QEMU
- [ ] Pretty up the bash scripts and output

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

If you have a suggestion, please reach out to me via Twitter and I'll see what I can do to get it added.

If you run into a problem or bug and it's not something you can fix, please feel free to create an issue on Github and I will see what I can do to get it fixed.

If you run into a problem or have an idea, and it IS something you can fix, please create a PR.  When doing so, please keep in mind the KISS principle as mentioned in the About this Project section.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the GPLv2 License. See `LICENSE.md` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Daniel Henry - [@danhenrydev](https://twitter.com/danhenrydev)

Project Link: [https://github.com/danhenrydev/k8s-vagrant](https://github.com/danhenrydev/k8s-vagrant)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Obviously I'm not the first to make something like this, so thank you to everyone that has solved some of these problems in the past.  Some specific projects that helped me a lot below.

* [https://github.com/techiescamp/vagrant-kubeadm-kubernetes](https://github.com/techiescamp/vagrant-kubeadm-kubernetes)

* [https://github.com/justmeandopensource](https://github.com/justmeandopensource)



<p align="right">(<a href="#readme-top">back to top</a>)</p>
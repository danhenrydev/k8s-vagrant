require "yaml"
s = YAML.load_file "cluster-settings.yaml"

# prepare networking information 
# Split the IP address into octets
octets = s["cluster"]["networking"]["startingIP"].split('.')

# Extract the first three octets with a dot separator
network = octets[0..2].join('.') + "."
network_ip = octets[3]

Vagrant.configure("2") do |config|

  config.vm.boot_timeout = s["cluster"]["bootTimeout"]

  # Define the master node
  config.vm.define "master" do |master|
    master.vm.box = s["cluster"]["box"]
    master.vm.hostname = s["cluster"]["name"] + "-master"
    master.vm.network "private_network", type: "static", ip: network + network_ip
    master.vm.base_mac = nil
    master.vm.provider "virtualbox" do |vb|
      vb.cpus = s["cluster"]["master"]["cores"]
      vb.memory = s["cluster"]["master"]["memory"]
      vb.customize ["modifyvm", :id, "--name", "master"]

      # Set the group in virtualbox
      if s["cluster"]["name"] and s["cluster"]["name"] != ""
        vb.customize ["modifyvm", :id, "--groups", ("/" + s["cluster"]["name"])]
      end
    end

    #
    #  Run the init provision script
    #
    master.vm.provision "shell",
      path: "provision/init.sh",
      # Arguments: DNS Servers, k8s version
      args:  [s["cluster"]["networking"]["dns"].join(" "), s["cluster"]["kubernetes"]["version"]]

    #
    #  Run the master provisioning script
    #
    master.vm.provision "shell",
      path: "provision/master.sh",
      # Arguments: Master IP, pod network, service network, calico version
      args:  [s["cluster"]["networking"]["startingIP"], s["cluster"]["networking"]["pod_network"], s["cluster"]["networking"]["service_network"], s["cluster"]["kubernetes"]["calicoVersion"]]
  end

  # Define worker nodes
  s["cluster"]["worker"]["count"].times do |i|
    config.vm.define sprintf("worker-%02d", i + 1) do |worker|
      worker.vm.box = s["cluster"]["box"]
      worker.vm.hostname = s["cluster"]["name"] + "-" + sprintf("worker-%02d", i + 1)
      worker.vm.base_mac = nil
      worker.vm.network "private_network", type: "static", ip: "#{network}#{sprintf('%02d', i + network_ip.to_i + 1)}"
      worker.vm.provider "virtualbox" do |vb|
        vb.cpus = s["cluster"]["worker"]["cores"]
        vb.memory = s["cluster"]["worker"]["memory"]
        vb.customize ["modifyvm", :id, "--name", sprintf("worker-%02d", i + 1)]

          # Set the group in virtualbox
          if s["cluster"]["name"] and s["cluster"]["name"] != ""
            vb.customize ["modifyvm", :id, "--groups", ("/" + s["cluster"]["name"])]
            vb.customize ["modifyvm", :id, "--name", s["cluster"]["name"] + "-" + sprintf("worker-%02d", i + 1)]
          end
        end

      #
      #  Run the init provision script
      #
      worker.vm.provision "shell",
        path: "provision/init.sh",
        # Arguments: DNS Servers, k8s version
        args:  [s["cluster"]["networking"]["dns"].join(" "), s["cluster"]["kubernetes"]["version"]]

      #
      #  Run the worker provisions script
      #
      worker.vm.provision "shell",
        path: "provision/worker.sh"
        # Arguments: ip address

      # Install metallb
      if i == (s["cluster"]["worker"]["count"] - 1) and s["cluster"]["software"]["metallb"]["install"] and s["cluster"]["software"]["metallb"]["install"] != ""
        worker.vm.provision "shell", path: "provision/metallb.sh", args: s["cluster"]["software"]["metallb"]["ipRange"]
      end

      #Install Longhorn
      if i == (s["cluster"]["worker"]["count"] - 1) and s["cluster"]["software"]["longhorn"]["install"] and s["cluster"]["software"]["longhorn"]["install"] != ""
        worker.vm.provision "shell", path: "provision/longhorn.sh",
        args: s["cluster"]["software"]["longhorn"]["frontend-lb"]
      end
    end
  end
end
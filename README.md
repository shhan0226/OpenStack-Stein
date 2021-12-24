# OpenStack-Stein
Installation Script for OpenStack Stein based on ARM Server (ubuntu18.04)


</br>
 
## OpenStack installer

ARM CPU Server-based Stein version manual installation method is written on [Wiki](https://github.com/shhan0226/Project-OpenStack/wiki).

Here, a shell script is written based on the contents of the [Wiki](https://github.com/shhan0226/Project-OpenStack/wiki), and the execution order of the shell script is as follows.

### Step.1 Prerequisites
- It runs on the Controller Node.
  ```
  # ./init.sh
  ```

- It runs on the Controller Node.
  ```
  # ./init.sh
  ```

### Step.2 Keystone
- It runs on the Controller Node.
  ```
  # ./keystone.sh
  ```

### Step.3 Glance
- It runs on the Controller Node.
  ```
  # ./glance.sh
  ```

### Step.4 Placement
- It runs on the Controller Node.
  ```
  # ./placement.sh
  ```

### Step.5 Nova
- It runs on the Controller Node.
  ```
  # ./nova-controller.sh
  ```

- It runs on the compute Node.
  ```
  # ./nova-compute.sh
  ```

- It runs on the Controller Node.
  ```
  # ./nova-check-to-compute.sh
  ```

### Step.6 Neutron
- It runs on the Controller Node.
  ```
  # ./neutron-controller.sh
  ```

- It runs on the compute Node.
  ```
  # ./neutron-compute.sh
  ```

### Setp.7 Horizon
- It runs on the Controller Node.
  ```
  # ./horizon.sh
  ```


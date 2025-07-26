

# ESP Bastion

This repository is a minimal example for the paper:

> *A Framework for Secure Third-Party IP Integration in NoC-based SoC Platforms*


This project is built on top of the [ESP platform](https://www.esp.cs.columbia.edu). For ESP usage and background, please check the [ESP documentation and tutorials](https://esp.cs.columbia.edu/docs/).

The example is based on [this commit](https://github.com/sld-columbia/esp/tree/607b249f06fb257c50e6f4e2e9d8a447f92eb1ee) of the [ESP project](https://github.com/sld-columbia/esp). 


## Tools
* Docker
* Modelsim 2019.4 
* Vivado 2019.2
* Stratus HLS

Using other versions of Questa / Vivado might require modifying the Makefiles.

## Steps

### 1. Configure EDA Tools and Start the Docker

* Edit `./scripts/esp_env_cad.sh` to specify the paths to Vivado, Stratus HLS, and ModelSim/Questa.

* Download the Docker image and launch it with local volumes, including the EDA tools and this repository:

```bash
docker run -it --security-opt label=type:container_runtime_t --network=host -e DISPLAY=$DISPLAY -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v "/opt:/opt" -v "./ESP-Bastion:/home/espuser/esp" davidegiri/esp-tutorial:asplos2021 /bin/bash
```
* Inside the Docker container, configure the enviroment variables:
```bash
source esp/scripts/esp_env_cad.sh
```

### 2. Generate HLS Accelerator
* This example uses the dummy-stratus accelerator. Users are required to generate the RTL and memory map of the accelrator using Stratus HLS. The HLS source code is under `acceleratos/stratus_hls/dummy_stratus`. 
* Check [here](https://esp.cs.columbia.edu/docs/systemc_acc/) for a tutorial on how to generate an accelerator using Cadence Stratus HLS.

* Place the generated accelerator RTL and memory map under
```bash
tech/virtex7/acc
tech/virtex7/memgen
```

### 3. Configure SoC architecture
* Enter directory 
```bash
socs/xilinx-vc707-xc7vx485t
``` 
* Launch the SoC configuration GUI
```bash
make esp-xconfig
``` 
* Design a minimal SoC with CPU, memory, I/O, and accelerator tiles. Make sure to select the Ariane core and Dummy Stratus accelerator.
![Diagram](readme_pics/configure.png)

* Click on the "Generate SoC Config" before closing the window.

### 3. Enable/Disable Security Features
* Enable or disable security features by checking or unchecking the "Enable security features" box in the SoC configuration GUI (previous step).

* Edit line 29 (SECURITY_ON) in `accelerators/stratus_hls/dummy_stratus/sw/baremetal/dummy.c` to match the security configuration. This ensures the firmware verifies the expected security behavior.

### 4. Run Simulation
* Enter directory `socs/xilinx-vc707-xc7vx485t`, to run simulation with ModelSim GUI, 
```bash
source dummy_stratus_sim.sh
```
* Once inside Modelsim, execute
```bash
source path/to/scripts/sim_op.tcl
```
* This will run the RTL simulation and display waveforms of security-related signals.
![Diagram](readme_pics/waveform.png)
* Alternatively, to launch ModelSim without GUI, 
```bash
source cmddummy_stratus_sim.sh
```



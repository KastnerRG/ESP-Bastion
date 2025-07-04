

![Open-ESP](esp-logo-small.png)

This repository is a minimal example for the paper:

> *A Framework for Secure Third-Party IP Integration in NoC-based SoC Platforms*

It is built on top of the [ESP platform](https://www.esp.cs.columbia.edu). For ESP usage and background, see the [ESP documentation and tutorials](https://esp.cs.columbia.edu/docs/).

This example is based on [this specific commit](https://github.com/sld-columbia/esp/tree/607b249f06fb257c50e6f4e2e9d8a447f92eb1ee) of the [ESP project](https://github.com/sld-columbia/esp). 


## Enviroment
* Docker
* Modelsim 2019.4 
* Vivado 2019.2
* Stratus HLS

Using other versions of Questa / Vivado might require modifying the Makefiles.

## Steps
Please follow 

### 1. Configure EDA Tools and Start the Docker

Edit `./scripts/esp_env_cad.sh` to specify the paths to Vivado, Stratus HLS, and ModelSim/Questa.

Download the Docker image and launch it with local volumes, including the EDA tools and this repository:

```bash
docker run -it --security-opt label=type:container_runtime_t --network=host -e DISPLAY=$DISPLAY -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v "/opt:/opt" -v "./ESP-Bastion:/home/espuser/esp" davidegiri/esp-tutorial:asplos2021 /bin/bash
```
Inside the Docker container, configure the EDA tool environment:
```bash
source esp/scripts/esp_env_cad.sh
```

### 2. Generate HLS Accelerator and SoC

* Generate the dummy accelerator RTL and memory map, and place them in
```bash
tech/virtex7/acc
tech/virtex7/memgen
```

* Enter directory 
```bash
socs/xilinx-vc707-xc7vx485t
``` 
* Launch the SoC configuration GUI
```bash
make esp-xconfig
``` 
In the GUI, design a minimal SoC with CPU, memory, I/O, and accelerator tiles. Make sure to select the Ariane core and Dummy Stratus accelerator.
![Diagram](readme_pics/configure.png)

Make sure to click on the "Generate SoC Config" before closing the window.

### 3. Enable/Disable Security Features
In the SoC configuration GUI, enable or disable security features by checking or unchecking the "Enable security features" box.

Also edit line 29 (SECURITY_ON) in:
```bash
accelerators/stratus_hls/dummy_stratus/sw/baremetal/dummy.c
```
to match the security configuration. This ensures the firmware verifies the expected security behavior.

### 4. Run Simulation
Enter directory `socs/xilinx-vc707-xc7vx485t`, to run simulation with ModelSim GUI, 
```
source dummy_stratus_sim.sh
```
Inside Modelsim, execute
```
source path/to/scripts/sim_op.tcl
```
This will run the RTL simulation and display waveforms of security-related signals.
![Diagram](readme_pics/waveform.png)


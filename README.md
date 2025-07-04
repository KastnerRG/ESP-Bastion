

![Open-ESP](esp-logo-small.png)

This repo is the open-source release of the paper "A Framework for Secure Third-Party IP Integration in NoC-based SoC Platforms" based on the [ESP platform](https://www.esp.cs.columbia.edu). [Here](https://esp.cs.columbia.edu/docs/) is a list of ESP tutorials.

This exmple is based on [this commit](https://github.com/sld-columbia/esp/tree/607b249f06fb257c50e6f4e2e9d8a447f92eb1ee) of the [ESP project](https://github.com/sld-columbia/esp). 

## Enviroment
* Docker
* Modelsim 2019.4 
* Vivado 2019.2
* Stratus HLS

Using other versions of Questa / Vivado might require modifying the Makefiles.

## Steps
Please follow 

### Configure EDA tools and start the docker
`./scripts/esp_env_cad.sh` specifies the paths of EDA tools. Configure the paths to Vivado, Stratus HLS, and Modelsim/Questa.

Download the docker image and launch the local volumns, including the EDA tools and this repo.
```
docker run -it --security-opt label=type:container_runtime_t --network=host -e DISPLAY=$DISPLAY -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v "/opt:/opt" -v "./ESP-Bastion:/home/espuser/esp" davidegiri/esp-tutorial:asplos2021 /bin/bash
```
Upon docker startup, configure the path to EDA tools
```
source esp/scripts/esp_env_cad.sh
```

### Generate HLS Accelerator and SoC

Generate dummy accelerator RTL and memory map, put them under `tech/virtex7/acc` and `tech/virtex7/memgen`.

Enter directory `socs/xilinx-vc707-xc7vx485t`, use command `make esp-xconfig` to design a minimal SoC with CPU, memory, I/O and accelerator tiles. Ariane core and dummyStratus should be selected.
![Diagram](readme_pics/configure.png)

Make sure to click on the "Generate SoC Config" before closing the window.

### Enable/disable security features
In the SoC configuration GUI, you can enable/disable security features by checking/unchecking the "Enable security features" box.

Also the check line 29 `SECURITY_ON` of file `accelerators/stratus_hls/dummy_stratus/sw/baremetal/dummy.c` to reflect the coresponding security configuraitons so that the firmawre can check with expetec output.

### Run simulation
Enter directory `socs/xilinx-vc707-xc7vx485t`, to run simulation with ModelSim GUI, 
```
source dummy_stratus_sim.sh
```
Inside Modelsim, run
```
source path/to/scripts/sim_op.tcl
```
This will run the RTL simulation, and display the waveforms of security-related signals.
![Diagram](readme_pics/waveform.png)


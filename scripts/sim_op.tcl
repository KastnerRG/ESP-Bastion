add wave -position insertpoint  \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/clk 

add wave -position insertpoint -group io_send_security_cfg \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/SECURITY_ON_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/RD_RANGE_SIZE_2_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/RD_RANGE_SIZE_1_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/RD_BASE_ADDR_2_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/RD_BASE_ADDR_1_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/WR_RANGE_SIZE_2_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/WR_RANGE_SIZE_1_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/WR_BASE_ADDR_2_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/WR_BASE_ADDR_1_CFG \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/init_done \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_wrreq \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_full \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_flit \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_done \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_data_in \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_cfg_next \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/security_cfg_current

add wave -position insertpoint -group security_cfg_for_acc \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/misc_tile_q_1/security_rdreq \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/misc_tile_q_1/security_empty \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/misc_tile_q_1/security_data_out \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/misc_tile_q_1/noc5_in_void \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/misc_tile_q_1/noc5_in_stop \
sim:/testbench/top_1/esp_1/tiles_gen(3)/io_tile/tile_io_i/misc_tile_q_1/noc5_in_data \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc5_out_data \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc5_out_void \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc5_out_stop \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc5_fifos_next \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc5_fifos_current \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/SECURITY_ON \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/RD_BASE_ADDR_1 \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/RD_RANGE_SIZE_1  \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/RD_BASE_ADDR_2 \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/RD_RANGE_SIZE_2  \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/WR_BASE_ADDR_1 \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/WR_RANGE_SIZE_1  \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/WR_BASE_ADDR_2 \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/WR_RANGE_SIZE_2  


add wave -position insertpoint -group stratus_dma \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/conf_done \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_ctrl_valid \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_ctrl_data_index \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_ctrl_data_length \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_ctrl_data_size \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_chnl_valid \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_chnl_data \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_read_chnl_ready \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_ctrl_valid \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_ctrl_data_index \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_ctrl_data_length \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_ctrl_data_size \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_chnl_valid \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_chnl_data \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/dma_write_chnl_ready \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/dummy_stratus_rlt_i/acc_done


add wave -position insertpoint  -group axi2noc\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_state \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_next \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_rcv_rdreq \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_rcv_data_out \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_rcv_empty \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_snd_wrreq \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_snd_data_in \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/dummy_stratus_gen/noc_dummy_stratus_i/esp_acc_dma_1/dma_snd_full 



add wave -position insertpoint  -group from_queue\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_snd_wrreq \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_snd_full \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_snd_data_in

add wave -position insertpoint  -group acw\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_snd_rdreq \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_snd_data_out\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/request_ERROR_illegal \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/request_ERROR_illegal_chk \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/aker_current \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/aker_next\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/holded_dma_snd_addr \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/holded_dma_snd_header \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/holded_dma_snd_len\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/max_rd_len \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/max_rd_len_chk \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/max_rd_len \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/max_rd_len_chk \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/rd_len_tofake \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/rd_len_tofake_chk \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/faked_reply_header \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/faked_reply_data_body \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/faked_reply_data_tail

add wave -position insertpoint  -group snd2_noc6\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc6_in_stop \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc6_in_data \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc6_in_void

add wave -position insertpoint  -group rcvfrom_noc4\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc4_out_data \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc4_out_void \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/noc4_out_stop

add wave -position insertpoint  -group to_queue\
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_rcv_data_out \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_rcv_empty \
sim:/testbench/top_1/esp_1/tiles_gen(2)/accelerator_tile/tile_acc_i/acc_tile_q_1/dma_rcv_rdreq

run -a
wave zoom full

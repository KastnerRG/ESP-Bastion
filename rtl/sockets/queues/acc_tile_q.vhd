-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.tile.all;

use work.esp_global.all;

entity acc_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                        : in  std_ulogic;
    clk                        : in  std_ulogic;
    -- tile->NoC1
    coherence_req_wrreq        : in  std_ulogic;
    coherence_req_data_in      : in  noc_flit_type;
    coherence_req_full         : out std_ulogic;
    -- NoC2->tile
    coherence_fwd_rdreq        : in  std_ulogic;
    coherence_fwd_data_out     : out noc_flit_type;
    coherence_fwd_empty        : out std_ulogic;
    -- Noc3->tile
    coherence_rsp_rcv_rdreq    : in  std_ulogic;
    coherence_rsp_rcv_data_out : out noc_flit_type;
    coherence_rsp_rcv_empty    : out std_ulogic;
    -- tile->Noc3
    coherence_rsp_snd_wrreq    : in  std_ulogic;
    coherence_rsp_snd_data_in  : in  noc_flit_type;
    coherence_rsp_snd_full     : out std_ulogic;
    -- NoC4->tile
    dma_rcv_rdreq              : in  std_ulogic;
    dma_rcv_data_out           : out noc_flit_type;
    dma_rcv_empty              : out std_ulogic;
    -- tile->NoC4
    coherent_dma_snd_wrreq     : in  std_ulogic;
    coherent_dma_snd_data_in   : in  noc_flit_type;
    coherent_dma_snd_full      : out std_ulogic;
    -- tile->NoC6
    dma_snd_wrreq              : in  std_ulogic;
    dma_snd_data_in            : in  noc_flit_type;
    dma_snd_full               : out std_ulogic;
    -- NoC6->tile
    coherent_dma_rcv_rdreq     : in  std_ulogic;
    coherent_dma_rcv_data_out  : out noc_flit_type;
    coherent_dma_rcv_empty     : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq              : in  std_ulogic;
    apb_rcv_data_out           : out misc_noc_flit_type;
    apb_rcv_empty              : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq              : in  std_ulogic;
    apb_snd_data_in            : in  misc_noc_flit_type;
    apb_snd_full               : out std_ulogic;
    -- tile->NoC5
    interrupt_wrreq            : in  std_ulogic;
    interrupt_data_in          : in  misc_noc_flit_type;
    interrupt_full             : out std_ulogic;
    -- NoC5->tile
    interrupt_ack_rdreq        : in  std_ulogic;
    interrupt_ack_data_out     : out misc_noc_flit_type;
    interrupt_ack_empty        : out std_ulogic;

    -- Cachable data plane 1 -> request messages
    noc1_out_data : in  noc_flit_type;
    noc1_out_void : in  std_ulogic;
    noc1_out_stop : out std_ulogic;
    noc1_in_data  : out noc_flit_type;
    noc1_in_void  : out std_ulogic;
    noc1_in_stop  : in  std_ulogic;
    -- Cachable data plane 2 -> forwarded messages
    noc2_out_data : in  noc_flit_type;
    noc2_out_void : in  std_ulogic;
    noc2_out_stop : out std_ulogic;
    noc2_in_data  : out noc_flit_type;
    noc2_in_void  : out std_ulogic;
    noc2_in_stop  : in  std_ulogic;
    -- Cachable data plane 3 -> response messages
    noc3_out_data : in  noc_flit_type;
    noc3_out_void : in  std_ulogic;
    noc3_out_stop : out std_ulogic;
    noc3_in_data  : out noc_flit_type;
    noc3_in_void  : out std_ulogic;
    noc3_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 4 -> DMA transfers response
    noc4_out_data : in  noc_flit_type;
    noc4_out_void : in  std_ulogic;
    noc4_out_stop : out std_ulogic;
    noc4_in_data  : out noc_flit_type;
    noc4_in_void  : out std_ulogic;
    noc4_in_stop  : in  std_ulogic;
    -- Configuration plane 5 -> RD/WR registers
    noc5_out_data : in  misc_noc_flit_type;
    noc5_out_void : in  std_ulogic;
    noc5_out_stop : out std_ulogic;
    noc5_in_data  : out misc_noc_flit_type;
    noc5_in_void  : out std_ulogic;
    noc5_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 6 -> DMA transfers requests
    noc6_out_data : in  noc_flit_type;
    noc6_out_void : in  std_ulogic;
    noc6_out_stop : out std_ulogic;
    noc6_in_data  : out noc_flit_type;
    noc6_in_void  : out std_ulogic;
    noc6_in_stop  : in  std_ulogic);

end acc_tile_q;

architecture rtl of acc_tile_q is

  signal fifo_rst : std_ulogic;

  -- These are auxilliary signals!! Not to be confused with i/o!
  -- tile->NoC1
  signal coherence_req_rdreq                 : std_ulogic;
  signal coherence_req_data_out              : noc_flit_type;
  signal coherence_req_empty                 : std_ulogic;
  -- NoC2->tile
  signal coherence_fwd_wrreq             : std_ulogic;
  signal coherence_fwd_data_in           : noc_flit_type;
  signal coherence_fwd_full              : std_ulogic;
  -- NoC3->tile
  signal coherence_rsp_rcv_wrreq            : std_ulogic;
  signal coherence_rsp_rcv_data_in          : noc_flit_type;
  signal coherence_rsp_rcv_full             : std_ulogic;
  -- tile->NoC3
  signal coherence_rsp_snd_rdreq     : std_ulogic;
  signal coherence_rsp_snd_data_out  : noc_flit_type;
  signal coherence_rsp_snd_empty     : std_ulogic;
  -- NoC4->tile
  signal dma_rcv_wrreq                       : std_ulogic;
  signal dma_rcv_data_in                     : noc_flit_type;
  signal dma_rcv_full                        : std_ulogic;

  signal dma_rcv_void_intent                  : std_ulogic;
  signal dma_rcv_data_in_noc                 : noc_flit_type;

  -- tile->NoC4
  signal coherent_dma_snd_rdreq              : std_ulogic;
  signal coherent_dma_snd_data_out           : noc_flit_type;
  signal coherent_dma_snd_empty              : std_ulogic;
  -- tile->NoC6
  signal dma_snd_rdreq                       : std_ulogic;
  signal dma_snd_data_out                    : noc_flit_type;
  signal dma_snd_empty                       : std_ulogic;

  signal noc6_in_data_unsafe                 : noc_flit_type;
  signal noc6_in_void_unsafe                 : std_ulogic;                          

  -- NoC6->tile
  signal coherent_dma_rcv_wrreq              : std_ulogic;
  signal coherent_dma_rcv_data_in            : noc_flit_type;
  signal coherent_dma_rcv_full               : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq                : std_ulogic;
  signal apb_rcv_data_in              : misc_noc_flit_type;
  signal apb_rcv_full                 : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq                : std_ulogic;
  signal apb_snd_data_out             : misc_noc_flit_type;
  signal apb_snd_empty                : std_ulogic;
  -- tile->Noc5
  signal interrupt_rdreq                    : std_ulogic;
  signal interrupt_data_out                 : misc_noc_flit_type;
  signal interrupt_empty                    : std_ulogic;
  -- NoC5->tile
  signal interrupt_ack_wrreq                : std_ulogic;
  signal interrupt_ack_data_in              : misc_noc_flit_type;
  signal interrupt_ack_full                 : std_ulogic;

  type noc2_packet_fsm is (none, packet_inv);
  signal noc2_fifos_current, noc2_fifos_next : noc2_packet_fsm;
  type noc3_packet_fsm is (none, packet_line);
  signal noc3_fifos_current, noc3_fifos_next : noc3_packet_fsm;
  type to_noc3_packet_fsm is (none, packet_coherence_rsp_snd);
  signal to_noc3_fifos_current, to_noc3_fifos_next : to_noc3_packet_fsm;
  type noc5_packet_fsm is (none, packet_apb_rcv,
                          set_rd_addr1, set_rd_range1, set_rd_addr2, set_rd_range2,
                          set_wr_addr1, set_wr_range1, set_wr_addr2, set_wr_range2);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;
  type to_noc5_packet_fsm is (none, packet_apb_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  type aker_fsm is (idle_check_header, check_addr_rd, check_len_rd, 
                    release_header_rd, release_addr_rd, release_len_rd,
                    blocking_rd, faking_header_rd, faking_data_rd, 
                    check_addr_wr, release_header_wr, release_addr_wr,
                    pass_date_wr, blocking_wr);

  signal request_ERROR_illegal         : std_ulogic;
  signal request_ERROR_illegal_chk     : std_ulogic;

  signal aker_current, aker_next       : aker_fsm;
  signal fifo_read_blocked_by_aker     : std_ulogic;
  signal holded_dma_snd_header         : noc_flit_type;  -- shift register
  signal holded_dma_snd_addr           : noc_flit_type;  -- avoid comb loop!
  signal holded_dma_snd_len            : noc_flit_type;

  signal holded_dma_snd_header_chk     : noc_flit_type;
  signal holded_dma_snd_addr_chk       : noc_flit_type;
  signal holded_dma_snd_len_chk        : noc_flit_type;

  signal next_noc6_in_data             : noc_flit_type;
  signal next_noc6_in_void             : std_ulogic;
  
  --constant RD_BASE_ADDR_1           : unsigned(32-1 downto 0) := X"A0200000";
  --constant RD_RANGE_SIZE_1          : unsigned(32-1 downto 0) := X"10000000";
  --constant RD_BASE_ADDR_2           : unsigned(32-1 downto 0) := X"B1200000";
  --constant RD_RANGE_SIZE_2          : unsigned(32-1 downto 0) := X"0FE00000";
  --constant WR_BASE_ADDR_1           : unsigned(32-1 downto 0) := X"A0200000";
  --constant WR_RANGE_SIZE_1          : unsigned(32-1 downto 0) := X"0FE00000";
  --constant WR_BASE_ADDR_2           : unsigned(32-1 downto 0) := X"B1000000";
  --constant WR_RANGE_SIZE_2          : unsigned(32-1 downto 0) := X"10000000";

  signal RD_BASE_ADDR_1             : unsigned(32-1 downto 0)  := CFG_RD_BASE_ADDR_1;
  signal RD_RANGE_SIZE_1            : unsigned(32-1 downto 0)  := CFG_RD_RANGE_SIZE_1;
  signal RD_BASE_ADDR_2             : unsigned(32-1 downto 0)  := CFG_RD_BASE_ADDR_2;
  signal RD_RANGE_SIZE_2            : unsigned(32-1 downto 0)  := CFG_RD_RANGE_SIZE_2;
  signal WR_BASE_ADDR_1             : unsigned(32-1 downto 0)  := CFG_WR_BASE_ADDR_1;
  signal WR_RANGE_SIZE_1            : unsigned(32-1 downto 0)  := CFG_WR_RANGE_SIZE_1;
  signal WR_BASE_ADDR_2             : unsigned(32-1 downto 0)  := CFG_WR_BASE_ADDR_2;
  signal WR_RANGE_SIZE_2            : unsigned(32-1 downto 0)  := CFG_WR_RANGE_SIZE_2;

  signal SECURITY_ON                : std_ulogic       := '1';
  signal SECURITY_ON_chk            : std_ulogic       := '1';

  signal max_rd_len                 : unsigned(32-1 downto 0);
  signal max_rd_len_chk             : unsigned(32-1 downto 0);

  signal allowed_wr_len             : unsigned(32-1 downto 0);
  signal allowed_wr_len_chk         : unsigned(32-1 downto 0);

  signal rd_len_tofake              : unsigned(32-1 downto 0);
  signal rd_len_tofake_chk          : unsigned(32-1 downto 0);

  signal max_wr_len                 : unsigned(32-1 downto 0);
  -- comb only, no process

  signal next_fifo4_data_in         : noc_flit_type;
  signal next_fifo4_void_intent     : std_ulogic;

  signal faked_reply_header               : noc_flit_type;
  signal faked_reply_data_body            : noc_flit_type;
  signal faked_reply_data_tail            : noc_flit_type;
  signal dummy_flit_payload               : std_logic_vector(NOC_FLIT_SIZE-PREAMBLE_WIDTH-1 downto 0) := (others => '0');

  signal noc3_msg_type : noc_msg_type;
  signal noc3_preamble : noc_preamble_type;
  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

  signal noc2_dummy_in_stop   : std_ulogic;
  signal noc1_dummy_out_data  : noc_flit_type;
  signal noc1_dummy_out_void  : std_ulogic;

  -- attribute mark_debug : string;

  -- attribute mark_debug of interrupt_ack_wrreq : signal is "true";
  -- attribute mark_debug of interrupt_ack_data_in : signal is "true";
  -- attribute mark_debug of interrupt_ack_full : signal is "true";
  -- attribute mark_debug of interrupt_rdreq : signal is "true";
  -- attribute mark_debug of interrupt_data_out : signal is "true";
  -- attribute mark_debug of interrupt_empty : signal is "true";
  -- attribute mark_debug of noc5_msg_type : signal is "true";
  -- attribute mark_debug of noc5_preamble : signal is "true";
  -- attribute mark_debug of noc5_fifos_current : signal is "true";
  -- attribute mark_debug of noc5_fifos_next : signal is "true";
  -- attribute mark_debug of to_noc5_fifos_current : signal is "true";
  -- attribute mark_debug of to_noc5_fifos_next : signal is "true";
  
begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- To noc1: coherence requests from CPU to directory (GET/PUT)
  noc1_out_stop <= '0';
  noc1_dummy_out_data <= noc1_out_data;
  noc1_dummy_out_void <= noc1_out_void;
  noc1_in_data          <= coherence_req_data_out;
  noc1_in_void          <= coherence_req_empty or noc1_in_stop;
  coherence_req_rdreq   <= (not coherence_req_empty) and (not noc1_in_stop);
  fifo_1: fifo0
    generic map (
      depth => 6,                       --Header, address, [cache line]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_req_rdreq,
      wrreq    => coherence_req_wrreq,
      data_in  => coherence_req_data_in,
      empty    => coherence_req_empty,
      full     => coherence_req_full,
      data_out => coherence_req_data_out);


  -- From noc2: coherence forwarded messages to CPU (INV, GETS/M)
  noc2_in_data          <= (others => '0');
  noc2_in_void          <= '1';
  noc2_dummy_in_stop    <= noc2_in_stop;
  noc2_out_stop <= coherence_fwd_full and (not noc2_out_void);
  coherence_fwd_data_in <= noc2_out_data;
  coherence_fwd_wrreq <= (not noc2_out_void) and (not coherence_fwd_full);

  fifo_2: fifo0
    generic map (
      depth => 4,                       --Header, address (x2)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_fwd_rdreq,
      wrreq    => coherence_fwd_wrreq,
      data_in  => coherence_fwd_data_in,
      empty    => coherence_fwd_empty,
      full     => coherence_fwd_full,
      data_out => coherence_fwd_data_out);


  -- From noc3: coherence response messages to CPU (DATA, INVACK, PUTACK)
  noc3_out_stop <= coherence_rsp_rcv_full and (not noc3_out_void);
  coherence_rsp_rcv_data_in <= noc3_out_data;
  coherence_rsp_rcv_wrreq <= (not noc3_out_void) and (not coherence_rsp_rcv_full);

  fifo_3: fifo0
    generic map (
      depth => 5,                       --Header (use RESERVED field to
                                        --determine  ACK number), cache line
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_rcv_rdreq,
      wrreq    => coherence_rsp_rcv_wrreq,
      data_in  => coherence_rsp_rcv_data_in,
      empty    => coherence_rsp_rcv_empty,
      full     => coherence_rsp_rcv_full,
      data_out => coherence_rsp_rcv_data_out);


  -- To noc3: coherence response messages from CPU (DATA, EDATA, INVACK)
  noc3_in_data          <= coherence_rsp_snd_data_out;
  noc3_in_void          <= coherence_rsp_snd_empty or noc3_in_stop;
  coherence_rsp_snd_rdreq   <= (not coherence_rsp_snd_empty) and (not noc3_in_stop);
  fifo_4: fifo0
    generic map (
      depth => 5,                       --Header
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherence_rsp_snd_rdreq,
      wrreq    => coherence_rsp_snd_wrreq,
      data_in  => coherence_rsp_snd_data_in,
      empty    => coherence_rsp_snd_empty,
      full     => coherence_rsp_snd_full,
      data_out => coherence_rsp_snd_data_out);



  -- From noc4: DMA response to accelerators
  noc4_out_stop   <= dma_rcv_full and (not noc4_out_void);
  dma_rcv_data_in_noc <= noc4_out_data;
  dma_rcv_wrreq   <= (not dma_rcv_void_intent) and (not dma_rcv_full);
  fifo_14: fifo0
    generic map (
      depth => 18,                      --Header, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_rcv_rdreq,
      wrreq    => dma_rcv_wrreq,
      data_in  => dma_rcv_data_in,
      empty    => dma_rcv_empty,
      full     => dma_rcv_full,
      data_out => dma_rcv_data_out);



  -- From noc6: Coherent DMA response to accelerators
  noc6_out_stop   <= coherent_dma_rcv_full and (not noc6_out_void);
  coherent_dma_rcv_data_in <= noc6_out_data;
  coherent_dma_rcv_wrreq   <= (not noc6_out_void) and (not coherent_dma_rcv_full);
  fifo_14c: fifo0
    generic map (
      depth => 18,                      --Header, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherent_dma_rcv_rdreq,
      wrreq    => coherent_dma_rcv_wrreq,
      data_in  => coherent_dma_rcv_data_in,
      empty    => coherent_dma_rcv_empty,
      full     => coherent_dma_rcv_full,
      data_out => coherent_dma_rcv_data_out);

  
  -- To noc6: DMA requests from accelerators
  noc6_in_data_unsafe <= dma_snd_data_out;
  noc6_in_void_unsafe <= dma_snd_empty or noc6_in_stop; -- 1 for don't send!
  dma_snd_rdreq <= (not dma_snd_empty) and (not noc6_in_stop) and (not fifo_read_blocked_by_aker);
  fifo_13: fifo0
    generic map (
      depth => 18,                      --Header, address, length or data
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_snd_rdreq,
      wrreq    => dma_snd_wrreq,
      data_in  => dma_snd_data_in,
      empty    => dma_snd_empty,
      full     => dma_snd_full,
      data_out => dma_snd_data_out);

  access_control_fsm: process (clk, rst)
  begin
    if rst = '0' then
      aker_current <= idle_check_header;
    elsif clk'event and clk = '1' then
      --noc6_in_data <= noc6_in_data_unsafe;
      --noc6_in_void <= noc6_in_void_unsafe;
      aker_current <= aker_next;
      noc6_in_data <= next_noc6_in_data;
      noc6_in_void <= next_noc6_in_void;
      max_rd_len_chk <= max_rd_len;
      allowed_wr_len_chk <= allowed_wr_len;
      rd_len_tofake_chk <= rd_len_tofake;
      request_ERROR_illegal_chk <= request_ERROR_illegal;
      holded_dma_snd_header_chk <= holded_dma_snd_header;
      holded_dma_snd_addr_chk <= holded_dma_snd_addr;
      holded_dma_snd_len_chk <= holded_dma_snd_len;
      if aker_current = check_addr_rd then
        report "Checking address for read" & time'image(now);
      end if;
    end if;
  end process;


  faked_reply_header <= PREAMBLE_HEADER & dummy_flit_payload;
  faked_reply_data_body <= PREAMBLE_BODY & dummy_flit_payload;
  faked_reply_data_tail <= PREAMBLE_TAIL & dummy_flit_payload;

  access_control_operations: process (aker_current, noc6_in_data_unsafe, noc6_in_void_unsafe, noc6_in_stop, request_ERROR_illegal,
              max_rd_len_chk, allowed_wr_len_chk, rd_len_tofake_chk, request_ERROR_illegal_chk, holded_dma_snd_header_chk, holded_dma_snd_addr_chk, holded_dma_snd_len_chk,
              dma_rcv_data_in_noc, noc4_out_void, SECURITY_ON_chk, RD_BASE_ADDR_1, RD_RANGE_SIZE_1, RD_BASE_ADDR_2, RD_RANGE_SIZE_2,
              holded_dma_snd_header, holded_dma_snd_addr, holded_dma_snd_len, faked_reply_header, dma_rcv_full, rd_len_tofake,
              faked_reply_data_body, faked_reply_data_tail, WR_BASE_ADDR_1, WR_RANGE_SIZE_1, WR_BASE_ADDR_2, WR_RANGE_SIZE_2, allowed_wr_len)
  begin
    aker_next <= aker_current;
    dma_rcv_data_in <= dma_rcv_data_in_noc;
    dma_rcv_void_intent <= noc4_out_void;
    next_noc6_in_data <= (others => '0');
    next_noc6_in_void <= '1';
    rd_len_tofake <= rd_len_tofake_chk;
    allowed_wr_len <= allowed_wr_len_chk;
    max_rd_len <= max_rd_len_chk;
    fifo_read_blocked_by_aker <= '0';
    request_ERROR_illegal <= request_ERROR_illegal_chk;
    holded_dma_snd_addr <= holded_dma_snd_addr_chk;
    holded_dma_snd_header <= holded_dma_snd_header_chk;
    holded_dma_snd_len <= holded_dma_snd_len_chk;

    
    case aker_current is
      when idle_check_header =>
        if SECURITY_ON_chk = '1' and noc6_in_void_unsafe = '0' and noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_HEADER then
          -- read
          if noc6_in_data_unsafe(NOC_FLIT_SIZE-PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
              NOC_FLIT_SIZE-PREAMBLE_WIDTH-4*YX_WIDTH-MSG_TYPE_WIDTH) = DMA_TO_DEV then
            aker_next <= check_addr_rd;
            next_noc6_in_data <= (others => '0');
            next_noc6_in_void <= '1';
            holded_dma_snd_header <= noc6_in_data_unsafe;
          -- write
          elsif noc6_in_data_unsafe(NOC_FLIT_SIZE-PREAMBLE_WIDTH - 4*YX_WIDTH - 1 downto
              NOC_FLIT_SIZE-PREAMBLE_WIDTH-4*YX_WIDTH-MSG_TYPE_WIDTH) = DMA_FROM_DEV then
            aker_next <= check_addr_wr;
            next_noc6_in_data <= (others => '0');
            next_noc6_in_void <= '1';
            holded_dma_snd_header <= noc6_in_data_unsafe;
          else 
            next_noc6_in_data <= noc6_in_data_unsafe;
            next_noc6_in_void <= noc6_in_void_unsafe;
          end if;          
        else 
          next_noc6_in_data <= noc6_in_data_unsafe;
          next_noc6_in_void <= noc6_in_void_unsafe;
        end if;
        fifo_read_blocked_by_aker <= '0';
        request_ERROR_illegal <= '0';
      when check_addr_rd =>
        if noc6_in_void_unsafe = '0' and noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_BODY then 
          if unsigned(noc6_in_data_unsafe(32-1 downto 0)) >= RD_BASE_ADDR_1 and 
              unsigned(noc6_in_data_unsafe(32-1 downto 0)) < RD_BASE_ADDR_1+RD_RANGE_SIZE_1 then
            aker_next <= check_len_rd;
            holded_dma_snd_addr <= noc6_in_data_unsafe;
            max_rd_len <= RD_BASE_ADDR_1+RD_RANGE_SIZE_1 - unsigned(noc6_in_data_unsafe(32-1 downto 0));
          elsif unsigned(noc6_in_data_unsafe(32-1 downto 0)) >= RD_BASE_ADDR_2 and 
              unsigned(noc6_in_data_unsafe(32-1 downto 0)) < RD_BASE_ADDR_2+RD_RANGE_SIZE_2 then
            aker_next <= check_len_rd;
            holded_dma_snd_addr <= noc6_in_data_unsafe;
            max_rd_len <= RD_BASE_ADDR_2+RD_RANGE_SIZE_2 - unsigned(noc6_in_data_unsafe(32-1 downto 0));
          else
            aker_next <= check_len_rd;
            request_ERROR_illegal <= '1';
            max_rd_len <= (others => '0');
          end if;
        end if;
        --end if;
        next_noc6_in_data <= (others => '0');
        next_noc6_in_void <= '1';
        fifo_read_blocked_by_aker <= '0';
      when check_len_rd =>
        if noc6_in_void_unsafe = '0' and noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_TAIL then 
          if unsigned(noc6_in_data_unsafe(32-1 downto 0)) <= max_rd_len_chk and request_ERROR_illegal_chk = '0' then
            aker_next <= release_header_rd;
            holded_dma_snd_len <= noc6_in_data_unsafe;
            fifo_read_blocked_by_aker <= '1';
          else 
            aker_next <= faking_header_rd;
            rd_len_tofake <= unsigned(noc6_in_data_unsafe(32-1 downto 0));
            fifo_read_blocked_by_aker <= '1';
          end if;
        else 
          fifo_read_blocked_by_aker <= '0';
        end if;
        next_noc6_in_data <= (others => '0');
        next_noc6_in_void <= '1';        
      when release_header_rd =>
        if noc6_in_stop = '0' then
          aker_next <= release_addr_rd;
          next_noc6_in_data <= holded_dma_snd_header_chk;
          next_noc6_in_void <= '0';
        else
          next_noc6_in_data <= (others => '0');
          next_noc6_in_void <= '1';
        end if;
        fifo_read_blocked_by_aker <= '1';
      when release_addr_rd =>
        if noc6_in_stop = '0' then
          aker_next <= release_len_rd;
          next_noc6_in_data <= holded_dma_snd_addr_chk;
          next_noc6_in_void <= '0';
        else
          next_noc6_in_data <= (others => '0');
          next_noc6_in_void <= '1';
        end if;
        fifo_read_blocked_by_aker <= '1';
      when release_len_rd =>
        if noc6_in_stop = '0' then
          aker_next <= idle_check_header;
          next_noc6_in_data <= holded_dma_snd_len_chk;
          next_noc6_in_void <= '0';
          fifo_read_blocked_by_aker <= '0';
        else
          next_noc6_in_data <= (others => '0');
          next_noc6_in_void <= '1';
          fifo_read_blocked_by_aker <= '1';
        end if;
      when blocking_rd => 
        if noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_TAIL then
          aker_next <= faking_header_rd;
          fifo_read_blocked_by_aker <= '1';
        else
          fifo_read_blocked_by_aker <= '0';
        end if;
      when faking_header_rd =>
        dma_rcv_void_intent <= '0';
        dma_rcv_data_in <= faked_reply_header;
        if (dma_rcv_full = '0') then
          aker_next <= faking_data_rd;
        end if;
        fifo_read_blocked_by_aker <= '1';
      when faking_data_rd =>
        dma_rcv_void_intent <= '0';        
        if (dma_rcv_full = '0') then
          if rd_len_tofake_chk > 1 then 
            rd_len_tofake <= rd_len_tofake_chk - 1;
            fifo_read_blocked_by_aker <= '1';
            dma_rcv_data_in <= faked_reply_data_body;
          else 
            aker_next <= idle_check_header;
            fifo_read_blocked_by_aker <= '0';
            dma_rcv_data_in <= faked_reply_data_tail;
          end if;
        else
          fifo_read_blocked_by_aker <= '1';
        end if;

      when check_addr_wr =>
        if noc6_in_void_unsafe = '0' and noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_BODY then 
          if unsigned(noc6_in_data_unsafe(32-1 downto 0)) >= WR_BASE_ADDR_1 and 
              unsigned(noc6_in_data_unsafe(32-1 downto 0)) < WR_BASE_ADDR_1+WR_RANGE_SIZE_1 then
            aker_next <= release_header_wr;
            holded_dma_snd_addr <= noc6_in_data_unsafe;
            allowed_wr_len <= WR_BASE_ADDR_1+WR_RANGE_SIZE_1 - unsigned(noc6_in_data_unsafe(32-1 downto 0));
            fifo_read_blocked_by_aker <= '1';
          elsif unsigned(noc6_in_data_unsafe(32-1 downto 0)) >= WR_BASE_ADDR_2 and 
              unsigned(noc6_in_data_unsafe(32-1 downto 0)) < WR_BASE_ADDR_2+WR_RANGE_SIZE_2 then
            aker_next <= release_header_wr;
            holded_dma_snd_addr <= noc6_in_data_unsafe;
            allowed_wr_len <= WR_BASE_ADDR_2+WR_RANGE_SIZE_2 - unsigned(noc6_in_data_unsafe(32-1 downto 0));
            fifo_read_blocked_by_aker <= '1';
          else
            aker_next <= blocking_wr;
            fifo_read_blocked_by_aker <= '0';
            request_ERROR_illegal <= '1';
          end if;
        else
          fifo_read_blocked_by_aker <= '0';
        end if;
        --end if;
        next_noc6_in_data <= (others => '0');
        next_noc6_in_void <= '1';

      when release_header_wr =>
        if noc6_in_stop = '0' then
          aker_next <= release_addr_wr;
          next_noc6_in_data <= holded_dma_snd_header_chk;
          next_noc6_in_void <= '0';
        else
          next_noc6_in_data <= (others => '0');
          next_noc6_in_void <= '1';
        end if;
        fifo_read_blocked_by_aker <= '1';
      when release_addr_wr =>
        if noc6_in_stop = '0' then
          aker_next <= pass_date_wr;
          next_noc6_in_data <= holded_dma_snd_addr_chk;
          next_noc6_in_void <= '0';
          fifo_read_blocked_by_aker <= '0';
        else
          next_noc6_in_data <= (others => '0');
          next_noc6_in_void <= '1';
          fifo_read_blocked_by_aker <= '1';
        end if;
      when pass_date_wr =>
        if noc6_in_void_unsafe = '0' and noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_TAIL then
          if allowed_wr_len_chk > 0 then
            if noc6_in_stop = '0' then
              aker_next <= idle_check_header;
              next_noc6_in_data <= noc6_in_data_unsafe;
              next_noc6_in_void <= noc6_in_void_unsafe;
              fifo_read_blocked_by_aker <= '0';
            else
              next_noc6_in_data <= (others => '0');
              next_noc6_in_void <= '1';
              fifo_read_blocked_by_aker <= '0';
            end if;
          else
            aker_next <= idle_check_header;
            next_noc6_in_data <= (others => '0');
            next_noc6_in_void <= '1';
            fifo_read_blocked_by_aker <= '0';
            request_ERROR_illegal <= '1';
          end if;
        elsif noc6_in_void_unsafe = '0' and noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_BODY then
          if allowed_wr_len_chk > 0 then
            if noc6_in_stop = '0' then
              next_noc6_in_data <= noc6_in_data_unsafe;
              next_noc6_in_void <= noc6_in_void_unsafe;
              fifo_read_blocked_by_aker <= '0';
              allowed_wr_len <= allowed_wr_len_chk - 1;
            else
              next_noc6_in_data <= (others => '0');
              next_noc6_in_void <= '1';
              fifo_read_blocked_by_aker <= '0';
            end if;
          else
            aker_next <= blocking_wr;
            next_noc6_in_data <= (others => '0');
            next_noc6_in_void <= '1';
            fifo_read_blocked_by_aker <= '0';
            request_ERROR_illegal <= '1';
          end if;
        end if; 

      when blocking_wr =>
        if noc6_in_data_unsafe(NOC_FLIT_SIZE-1 downto NOC_FLIT_SIZE-PREAMBLE_WIDTH) = PREAMBLE_TAIL then
          aker_next <= idle_check_header;
          fifo_read_blocked_by_aker <= '0';
        end if;
        next_noc6_in_data <= (others => '0');
        next_noc6_in_void <= '1';     
        
      end case;
  end process;


  -- To noc4: Coherent DMA requests from accelerators
  noc4_in_data <= coherent_dma_snd_data_out;
  noc4_in_void <= coherent_dma_snd_empty or noc4_in_stop;
  coherent_dma_snd_rdreq <= (not coherent_dma_snd_empty) and (not noc4_in_stop);
  fifo_13c: fifo0
    generic map (
      depth => 18,                      --Header, address, length or data
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => coherent_dma_snd_rdreq,
      wrreq    => coherent_dma_snd_wrreq,
      data_in  => coherent_dma_snd_data_in,
      empty    => coherent_dma_snd_empty,
      full     => coherent_dma_snd_full,
      data_out => coherent_dma_snd_data_out);

  -- From noc5: APB requests from cores
  noc5_msg_type <= get_msg_type(MISC_NOC_FLIT_SIZE, noc_flit_pad & noc5_out_data);
  noc5_preamble <= get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & noc5_out_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc5_fifos_current <= noc5_fifos_next;
      SECURITY_ON_chk <= SECURITY_ON;
    end if;
  end process;
  noc5_fifos_get_packet : process (noc5_out_data, noc5_out_void, noc5_msg_type,
                                   noc5_preamble, noc5_fifos_current,
                                   apb_rcv_full, SECURITY_ON_chk,
                                   interrupt_ack_full)
  begin  -- process noc5_get_packet
    apb_rcv_wrreq       <= '0';
    interrupt_ack_wrreq <= '0';

    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop   <= '0';
    RD_BASE_ADDR_1 <= CFG_RD_BASE_ADDR_1;
    RD_RANGE_SIZE_1 <= CFG_RD_RANGE_SIZE_1;
    RD_BASE_ADDR_2 <= CFG_RD_BASE_ADDR_2;
    RD_RANGE_SIZE_2 <= CFG_RD_RANGE_SIZE_2;
    WR_BASE_ADDR_1 <= CFG_WR_BASE_ADDR_1;
    WR_RANGE_SIZE_1 <= CFG_WR_RANGE_SIZE_1;
    WR_BASE_ADDR_2 <= CFG_WR_BASE_ADDR_2;
    WR_RANGE_SIZE_2 <= CFG_WR_RANGE_SIZE_2;
    SECURITY_ON <= SECURITY_ON_chk;

    case noc5_fifos_current is
      when none =>
        if noc5_out_void = '0' then
          if ((noc5_msg_type = REQ_REG_RD or noc5_msg_type = REQ_REG_WR)
              and noc5_preamble = PREAMBLE_HEADER) then
            if apb_rcv_full = '0' then
              apb_rcv_wrreq   <= '1';
              noc5_fifos_next <= packet_apb_rcv;
            else
              noc5_out_stop <= '1';
            end if;
          elsif (noc5_msg_type = INTERRUPT and noc5_preamble = PREAMBLE_1FLIT) then
            interrupt_ack_wrreq <= not interrupt_ack_full;
            noc5_out_stop <= interrupt_ack_full;
          elsif (noc5_msg_type = IRQ_MSG) then
            if noc5_preamble = PREAMBLE_1FLIT and noc5_out_data(5) = '1' then 
              -- ToDo: this is actually what needs to be done!
              --noc5_fifos_next <= set_rd_addr1;
              noc5_fifos_next <= none;
              SECURITY_ON <= '1';
            elsif noc5_preamble = PREAMBLE_1FLIT and noc5_out_data(5) = '0' then
              noc5_fifos_next <= none;
              SECURITY_ON <= '0';
            end if;
          end if;
        end if;

      when packet_apb_rcv =>
        apb_rcv_wrreq <= not noc5_out_void and (not apb_rcv_full);
        noc5_out_stop <= apb_rcv_full and (not noc5_out_void);
        if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
            apb_rcv_full = '0') then
          noc5_fifos_next <= none;
        end if;

        
--      when set_rd_addr1 =>
--        if noc5_out_void = '0' then
--          RD_BASE_ADDR_1 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_rd_range1;
--        end if;
--      when set_rd_range1 =>
--        if noc5_out_void = '0' then
--          RD_RANGE_SIZE_1 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_rd_addr2;
--        end if;
--      when set_rd_addr2 =>
--        if noc5_out_void = '0' then
--          RD_BASE_ADDR_2 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_rd_range2;
--        end if;
--      when set_rd_range2 =>
--        if noc5_out_void = '0' then
--          RD_RANGE_SIZE_2 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_wr_addr1;
--        end if;
--      when set_wr_addr1 =>
--        if noc5_out_void = '0' then
--          WR_BASE_ADDR_1 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_wr_range1;
--        end if;
--      when set_wr_range1 =>
--        if noc5_out_void = '0' then
--          WR_RANGE_SIZE_1 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_wr_addr2;
--        end if;
--      when set_wr_addr2 =>
--        if noc5_out_void = '0' then
--          WR_BASE_ADDR_2 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= set_wr_range2;
--        end if;
--      when set_wr_range2 =>
--        if noc5_out_void = '0' then
--          WR_RANGE_SIZE_2 <= unsigned(noc5_out_data(32-1 downto 0));
--          noc5_fifos_next <= none;
--        end if;
      when others =>
        noc5_fifos_next <= none;


    end case;
  end process noc5_fifos_get_packet;

  apb_rcv_data_in <= noc5_out_data;
  fifo_10 : fifo0
    generic map (
      depth => 3,                       --Header, address, data
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_rcv_rdreq,
      wrreq    => apb_rcv_wrreq,
      data_in  => apb_rcv_data_in,
      empty    => apb_rcv_empty,
      full     => apb_rcv_full,
      data_out => apb_rcv_data_out);
  
  interrupt_ack_data_in <= noc5_out_data;
  fifo_16 : fifo0
    generic map (
      depth => 2,                       --Header x # accelerators
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => interrupt_ack_rdreq,
      wrreq    => interrupt_ack_wrreq,
      data_in  => interrupt_ack_data_in,
      empty    => interrupt_ack_empty,
      full     => interrupt_ack_full,
      data_out => interrupt_ack_data_out);

  -- To noc5: APB response from accelerators
  -- To noc5: interrupts from accelerators
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc5_fifos_current <= to_noc5_fifos_next;
    end if;
  end process;
  noc5_fifos_put_packet: process (noc5_in_stop, to_noc5_fifos_current,
                                  apb_snd_data_out, apb_snd_empty,
                                  interrupt_data_out, interrupt_empty)
    variable to_noc5_preamble : noc_preamble_type;
  begin  -- process noc5_get_packet
    noc5_in_data <= (others => '0');
    noc5_in_void <= '1';
    apb_snd_rdreq <= '0';
    interrupt_rdreq <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble := "00";

    case to_noc5_fifos_current is
      when none => if apb_snd_empty = '0' then
                     if noc5_in_stop = '0' then
                       noc5_in_data <= apb_snd_data_out;
                       noc5_in_void <= apb_snd_empty;
                       apb_snd_rdreq <= '1';
                       to_noc5_fifos_next <= packet_apb_snd;
                     end if;
                   elsif interrupt_empty = '0' then
                     if noc5_in_stop = '0' then
                       noc5_in_data <= interrupt_data_out;
                       noc5_in_void <= interrupt_empty;
                       interrupt_rdreq <= '1';
                     end if;
                   end if;

      when packet_apb_snd => to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, noc_flit_pad & apb_snd_data_out);
                             if (noc5_in_stop = '0' and apb_snd_empty = '0') then
                               noc5_in_data <= apb_snd_data_out;
                               noc5_in_void <= apb_snd_empty;
                               apb_snd_rdreq <= not noc5_in_stop;
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when others => to_noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_put_packet;

  fifo_7: fifo0
    generic map (
      depth => 2,                       --Header, data (1 Word)
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_snd_rdreq,
      wrreq    => apb_snd_wrreq,
      data_in  => apb_snd_data_in,
      empty    => apb_snd_empty,
      full     => apb_snd_full,
      data_out => apb_snd_data_out);

  fifo_15: fifo0
    generic map (
      depth => 2,                       --Header only x possible sharers
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => interrupt_rdreq,
      wrreq    => interrupt_wrreq,
      data_in  => interrupt_data_in,
      empty    => interrupt_empty,
      full     => interrupt_full,
      data_out => interrupt_data_out);

end rtl;

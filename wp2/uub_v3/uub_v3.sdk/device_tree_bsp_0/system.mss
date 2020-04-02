
 PARAMETER VERSION = 2.2.0


BEGIN OS
 PARAMETER OS_NAME = device_tree
 PARAMETER PROC_INSTANCE = ps7_cortexa9_0
END


BEGIN PROCESSOR
 PARAMETER DRIVER_NAME = cpu_cortexa9
 PARAMETER HW_INSTANCE = ps7_cortexa9_0
END


BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartlite
 PARAMETER HW_INSTANCE = axi_uartlite_0
 PARAMETER clock-names = ref_clk
 PARAMETER clocks = clkc 0
 PARAMETER interrupt-parent = intc
 PARAMETER interrupts = 0 31 1
 PARAMETER port-number = 2
 PARAMETER reg = 0x42c00000 0x10000
 PARAMETER xlnx,baudrate = 9600
 PARAMETER xlnx,data-bits = 8
 PARAMETER xlnx,odd-parity = 0
 PARAMETER xlnx,s-axi-aclk-freq-hz-d = 50.0
 PARAMETER xlnx,use-parity = 0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartlite
 PARAMETER HW_INSTANCE = axi_uartlite_1
 PARAMETER clock-names = ref_clk
 PARAMETER clocks = clkc 0
 PARAMETER interrupt-parent = intc
 PARAMETER interrupts = 0 34 1
 PARAMETER port-number = 3
 PARAMETER reg = 0x42c10000 0x10000
 PARAMETER xlnx,baudrate = 9600
 PARAMETER xlnx,data-bits = 8
 PARAMETER xlnx,odd-parity = 0
 PARAMETER xlnx,s-axi-aclk-freq-hz-d = 50.0
 PARAMETER xlnx,use-parity = 0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = digital_interface_0
 PARAMETER compatible = xlnx,digital-interface-1.0
 PARAMETER reg = 0x43c80000 0x10000
 PARAMETER xlnx,s00-axi-addr-width = 4
 PARAMETER xlnx,s00-axi-data-width = 32
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = interface_uub_dfn3_0
 PARAMETER compatible = xlnx,interface-uub-dfn3-1.0
 PARAMETER reg = 0x43c00000 0x10000
 PARAMETER xlnx,s00-axi-addr-width = 4
 PARAMETER xlnx,s00-axi-data-width = 32
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_2
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_3
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_coresight_comp_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ddrps
 PARAMETER HW_INSTANCE = ps7_ddr_0
 PARAMETER reg = 0x0 0x40000000
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ddrcps
 PARAMETER HW_INSTANCE = ps7_ddrc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = devcfg
 PARAMETER HW_INSTANCE = ps7_dev_cfg_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = none
 PARAMETER HW_INSTANCE = ps7_dma_ns
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = dmaps
 PARAMETER HW_INSTANCE = ps7_dma_s
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = emacps
 PARAMETER HW_INSTANCE = ps7_ethernet_0
 PARAMETER enet-reset = gpio0 50 0
 PARAMETER phy-mode = rgmii-id
 PARAMETER xlnx,ptp-enet-clock = 55555557
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = globaltimerps
 PARAMETER HW_INSTANCE = ps7_globaltimer_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpiops
 PARAMETER HW_INSTANCE = ps7_gpio_0
 PARAMETER emio-gpio-width = 64
 PARAMETER gpio-mask-high = 0
 PARAMETER gpio-mask-low = 22016
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_gpv_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = iicps
 PARAMETER HW_INSTANCE = ps7_i2c_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = iicps
 PARAMETER HW_INSTANCE = ps7_i2c_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_intc_dist_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_iop_bus_config_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_l2cachec_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ocmcps
 PARAMETER HW_INSTANCE = ps7_ocmc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = pl310ps
 PARAMETER HW_INSTANCE = ps7_pl310_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = pmups
 PARAMETER HW_INSTANCE = ps7_pmu_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = qspips
 PARAMETER HW_INSTANCE = ps7_qspi_0
 PARAMETER is-dual = 0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_qspi_linear_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ramps
 PARAMETER HW_INSTANCE = ps7_ram_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = none
 PARAMETER HW_INSTANCE = ps7_ram_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_scuc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = scugic
 PARAMETER HW_INSTANCE = ps7_scugic_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = scutimer
 PARAMETER HW_INSTANCE = ps7_scutimer_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = scuwdt
 PARAMETER HW_INSTANCE = ps7_scuwdt_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = slcrps
 PARAMETER HW_INSTANCE = ps7_slcr_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = spips
 PARAMETER HW_INSTANCE = ps7_spi_0
 PARAMETER num-cs = 3
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = spips
 PARAMETER HW_INSTANCE = ps7_spi_1
 PARAMETER num-cs = 3
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartps
 PARAMETER HW_INSTANCE = ps7_uart_0
 PARAMETER port-number = 4
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartps
 PARAMETER HW_INSTANCE = ps7_uart_1
 PARAMETER port-number = 5
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = usbps
 PARAMETER HW_INSTANCE = ps7_usb_0
 PARAMETER usb-reset = gpio0 51 0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = xadcps
 PARAMETER HW_INSTANCE = ps7_xadc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = rd_block_axi_bram_ctrl_1
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80000000 0x8000
 PARAMETER xlnx,bram-addr-width = 13
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 8192
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = rd_block_rd_interface_0
 PARAMETER compatible = xlnx,rd-interface-2.0
 PARAMETER reg = 0x43c60000 0x10000
 PARAMETER xlnx,s00-axi-addr-width = 4
 PARAMETER xlnx,s00-axi-data-width = 32
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = test_control_block_axi_bram_ctrl_0
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x4e000000 0x2000
 PARAMETER xlnx,bram-addr-width = 11
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 2048
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = test_control_block_axi_bram_ctrl_1
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x52000000 0x2000
 PARAMETER xlnx,bram-addr-width = 11
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 2048
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = test_control_block_test_control_0
 PARAMETER compatible = xlnx,test-control-1.0
 PARAMETER reg = 0x43c40000 0x10000
 PARAMETER xlnx,s00-axi-addr-width = 4
 PARAMETER xlnx,s00-axi-data-width = 32
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = time_tagging_0
 PARAMETER compatible = xlnx,time-tagging-1.0
 PARAMETER interrupt-parent = intc
 PARAMETER interrupts = 0 29 4
 PARAMETER reg = 0x43c30000 0x10000 0x43c70000 0x10000
 PARAMETER xlnx,intr-active-state = 0xFFFFFFFF
 PARAMETER xlnx,intr-sensitivity = 0xFFFFFFFF
 PARAMETER xlnx,irq-active-state = 1
 PARAMETER xlnx,irq-sensitivity = 1
 PARAMETER xlnx,s-axi-intr-addr-width = 5
 PARAMETER xlnx,s-axi-intr-data-width = 32
 PARAMETER xlnx,s00-axi-addr-width = 6
 PARAMETER xlnx,s00-axi-data-width = 32
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_muon_memory_block_axi_bram_ctrl_0
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80040000 0x20000
 PARAMETER xlnx,bram-addr-width = 15
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 32768
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_muon_memory_block_axi_bram_ctrl_1
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80060000 0x20000
 PARAMETER xlnx,bram-addr-width = 15
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 32768
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_sde_trigger_0
 PARAMETER compatible = xlnx,sde-trigger-3.0
 PARAMETER reg = 0x43c10000 0x10000 0x43c20000 0x10000 0x43c50000 0x10000
 PARAMETER xlnx,intr-active-state = 0xFFFFFFFF
 PARAMETER xlnx,intr-sensitivity = 0xFFFFFFFF
 PARAMETER xlnx,irq-active-state = 1
 PARAMETER xlnx,irq-sensitivity = 1
 PARAMETER xlnx,s-axi-intr-addr-width = 5
 PARAMETER xlnx,s-axi-intr-data-width = 32
 PARAMETER xlnx,s00-axi-addr-width = 10
 PARAMETER xlnx,s00-axi-data-width = 32
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_shower_memory_block_axi_bram_ctrl_0
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80008000 0x8000
 PARAMETER xlnx,bram-addr-width = 13
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 8192
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_shower_memory_block_axi_bram_ctrl_1
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80010000 0x8000
 PARAMETER xlnx,bram-addr-width = 13
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 8192
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_shower_memory_block_axi_bram_ctrl_2
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80018000 0x8000
 PARAMETER xlnx,bram-addr-width = 13
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 8192
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_shower_memory_block_axi_bram_ctrl_3
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80020000 0x8000
 PARAMETER xlnx,bram-addr-width = 13
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 8192
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = trigger_memory_block_shower_memory_block_axi_bram_ctrl_4
 PARAMETER compatible = xlnx,axi-bram-ctrl-4.0
 PARAMETER reg = 0x80028000 0x8000
 PARAMETER xlnx,bram-addr-width = 13
 PARAMETER xlnx,bram-inst-mode = EXTERNAL
 PARAMETER xlnx,ecc = 0
 PARAMETER xlnx,ecc-onoff-reset-value = 0
 PARAMETER xlnx,ecc-type = 0
 PARAMETER xlnx,fault-inject = 0
 PARAMETER xlnx,memory-depth = 8192
 PARAMETER xlnx,s-axi-ctrl-addr-width = 32
 PARAMETER xlnx,s-axi-ctrl-data-width = 32
 PARAMETER xlnx,s-axi-id-width = 12
 PARAMETER xlnx,s-axi-supports-narrow-burst = 0
 PARAMETER xlnx,single-port-bram = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = axi_iic
 PARAMETER HW_INSTANCE = axi_iic_0
 PARAMETER interrupt-parent = intc
 PARAMETER interrupts = 0 35 4
 PARAMETER reg = 0x41600000 0x10000
END



#include "linux/of.h"
#include <linux/module.h>
#include <linux/init.h>
#include <linux/spi/spi.h>


MODULE_LICENSE("GPL");
MODULE_AUTHOR("ProgramistaPrzemyslaw");
MODULE_DESCRIPTION("VHDLscope module");

#define BUS_NUM_SPI 0
static struct spi_device *VHDLscope;

static int __init initModule(void) {
	u8 msg[] = {0b00001000, 0b00000000, 0b00000100};
	struct spi_master *master;
	struct spi_board_info spartan_fpga_info={
		.modalias = "spartan-3a",
		.max_speed_hz = 10000000,
		.bus_num = BUS_NUM_SPI,
		.chip_select = 0,
		.mode = 0,
	};
	pr_info("Loading module\n");
	master = spi_busnum_to_master(BUS_NUM_SPI);
	if(!master){
		pr_err("No spi bus with Nr %d. Exiting",BUS_NUM_SPI);
		return -1;
	}

	VHDLscope = spi_new_device(master, &spartan_fpga_info);
	if(!VHDLscope){
		pr_err("Failed to create device \n");
		return -1;
	}
	
	if(spi_setup(VHDLscope) != 0){
		pr_err("Could not change bus setup!\n");
		spi_unregister_device(VHDLscope);
		return -1;
	}

	if(spi_write(VHDLscope, msg, sizeof(8))==0){
		pr_info("MSG send success\n");
	}else{
		pr_err("MSG send fail\n");
	}
	pr_info("Module initialized\n");
	return 0;
}

static void __exit exitModule(void) {
	printk("Goodbye World\n");
}

module_init(initModule);
module_exit(exitModule);
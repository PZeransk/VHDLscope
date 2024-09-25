#include "asm-generic/fcntl.h"
#include "linux/spi/spidev.h"
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <signal.h>
#include <unistd.h>
#include <stdint.h>

#define arg_cnt 3


void print_use_info(){
    printf("Bad arguments! \n\
    Avalible argumens are:\n\
    measure signal: [spi path] [measure] [meas_cnt] \n");
}

void get_args(int argc, char* argv[]){

    
}

int main(int argc, char* argv[]){
    int spi_dev = 0;
    int fd;
    unsigned int spi_mode;
    unsigned int freq;
    int ret;
    uint8_t meas_msg[] = {0b00001000, 0b00000000, 0b00000100};
    struct spi_ioc_transfer buf[1] = {0};

    if(argc < arg_cnt){
        printf( "Not enough arguments\n");
        return -1;
    }



    fd = open(argv[1],O_RDWR);
    if(fd < 0){
        printf("ERROR while opening spi dev: %s\n",argv[1]);
        return -1;
    }

    spi_mode = 0;
    if(ioctl(fd, SPI_IOC_WR_MODE, &spi_mode)<0){
        printf("ERROR while set mode\n");
        return -1;       
    }

    if(ioctl(fd, SPI_IOC_RD_MODE, &ret)>=0){
        printf("mode: %d\n",ret);   
    }

    
    freq = 8000000;
    if (ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &freq) < 0) {
        printf("ERROR ioctl() set speed\n");
        return -1;
    }
    if (ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &ret) < 0) {
        printf("ERROR ioctl() get speed\n");
        return -1;
    } else
        printf("speed set to %d\n", ret);



    buf[0].tx_buf = (unsigned long)meas_msg;
    buf[0].len = 3; 

    // send data
    if (ioctl(fd, SPI_IOC_MESSAGE(1), buf) < 0)
        perror("SPI_IOC_MESSAGE");



    // close device
    close(fd);

    


    printf("MSG sent \n");
    return 0;
}
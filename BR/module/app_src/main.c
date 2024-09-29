#include "asm-generic/fcntl.h"
#include "linux/spi/spidev.h"
#include "linux/string.h"
#include "linux/types.h"
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <signal.h>
#include <unistd.h>
#include <stdint.h>

#define arg_cnt 2 // only to include path to device
#define gen_arg_cnt 5
#define meas_arg_cnt 4

void print_use_info(){
printf("Bad arguments! \n\
Avalible argumens are:\n\
measure signal: [spi path] [measure] [n_sample]\n\
generate sinus: [spi path] [gen_sinus] [freq] [amplitude]\n");
    
}

void get_args(int argc, char* argv[]){

    
}


int measure_dac(uint16_t n_samples, int fd){

    printf("Taking %d samples\n",n_samples);

    uint8_t msg[3];
    struct spi_ioc_transfer buf[1] = {0};
    msg[0] = 0b00001000;

    if(n_samples < 256){
        msg[1] = 0b00000000;
        msg[2] = (uint8_t)n_samples;
    }else if(n_samples >= 256){
        // converting uint_16 value to two uint8_t
        msg[1] = (uint8_t)(n_samples & 0xff);
        msg[2] = (uint8_t)(n_samples >> 8);
    }

    buf[0].tx_buf = (unsigned long)msg;
    buf[0].len = 3; 

    if (ioctl(fd, SPI_IOC_MESSAGE(1), buf) < 0){
        perror("SPI_IOC_MESSAGE");
        return -1;
    }

    return 0;
}

int gen_sin_wave(uint16_t freq,uint8_t amplitude, int fd){
  
    /*Max output freqency should be around 67 kHz because
    t_settle = 6 us
    t_bit = 1/3.4 MHz (with the fastest mode)
    f_max = 1/(t_settle + 27*t_bit) = 67460 Hz
    Command described in section 6.1 in MCP4726 datasheet
    is 27 bit long

    This frequency will be cut down to 16 bit value, because it will
    fit perfectly in current command structure

    Amplitude is not used for now
    */
    
    uint8_t msg[3];
    struct spi_ioc_transfer buf[1] = {0};

    printf("Generating sine wave with freqency of %d Hz\n",freq);

    msg[0] = 0b00001001; // gen sin command
    msg[1] = (uint8_t)(freq & 0xff);
    msg[2] = (uint8_t)(freq >> 8);

    buf[0].tx_buf = (unsigned long)msg;
    buf[0].len = 3; 

    if (ioctl(fd, SPI_IOC_MESSAGE(1), buf) < 0){
        perror("SPI_IOC_MESSAGE");
        return -1;
    }

    return 0;
}
/*
argv[0] = app_name
argv[1] = path_to_spi_dev
argv[2] = command
argv[3] = misc 1 e.g number of samples to take
argv[4] = misc 2 e.g sample rate
*/

int main(int argc, char* argv[]){
    int spi_dev = 0;
    int fd;
    unsigned int spi_mode;
    unsigned int freq;
    int ret;


    uint8_t meas_msg[] = {0b00001000, 0b00000000, 0b00000100};
    struct spi_ioc_transfer buf[1] = {0};

    if(argc <= arg_cnt){
        print_use_info();
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



    //buf[0].tx_buf = (unsigned long)meas_msg;
    //buf[0].len = 3; 

    // send data
    //if (ioctl(fd, SPI_IOC_MESSAGE(1), buf) < 0)
    //    perror("SPI_IOC_MESSAGE");

    
    if(strcmp("measure", argv[2]) == 0 && argc == meas_arg_cnt){
        ret = measure_dac(atoi(argv[3]), fd);
    }else if(strcmp("gen_sinus", argv[2]) == 0 && argc == gen_arg_cnt){
        ret = gen_sin_wave(atoi(argv[3]), atoi(argv[4]),fd);
    }else{
        printf("Wrong command or wrong amount of arguments provided\n");
    }
 
    if(ret<0)
        printf("command error with error %d \n", ret);

    // close device
    close(fd);

    


    printf("App finished \n");
    return 0;
}
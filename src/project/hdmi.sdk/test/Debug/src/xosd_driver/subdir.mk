################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/xosd_driver/xosd.c \
../src/xosd_driver/xosd_g.c \
../src/xosd_driver/xosd_intr.c \
../src/xosd_driver/xosd_selftest.c \
../src/xosd_driver/xosd_sinit.c 

OBJS += \
./src/xosd_driver/xosd.o \
./src/xosd_driver/xosd_g.o \
./src/xosd_driver/xosd_intr.o \
./src/xosd_driver/xosd_selftest.o \
./src/xosd_driver/xosd_sinit.o 

C_DEPS += \
./src/xosd_driver/xosd.d \
./src/xosd_driver/xosd_g.d \
./src/xosd_driver/xosd_intr.d \
./src/xosd_driver/xosd_selftest.d \
./src/xosd_driver/xosd_sinit.d 


# Each subdirectory must supply rules for building sources it contributes
src/xosd_driver/%.o: ../src/xosd_driver/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -MT"$@" -I../../test_bsp/microblaze_0/include -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v9.6 -mno-xl-soft-mul -mxl-multiply-high -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



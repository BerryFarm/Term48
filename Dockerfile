FROM yamsergey/bb10-ndk:0.6

ENV QNX_HOST=/root/bbndk/host_10_3_1_12/linux/x86  
ENV QNX_TARGET=/root/bbndk/target_10_3_1_995/qnx6  
ENV CC=/root/bbndk/host_10_3_1_12/linux/x86/usr/bin/arm-unknown-nto-qnx8.0.0eabi-gcc CFLAGS="-std=c99" 


# interactive container
RUN apt-get update -y ; apt-get -y install vim

ADD . /Term49

WORKDIR /Term49
RUN make

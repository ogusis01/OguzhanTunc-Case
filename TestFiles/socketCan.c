// sender.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>

int main() {
    int s;
    struct sockaddr_can addr;
    struct ifreq ifr;
    struct can_frame frame;

    // Socket oluştur
    if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
        perror("Socket oluşturulamadı");
        return 1;
    }

    // vcan0 interface bağla
    strcpy(ifr.ifr_name, "vcan0");
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl hatası");
        return 1;
    }

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind hatası");
        return 1;
    }

    // CAN frame doldur
    frame.can_id = 0x123; // Örnek ID
    frame.can_dlc = 2;    // Data uzunluğu
    frame.data[0] = 0xAB;
    frame.data[1] = 0xCD;

    // Mesajı sürekli gönder
    while (1) {
        if (write(s, &frame, sizeof(struct can_frame)) != sizeof(struct can_frame)) {
            perror("Mesaj gönderilemedi");
            return 1;
        }
        printf("Mesaj gönderildi: DATA=ABCD\n");
        sleep(1); // Her saniye gönder
    }

    close(s);
    return 0;
}

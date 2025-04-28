#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define MCAST_GRP "239.255.0.1"
#define MCAST_PORT 50002
#define MESSAGE "Hello from C Publisher!"

int main() {
    int sockfd;
    struct sockaddr_in addr;
    int ttl = 1;
    int reuse = 1;


    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }


    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
        perror("setsockopt (SO_REUSEADDR) failed");
        exit(EXIT_FAILURE);
    }


    if (setsockopt(sockfd, IPPROTO_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl)) < 0) {
        perror("setsockopt (IP_MULTICAST_TTL) failed");
        exit(EXIT_FAILURE);
    }


    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(MCAST_GRP);
    addr.sin_port = htons(MCAST_PORT);


    if (bind(sockfd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }


    struct ip_mreq mreq;
    mreq.imr_multiaddr.s_addr = inet_addr(MCAST_GRP);
    mreq.imr_interface.s_addr = htonl(INADDR_ANY);
    if (setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq)) < 0) {
        perror("setsockopt (IP_ADD_MEMBERSHIP) failed");
        exit(EXIT_FAILURE);
    }

    // Veri gönderme döngüsü
    while (1) {
        if (sendto(sockfd, MESSAGE, strlen(MESSAGE), 0, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
            perror("sendto failed");
            exit(EXIT_FAILURE);
        }
        printf("Sent: %s\n", MESSAGE);
        sleep(2); // 2 saniyede bir mesaj gönder
    }

    close(sockfd);
    return 0;
}

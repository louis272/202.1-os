#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char* argv[]) {
  struct sockaddr_in server_address;
  memset(&server_address, 0, sizeof(server_address));
  server_address.sin_family = AF_INET;
  server_address.sin_addr.s_addr = htonl(INADDR_ANY);
  server_address.sin_port = htons(5050);

  int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
  bind(listen_fd, reinterpret_cast<struct sockaddr*>(&server_address), sizeof(server_address));
  listen(listen_fd, 10);

  char const* message = "Hello, Client!\n";
  while(true) {
    int connection = accept(listen_fd, nullptr, nullptr);
    write(connection, message, strlen(message));
    close(connection);
  }
  return 0;
}
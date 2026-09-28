#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <cstring>
#include <vector>

int main(int argc, char* argv[]) {
  struct sockaddr_in server_address;
  memset(&server_address, 0, sizeof(server_address));
  server_address.sin_family = AF_INET;
  server_address.sin_addr.s_addr = htonl(INADDR_ANY);
  server_address.sin_port = htons(5050);

  int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
  bind(listen_fd, reinterpret_cast<struct sockaddr*>(&server_address), sizeof(server_address));
  listen(listen_fd, 10);

  const char* filename = argv[1];

  while(true) {
    int connection = accept(listen_fd, nullptr, nullptr);

    /// Read from connection and store in buffer
    std::vector<char> client_buffer;
    char tmp_buffer[4096];
    ssize_t data;

    // 1 MB limit (above that limit it works, but it's really slow (at least on my laptop))
    const size_t MAX_DATA = 1024 * 1024;
    
    // While there is data to read from connection
    while ((data = read(connection, tmp_buffer, sizeof(tmp_buffer))) > 0) {
      if (client_buffer.size() + data > MAX_DATA) {
        // Exceeded maximum data size, stop reading
        const char* message = "Maximum data size exceeded. The first 1MB have been received.\n";
        write(connection, message, strlen(message));
        break;
      }
      // Store data by parts in buffer
      client_buffer.insert(client_buffer.end(), tmp_buffer, tmp_buffer + data);
    }

    int file = open(filename, O_RDWR); // Open file for reading and writing
    
    if (file >= 0) {
      char file_buffer[4096];
      lseek(file, 0, 0);               // Go to beginning of file
      
      // Send file content on connection
      while ((data = read(file, file_buffer, sizeof(file_buffer))) > 0) {
        write(connection, file_buffer, data);
      }
    

      // If it received data from client
      if (client_buffer.size() > 0) {
        lseek(file, 0, 0);                                       // Go to beginning of file
        ftruncate(file, 0);                                      // Erase the file content
        write(file, client_buffer.data(), client_buffer.size()); // Write content of buffer to file
      }
    
      close(file);
    }

    close(connection);
  }

  return 0;
}
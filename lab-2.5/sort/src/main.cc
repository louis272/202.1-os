#include "array.hh"
#include "tree.hh"
#include <iostream>

int main() {
  // Create a binary search tree and add some elements to it.
  auto root = Tree{};
  root.insert(5);
  root.insert(2);
  root.insert(7);

  // Should print "[2, 5, 7]".
  std::cout << root.description() << std::endl;

  // Create an array and reverses a slice of it.
  int xs[8] = {0};
  for (int i = 0; i < 8; ++i) { xs[i] = i * i; }
  reverse(xs + 2, 4);

  for (int i = 0; i < 8; ++i) { std::cout << xs[i] << std::endl; }

  // Test quicksort
  int arr[] = {10, 7, 8, 9, 1, 5};
  int n = sizeof(arr) / sizeof(arr[0]);

  std::cout << "Original array: ";
  for (int i = 0; i < n; ++i) {
    std::cout << arr[i] << " ";
  }
  std::cout << std::endl;

  quicksort(arr, n);

  std::cout << "Sorted array: ";
  for (int i = 0; i < n; ++i) {
    std::cout << arr[i] << " ";
  }
  std::cout << std::endl;

  return 0;
}

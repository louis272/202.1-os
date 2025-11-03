void exchange(int* xs, int p, int q) {
  int x = xs[p];
  xs[p] = xs[q];
  xs[q] = x;
}

void reverse(int* xs, int length) {
    int i = 0;
    int j = length;
    while (i < j) { exchange(xs, i++, --j); }
}

void quicksort(int* start, int length) {
  // TODO
    if (length <= 1) return; // Base case: arrays of length 0 or 1 are already sorted

    int pivot = start[length - 1]; // Choose the last element as the pivot
    int i = -1; // Partition index

    for (int j = 0; j < length - 1; ++j) {
        if (start[j] <= pivot) {
            ++i;
            exchange(start, i, j); // Move smaller elements to the left
        }
    }

    exchange(start, i + 1, length - 1); // Place the pivot in its correct position

    // Recursively sort the left and right partitions
    quicksort(start, i + 1); // Left partition
    quicksort(start + i + 2, length - i - 2); // Right partition
}

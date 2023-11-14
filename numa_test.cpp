
#include <chrono>
#include <cstddef>
#include <cstdlib>
#include <iostream>
#include <sched.h>
#include <string>


void pin_myself_to(int core) {
  cpu_set_t mask;
  CPU_ZERO(&mask);
  CPU_SET(core, &mask);

  int set_affinity_return{sched_setaffinity(0, sizeof(mask), &mask)};

  if (set_affinity_return != 0) {
    std::cout << "Could not set affinity (return code " << set_affinity_return
              << ")" << std::endl;
  }
}

void __attribute__((optimize("O0"))) read_data(size_t array_size, uint64_t* large_array) {
  for (int i{0}; i < array_size; i++) {
    auto test{large_array[i]};
  }
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    std::cout << "Please specify at least [first-pin] [second-pin]" << std::endl;
    exit(1);
  }
  const int first_pin{atoi(argv[1])};
  const int second_pin{atoi(argv[2])};

  std::cout << "First pin: " << first_pin << "; Second pin:" << second_pin << std::endl;

  pin_myself_to(first_pin);

  size_t array_size{1024};
  if (argc > 3) {
    array_size = atoi(argv[3]);
  }

  std::cout << "Array size is " << array_size << std::endl;

  auto* large_array = new uint64_t[array_size];

  // write so we actually allocate.
  for (size_t i{0}; i < array_size; i++) {
    large_array[i] = 0x42;
  }

  pin_myself_to(second_pin);

  std::cout << "Please attach with perf and then hit some key" << std::endl;

  std::string line;
  std::getline(std::cin, line);

  std::chrono::steady_clock::time_point begin =
      std::chrono::steady_clock::now();

  read_data(array_size, large_array);

  std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();

  std::cout << "Time difference = "
            << std::chrono::duration_cast<std::chrono::milliseconds>(end -
                                                                     begin)
                   .count()
            << "ms" << std::endl;

  return 0;
}
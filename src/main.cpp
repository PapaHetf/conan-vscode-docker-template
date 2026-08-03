#include <cstdio>
#include <cstring>
#include <iostream>

#include "program_args.hpp"

int main(int argc, char **argv) {
  args::ProgramOptions prog_opt;

  auto res = prog_opt.parse(argc, argv);

  if (res.has_error()) {
    std::cerr << res.error() << std::endl;
    return EXIT_FAILURE;
  }

  if (res.has_value()) {
    printf("Working directory: %s\n",
           args::WorkingDirectory::load(prog_opt.get_variables_map()).c_str());
  }

  return 0;
}

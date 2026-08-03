#include "program_args.hpp"
#include <iostream>
#include <string>

namespace args {

ProgramOptions::ProgramOptions() : desc("Allowed options") {
  auto options = desc.add_options();
  options("help", "available options;");
  WorkingDirectory::add(options);
  PfxPassword::add(options);
}

outcome::result<bool, std::string> ProgramOptions::parse(int argc,
                                                         char *p_argv[]) {

  try {
    bpo::store(bpo::parse_command_line(argc, p_argv, desc), vm);
    bpo::notify(vm);
  } catch (bpo::unknown_option &err) {
    return outcome::failure(std::string(err.what()));
  } catch (const bpo::invalid_command_line_syntax &err) {
    return outcome::failure(std::string(err.what()));
  } catch (...) {
    return outcome::failure(std::string("Unknown parse args error"));
  }

  if (vm.count("help")) {
    desc.print(std::cout);
    return outcome::success(false);
  }

  return outcome::success(true);
}

const bpo::variables_map &ProgramOptions::get_variables_map() { return vm; }

} // namespace args
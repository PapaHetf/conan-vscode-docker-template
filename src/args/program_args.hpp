#pragma once

#include "boost/program_options.hpp"
#include <boost/outcome.hpp>
#include <boost/outcome/result.hpp>

#include <string>

namespace args {

namespace bpo = boost::program_options;
namespace outcome = BOOST_OUTCOME_V2_NAMESPACE;

class ProgramOptions {
public:
  ProgramOptions();
  ~ProgramOptions() = default;

  outcome::result<bool, std::string> parse(int argc, char *p_argv[]);
  const bpo::variables_map &get_variables_map();

private:
  bpo::options_description desc;
  bpo::variables_map vm;
};

template <typename Derived> struct Base {
  static auto load(const boost::program_options::variables_map &map) {
    return map.at(Derived::KEY).template as<typename Derived::Type>();
  }

  static void add(boost::program_options::options_description_easy_init &init) {
    init(Derived::KEY,
         boost::program_options::value<typename Derived::Type>()->default_value(
             Derived::DEFAULT_VALUE),
         Derived::DESC);
  }
};

struct WorkingDirectory : Base<WorkingDirectory> {
  using Type = std::string;
  constexpr static auto KEY = "path";
  constexpr static auto DEFAULT_VALUE = ".";
  constexpr static auto DESC = "working directory";
};

struct PfxPassword : Base<PfxPassword> {
  using Type = std::string;
  constexpr static auto KEY = "password";
  constexpr static auto DEFAULT_VALUE = "";
  constexpr static auto DESC = "PFX password";
};

} // namespace args
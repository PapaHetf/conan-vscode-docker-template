// Тесты разбора аргументов командной строки (src/args/program_args.*).
// Пример того, как тестировать код проекта: тест линкуется с module_src.
#include <gtest/gtest.h>

#include <string>
#include <vector>

#include "program_args.hpp"

namespace {

// Собирает argc/argv из списка строк, как их передаёт ОС в main().
class Argv {
public:
  explicit Argv(std::vector<std::string> args) : storage_(std::move(args)) {
    storage_.insert(storage_.begin(), "my_app");
    for (auto &arg : storage_) {
      pointers_.push_back(arg.data());
    }
    pointers_.push_back(nullptr);
  }

  [[nodiscard]] int argc() const { return static_cast<int>(storage_.size()); }
  char **argv() { return pointers_.data(); }

private:
  std::vector<std::string> storage_;
  std::vector<char *> pointers_;
};

TEST(ProgramArgs, DefaultsWithoutArguments) {
  args::ProgramOptions options;
  Argv argv({});

  auto result = options.parse(argv.argc(), argv.argv());

  ASSERT_TRUE(result.has_value()) << result.error();
  EXPECT_EQ(args::WorkingDirectory::load(options.get_variables_map()), ".");
  EXPECT_EQ(args::PfxPassword::load(options.get_variables_map()), "");
}

TEST(ProgramArgs, ParsesValues) {
  args::ProgramOptions options;
  Argv argv({"--path", "/tmp/data", "--password", "secret"});

  auto result = options.parse(argv.argc(), argv.argv());

  ASSERT_TRUE(result.has_value()) << result.error();
  EXPECT_EQ(args::WorkingDirectory::load(options.get_variables_map()),
            "/tmp/data");
  EXPECT_EQ(args::PfxPassword::load(options.get_variables_map()), "secret");
}

TEST(ProgramArgs, ParsesEqualsSyntax) {
  args::ProgramOptions options;
  Argv argv({"--path=/opt/certs"});

  auto result = options.parse(argv.argc(), argv.argv());

  ASSERT_TRUE(result.has_value()) << result.error();
  EXPECT_EQ(args::WorkingDirectory::load(options.get_variables_map()),
            "/opt/certs");
}

TEST(ProgramArgs, UnknownOptionIsError) {
  args::ProgramOptions options;
  Argv argv({"--unknown"});

  auto result = options.parse(argv.argc(), argv.argv());

  ASSERT_TRUE(result.has_error());
  EXPECT_NE(result.error().find("unknown"), std::string::npos)
      << result.error();
}

TEST(ProgramArgs, MissingValueIsError) {
  args::ProgramOptions options;
  Argv argv({"--path"});

  auto result = options.parse(argv.argc(), argv.argv());

  EXPECT_TRUE(result.has_error());
}

TEST(ProgramArgs, HelpPrintsUsage) {
  args::ProgramOptions options;
  Argv argv({"--help"});

  testing::internal::CaptureStdout();
  auto result = options.parse(argv.argc(), argv.argv());
  const std::string output = testing::internal::GetCapturedStdout();

  // --help печатает описание опций и прерывает разбор
  EXPECT_FALSE(result.has_value() && result.value());
  EXPECT_NE(output.find("--path"), std::string::npos) << output;
  EXPECT_NE(output.find("--password"), std::string::npos) << output;
}

} // namespace

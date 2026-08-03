// Пример теста — шаблон для новых тестов.
// Документация: https://google.github.io/googletest/primer.html
#include <gtest/gtest.h>

#include <string>

namespace {

TEST(SampleTest, Arithmetic) { EXPECT_EQ(2 + 2, 4); }

TEST(SampleTest, Strings) {
  const std::string hello = "hello";
  ASSERT_FALSE(hello.empty());
  EXPECT_EQ(hello.size(), 5U);
}

} // namespace

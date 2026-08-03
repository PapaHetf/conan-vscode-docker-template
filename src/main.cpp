#include <cstring>
#include <iostream>
#include <string>

#include "pfx_reader.hpp"
#include "program_args.hpp"

#include <openssl/err.h>
#include <openssl/provider.h>

// Объявляем функцию инициализации из статической библиотеки gost-engine
extern "C" OSSL_provider_init_fn OSSL_provider_init;

bool init_gost_provider() {
  // 1. Загружаем стандартный базовый провайдер OpenSSL (опционально, но
  // рекомендуется)
  OSSL_PROVIDER *base = OSSL_PROVIDER_load(nullptr, "base");
  if (!base) {
    std::cerr << "Не удалось загрузить base провайдер\n";
    return false;
  }

  // 2. Вручную регистрируем статический ГОСТ-провайдер в памяти OpenSSL
  if (!OSSL_PROVIDER_add_builtin(nullptr, "gost", OSSL_provider_init)) {
    std::cerr << "Не удалось зарегистрировать GOST в списке встроенных\n";
    return false;
  }

  // 3. Активируем зарегистрированный ГОСТ-провайдер
  OSSL_PROVIDER *gost = OSSL_PROVIDER_load(nullptr, "gost");
  if (!gost) {
    std::cerr << "Ошибка активации GOST провайдера. Код ошибки OpenSSL:\n";
    ERR_print_errors_fp(stderr);
    return false;
  }

  std::cout << "ГОСТ-провайдер (v3.0.3) успешно активирован статически!\n";
  return true;
}

int main(int argc, char **argv) {
  args::ProgramOptions prog_opt;

  auto res = prog_opt.parse(argc, argv);

  if (res.has_error()) {
    std::cerr << res.error() << std::endl;
    return EXIT_FAILURE;
  }

  if (res.has_value() && !res.value()) {
    return EXIT_SUCCESS;
  }

  std::string pfx_file_path =
      args::WorkingDirectory::load(prog_opt.get_variables_map());
  std::string pfx_password =
      args::PfxPassword::load(prog_opt.get_variables_map());

  if (!init_gost_provider()) {
    return EXIT_FAILURE;
  }

  if (!pfx_reader(pfx_file_path, pfx_password)) {
    return EXIT_FAILURE;
  }
  return 0;
}

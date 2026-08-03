#pragma once

#include <openssl/asn1.h>
#include <openssl/bio.h>
#include <openssl/engine.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/obj_mac.h>
#include <openssl/pkcs12.h>
#include <openssl/x509.h>

#include <iostream>

inline bool pfx_reader(std::string_view pfx_file_path,
                       std::string_view password) {

  // Чтение бинарного PFX-файла
  BIO *pfx_bio = BIO_new_file(pfx_file_path.data(), "rb");

  if (!pfx_bio) {
    std::cerr << "[Ошибка] Не удалось открыть файл: " << pfx_file_path
              << std::endl;
    return false;
  }

  // Преобразование в структуру PKCS12
  PKCS12 *p12 = d2i_PKCS12_bio(pfx_bio, nullptr);
  BIO_free(pfx_bio); // Дескриптор файла больше не нужен

  if (!p12) {
    ERR_print_errors_fp(stderr);
    std::cerr << "[Ошибка] Неверный формат PFX или файл поврежден."
              << std::endl;
    return false;
  }

  // Верификация MAC
  const int mac_result = PKCS12_verify_mac(p12, password.data(), -1);

  if (mac_result == 0) {
    ERR_print_errors_fp(stderr);
    std::cerr << "[Ошибка] верификации MAC" << std::endl;
    PKCS12_free(p12);
    return false;
  }

  // Диагностика MAC-алгоритма
  const X509_ALGOR *macalg = nullptr;
  PKCS12_get0_mac(nullptr, &macalg, nullptr, nullptr, p12);

  if (macalg) {
    const ASN1_OBJECT *mac_oid = nullptr;
    X509_ALGOR_get0(&mac_oid, nullptr, nullptr, macalg);

    if (mac_oid) {
      char oid_buf[128] = {0};
      OBJ_obj2txt(oid_buf, sizeof(oid_buf), mac_oid, 1);
      std::cout << "[DIAG] MAC hash algorithm (OID): " << oid_buf << std::endl;

      char name_buf[128] = {0};
      OBJ_obj2txt(name_buf, sizeof(name_buf), mac_oid, 0);
      std::cout << "[DIAG] MAC hash algorithm (name): " << name_buf
                << std::endl;

      int mac_nid = OBJ_obj2nid(mac_oid);
      std::cout << "[DIAG] MAC algorithm NID: " << mac_nid << std::endl;
      std::cout << "[DIAG] MAC algorithm NID name: "
                << (mac_nid != NID_undef ? OBJ_nid2sn(mac_nid) : "UNDEF")
                << std::endl;
    }
  }
  // Указатели для извлекаемых объектов
  EVP_PKEY *private_key = nullptr; // Сюда запишется ГОСТ закрытый ключ
  X509 *user_cert = nullptr; // Сюда запишется ГОСТ сертификат
  STACK_OF(X509) *ca_certs = nullptr; // Для цепочки CA (если есть в PFX)

  // Парсинг и расшифровка контейнера
  // Благодаря ENGINE_set_default, эта функция автоматически применит ГОСТ
  // (Магма/Кузнечик/Стрибог/34.10)
  if (!PKCS12_parse(p12, password.data(), &private_key, &user_cert,
                    &ca_certs)) {
    ERR_print_errors_fp(stderr);
    PKCS12_free(p12);
    std::cerr << "[Ошибка] Не удалось расшифровать PFX. Неверный пароль "
                 "или отсутствует поддержка нужного ГОСТ-алгоритма."
              << std::endl;
    return false;
  }

  // Проверка результатов работы
  if (user_cert && private_key) {
    std::cout << "\n[Успех] Данные успешно извлечены в оперативную память!"
              << std::endl;

    // Вывод типа извлеченного асимметричного ключа (для ГОСТ 2012 это обычно
    // NID_id_GostR3410_2012_256)
    std::cout << "-> ID алгоритма закрытого ключа: " << EVP_PKEY_id(private_key)
              << std::endl;

    // Вывод информации о владельце сертификата
    std::cout << "-> Владелец сертификата: ";
    X509_NAME_print_ex_fp(stdout, X509_get_subject_name(user_cert), 0,
                          XN_FLAG_ONELINE);
    std::cout << "\n";
  } else {
    std::cerr << "[Предупреждение] Контейнер открыт, но в нем отсутствует "
                 "пара ключ+сертификат."
              << std::endl;
  }

  // 6. Освобождение памяти и ресурсов
  X509_free(user_cert);
  EVP_PKEY_free(private_key);
  if (ca_certs) {
    sk_X509_pop_free(ca_certs, X509_free);
  }
  PKCS12_free(p12);
  return true;
}
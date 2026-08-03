# ============================================================
# Сторонние библиотеки из исходников (git-сабмодули)
# ============================================================
# Сюда подключаются библиотеки, которых нет в Conan Center или которые
# нужно собирать из конкретного коммита/форка. Если библиотека есть в Conan —
# лучше добавить её в conanfile.py (requirements) и не использовать сабмодуль.
#
# Переменные, заданные в этом файле (флаги, BUILD_SHARED_LIBS и т.п.), видны
# только здесь и в подкаталогах — на флаги основного проекта они не влияют.
#
# ------------------------------------------------------------
# Как добавить сабмодуль
# ------------------------------------------------------------
# 1. Добавить репозиторий (из корня проекта), закрепив версию тегом:
#
#      git submodule add https://github.com/<owner>/<lib>.git libraries/<lib>
#      git -C libraries/<lib> checkout v1.2.3
#      git add .gitmodules libraries/<lib>
#
# 2. Подключить ниже (раскомментировать и поправить пример):
#
#      add_subdirectory(<lib> EXCLUDE_FROM_ALL)
#      list(APPEND _libraries <lib>::<target>)
#
#    EXCLUDE_FROM_ALL — собираются только таргеты, от которых зависит проект,
#    а не тесты/примеры/утилиты библиотеки.
#
# 3. Готово: таргеты из _libraries линкуются к module_src (см. src/CMakeLists.txt).
#
# Клонирование проекта с сабмодулями:   git clone --recursive <url>
# Уже склонирован:                      git submodule update --init --recursive
# (scripts/*.sh и devcontainer делают это автоматически)
#
# Обновить сабмодуль до новой версии:
#      git -C libraries/<lib> fetch --tags && git -C libraries/<lib> checkout v1.3.0
#      git add libraries/<lib>
#
# Удалить сабмодуль:
#      git submodule deinit -f libraries/<lib>
#      git rm -f libraries/<lib>
#      rm -rf .git/modules/libraries/<lib>
#
# ------------------------------------------------------------
# Частые настройки для чужого CMake-кода
# ------------------------------------------------------------
# Старые cmake_minimum_required(VERSION < 3.5) в сабмодулях несовместимы с CMake 4.x
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
# Собирать библиотеки статически
set(BUILD_SHARED_LIBS OFF)
# Опции библиотеки задаются обычными переменными ДО add_subdirectory, например:
#   set(<LIB>_BUILD_TESTS OFF)
# Если библиотека собирается с -Werror и падает на новых компиляторах:
#   string(APPEND CMAKE_C_FLAGS " -Wno-error")
#
# Если библиотека должна попасть в бинарник целиком (плагины/провайдеры,
# которые регистрируются через статические конструкторы или ищутся по имени
# символа), используйте WHOLE_ARCHIVE:
#   list(APPEND _libraries "$<LINK_LIBRARY:WHOLE_ARCHIVE,<target>>")
# ============================================================

set(_libraries)

# ------------------------------------------------------------
# Сабмодули проекта
# ------------------------------------------------------------
# Пример:
# add_subdirectory(<lib> EXCLUDE_FROM_ALL)
# list(APPEND _libraries <lib>::<target>)


# Список таргетов для линковки к module_src
set(LIBRARIES ${_libraries} PARENT_SCOPE)

cmake_minimum_required(VERSION 2.8.8)

project(cmake-ocaml-simple)

set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(FindOCaml)
find_package(OCaml REQUIRED)

if( OCAML_VERSION VERSION_LESS "4.00.0" )
  message(FATAL_ERROR "OCaml >=4.00.0 is required")
endif()

find_ocamlfind_package(PKG ctypes VERSION 0.3)
find_ocamlfind_package(PKG oUnit VERSION 2 OPTIONAL)

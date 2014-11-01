# CMake find_package() module for the OCaml language.
# Assumes ocamlfind will be used for compilation.
# http://ocaml.org/
#
# Example usage:
#
# find_package(OCaml)
#
# If successful, the following variables will be defined:
# OCAMLFIND
# OCAML_VERSION
# OCAML_STDLIB_PATH
#
# Also provides find_ocamlfind_package() macro.
#
# Example usage:
#
# find_ocamlfind_package(ctypes)
#
# In any case, the following variables are defined:
#
# OCAML_${pkg}_FOUND
#
# If successful, the following variables will be defined:
#
# OCAML_${pkg}_VERSION

include( FindPackageHandleStandardArgs )

find_program(OCAMLFIND
             NAMES ocamlfind)

if( OCAMLFIND )
    execute_process(
        COMMAND ${OCAMLFIND} ocamlc -version
        OUTPUT_VARIABLE OCAML_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(
        COMMAND ${OCAMLFIND} ocamlc -where
        OUTPUT_VARIABLE OCAML_STDLIB_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

find_package_handle_standard_args( OCaml DEFAULT_MSG
    OCAMLFIND
    OCAML_VERSION
    OCAML_STDLIB_PATH)

mark_as_advanced(
    OCAMLFIND)

macro(find_ocamlfind_package)
    CMAKE_PARSE_ARGUMENTS(find_ocamlfind_package "OPTIONAL" "PKG;VERSION" "" ${ARGN})

    execute_process(
        COMMAND "${OCAMLFIND}" "query" "${find_ocamlfind_package_PKG}" "-format" "%v"
        RESULT_VARIABLE find_ocamlfind_package_result
        OUTPUT_VARIABLE find_ocamlfind_package_version
        ERROR_VARIABLE find_ocamlfind_package_error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE)

    if( NOT ${find_ocamlfind_package_result} EQUAL 0 AND
        NOT ${find_ocamlfind_package_OPTIONAL} )
        message(FATAL_ERROR ${find_ocamlfind_package_error})
    endif()

    if( ${find_ocamlfind_package_result} EQUAL 0 )
        set(find_ocamlfind_package_found TRUE)
    else()
        set(find_ocamlfind_package_found FALSE)
    endif()

    if( ${find_ocamlfind_package_found} AND ${find_ocamlfind_package_VERSION} )
        if( ${find_ocamlfind_package_version} VERSION_LESS ${find_ocamlfind_package_VERSION} )
            message(FATAL_ERROR "ocamlfind package ${find_ocamlfind_package_PKG} should have version ${find_ocamlfind_package_VERSION} or newer")
        endif()
    endif()

    set(OCAML_${find_ocamlfind_package_PKG}_FOUND ${find_ocamlfind_package_found})

    set(OCAML_${find_ocamlfind_package_PKG}_VERSION ${find_ocamlfind_package_version})

endmacro()

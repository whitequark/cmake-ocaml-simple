# CMake build rules for the OCaml language.
# Assumes FindOCaml is used.
# http://ocaml.org/
#
# Example usage:
#
# add_ocaml_library(OCAML pkg_a)

function(add_ocaml_library name)
    CMAKE_PARSE_ARGUMENTS(ARG "" "" "OCAML;C;PKG" ${ARGN})

    set(src ${CMAKE_CURRENT_SOURCE_DIR})
    set(bin ${CMAKE_CURRENT_BINARY_DIR})

    set(sources)

    set(ocaml_inputs)

    set(ocaml_outputs "${bin}/${name}.cma")
    if( ARG_C )
        list(APPEND ocaml_outputs "${bin}/lib${name}.a" "${bin}/dll${name}.so")
    endif()
    if( HAVE_OCAMLOPT )
        list(APPEND ocaml_outputs "${bin}/${name}.cmxa" "${bin}/${name}.a")
    endif()

    set(ocaml_flags)
    foreach( ocaml_pkg ${ARG_PKG} )
        list(APPEND ocaml_flags "-package" "${ocaml_pkg}")
    endforeach()

    foreach( ocaml_file ${ARG_OCAML} )
        list(APPEND sources "${ocaml_file}.mli" "${ocaml_file}.ml")

        list(APPEND ocaml_inputs "${bin}/${ocaml_file}.mli" "${bin}/${ocaml_file}.ml")

        list(APPEND ocaml_outputs "${bin}/${ocaml_file}.cmi" "${bin}/${ocaml_file}.cmo")
        if( HAVE_OCAMLOPT )
            list(APPEND ocaml_outputs "${bin}/${ocaml_file}.cmx" "${bin}/${ocaml_file}.o")
        endif()
    endforeach()

    foreach( c_file ${ARG_C} )
        list(APPEND sources "${c_file}.c")

        list(APPEND c_inputs  "${bin}/${c_file}.c")
        list(APPEND c_outputs "${bin}/${c_file}.o")
    endforeach()

    foreach( source ${sources} )
        add_custom_command(
            OUTPUT "${bin}/${source}"
            COMMAND "${CMAKE_COMMAND}" "-E" "copy" "${CMAKE_CURRENT_SOURCE_DIR}/${source}"
                                                   "${bin}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${source}"
            COMMENT "Copying ${source} to build area")
    endforeach()

    foreach( c_input ${c_inputs} )
        get_filename_component(basename "${c_input}" NAME_WE)
        add_custom_command(
            OUTPUT "${basename}.o"
            COMMAND "${OCAMLFIND}" "ocamlc" "-c" "${c_input}"
            DEPENDS "${c_input}")
    endforeach()

    set(ocaml_params)
    foreach( ocaml_input ${ocaml_inputs} ${c_outputs})
        get_filename_component(basename "${ocaml_input}" NAME)
        list(APPEND ocaml_params "${basename}")
    endforeach()

    add_custom_command(
        OUTPUT ${ocaml_outputs}
        COMMAND "${OCAMLFIND}" "ocamlmklib" "-o" "${name}" ${ocaml_flags} ${ocaml_params}
        DEPENDS ${ocaml_inputs} ${c_outputs})

    add_custom_target(${name} ALL DEPENDS ${ocaml_outputs})
endfunction()

cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_VERBOSE_MAKEFILE on)

file(GLOB rnoh_pdf_view_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_pdf_view SHARED ${rnoh_pdf_view_SRC})
target_include_directories(rnoh_pdf_view PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(rnoh_pdf_view PUBLIC rnoh)


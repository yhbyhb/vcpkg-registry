vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
vcpkg_find_acquire_program(NUGET)

set(ENV{NUGET_PACKAGES} "${BUILDTREES_DIR}/nuget")

# see https://www.nuget.org/packages/Microsoft.ML.OnnxRuntime.DirectML/
set(PACKAGE_NAME    "Microsoft.ML.OnnxRuntime.DirectML")

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${PACKAGE_NAME}")
vcpkg_execute_required_process(
    COMMAND ${NUGET} install "${PACKAGE_NAME}" -Version "${VERSION}" -Verbosity detailed
                -OutputDirectory "${CURRENT_BUILDTREES_DIR}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    LOGNAME install-nuget
)

get_filename_component(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${PACKAGE_NAME}.${VERSION}" ABSOLUTE)
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(TRIPLE "win-x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(TRIPLE "win-x86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(TRIPLE "win-arm64")
    else()
        message(FATAL_ERROR "The architecture '${VCPKG_TARGET_ARCHITECTURE}' is not supported")
    endif()
else()
    message(FATAL_ERROR "The triplet '${TARGET_TRIPLET}' is not supported")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SOURCE_PATH}/runtimes/${TRIPLE}/native/onnxruntime.lib"        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/runtimes/${TRIPLE}/native/onnxruntime.dll"        DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/runtimes/${TRIPLE}/native/onnxruntime.lib"        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${SOURCE_PATH}/runtimes/${TRIPLE}/native/onnxruntime.dll"        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    message(FATAL_ERROR "The target platform is not supported")
endif()

file(INSTALL "${SOURCE_PATH}/build/native/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt"
             "${SOURCE_PATH}/README.md"
             "${SOURCE_PATH}/ThirdPartyNotices.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

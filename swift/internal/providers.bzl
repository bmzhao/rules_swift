# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Defines Skylark providers that propagated by the Swift BUILD rules."""

load(":utils.bzl", "collect_transitive")

SwiftBinaryInfo = provider(
    doc="Contains information about the compilation of a Swift binary target.",
    fields={
        "compile_options": """
`List` of `Args` objects. The command-line options that were passed to the
compiler to compile this target. This is intended to be flattened into a params
file by aspects to allow IDE integration with Bazel.
""",
    },
)

SwiftCcLibsInfo = provider(
    doc="""
Contains information about C libraries that are dependencies of Swift libraries,
excluding any that are embedded directly within the archive of a `swift_library`
(via the `cc_libs` attribute) to prevent double-linkage.

This provider is an internal implementation detail of the Swift BUILD rules; it
should not be used directly.
""",
    fields={
        "libraries": """
`Depset` of `File`s. The static libraries (`.a`) that should be linked into the
binary that depends on the target propagating this provider.
""",
    },
)

SwiftClangModuleInfo = provider(
    doc="""
Contains information about a Clang module with relative paths that needs to be
propagated up to other Swift compilation/link actions.
""",
    fields={
        "transitive_compile_flags": """
`Depset` of `string`s. The C compiler flags that should be passed to Clang when
depending on this target (for example, header search paths).
""",
        "transitive_defines": """
`Depset` of `string`s. The C preprocessor defines that should be passed to Clang
when depending on this target.
""",
        "transitive_headers": """
`Depset` of `File`s. The transitive header files that must be available to
compile actions when depending on this target.
""",
        "transitive_modulemaps": """
`Depset` of `File`s. The transitive module map files that will be passed to
Clang using the `-fmodule-map-file` option.
""",
    },
)

SwiftInfo = provider(
    doc="""
Contains information about the compiled artifacts of a Swift static library.
""",
    fields={
        "compile_options": """
`List` of `Args` objects. The command-line options that were passed to the
compiler to compile this target. This is intended to be flattened into a params
file by aspects to allow IDE integration with Bazel.
""",
        "direct_defines": """
`List` of `string`s. The values specified by the `defines` attribute of the
library that directly propagated this provider.
""",
        "direct_libraries": """
`List` of `File`s. The static libraries (`.a`) for the target that directly
propagated this provider.
""",
        "direct_linkopts": """
`List` of `string`s. Additional flags defined by this target that should be
passed to the linker when this library is linked into a binary.
""",
        "direct_swiftmodules": """
`List` of `File`s. The Swift modules (`.swiftmodule`) for the library that
directly propagated this provider.
""",
        "module_name": """
`String`. The name of the Swift module represented by the target that directly
propagated this provider.

This field will be equal to the explicitly assigned module name (if present);
otherwise, it will be equal to the autogenerated module name.
""",
        "swift_version": """
`String`. The version of the Swift language that was used when
compiling the propagating target; that is, the value passed via the
`-swift-version` compiler flag. This will be `None` if the flag was not set.
""",
        "transitive_additional_inputs": """
`Depset` of `File`s. The transitive additional inputs specified by the
`swiftc_inputs` attribute of library and binary targets. This allows files used
in `linkopts` location expansion in library targets to be propagated to the
eventual linker action that needs to use them, even when they are not present in
the same target.
""",
        "transitive_defines": """
`Depset` of `string`s. The transitive `defines` specified for the library that
propagated this provider and all of its dependencies.
""",
        "transitive_libraries": """
`Depset` of `File`s. The static libraries (`.a`) emitted by the target that
propagated this provider and all of its dependencies.
""",
        "transitive_linkopts": """
`Depset` of `string`s. The transitive `linkopts` specified for the library that
propagated this provider and all of its dependencies.
""",
        "transitive_swiftmodules": """
`Depset` of `File`s. The transitive Swift modules (`.swiftmodule`) emitted by
the library that propagated this provider and all of its dependencies.
""",
    },
)

SwiftProtoInfo = provider(
    doc="Propagates Swift-specific information about a `proto_library`.",
    fields={
        "module_mappings" : """
`Sequence` of `struct`s. Each struct contains `module_name` and
`proto_file_paths` fields that denote the transitive mappings from `.proto`
files to Swift modules. This allows messages that reference messages in other
libraries to import those modules in generated code.
""",
        "pbswift_files": """
`Depset` of `File`s. The transitive Swift source files (`.pb.swift`) generated
from the `.proto` files.
""",
    }
)

SwiftToolchainInfo = provider(
    doc="""
Propagates information about a Swift toolchain to compilation and linking rules
that use the toolchain.
""",
    fields={
        "action_environment": """
`Dict`. Environment variables that should be set during any actions spawned to
compile or link Swift code.
""",
        "cc_toolchain_info": """
`Struct`, defined as that returned by `swift_cc_toolchain_info`. Contains
information about the Bazel C++ toolchain that this Swift toolchain depends on,
if any.

This key may be `None` if the toolchain does not depend on a Bazel C++
toolchain (for example, an Xcode-based Swift toolchain).
""",
        "cpu": """
`String`. The CPU architecture that the toolchain is targeting.
""",
        "execution_requirements": """
`Dict`. Execution requirements that should be passed to any actions spawned to
compile or link Swift code.

For example, when using an Xcode toolchain, the execution requirements should be
such that running on Darwin is required.
""",
        "implicit_deps": """
`List` of `Target`s. Library targets that should be added as implicit
dependencies of any `swift_library`, `swift_binary`, or `swift_test` target.
""",
        "linker_opts": """
`List` of `string`s. Additional flags that should be passed to Clang when
linking a binary or test target using this toolchain.
""",
        "linker_search_paths": """
`List` of `string`s. Additional library search paths that should be passed to
the linker when linking binaries with this toolchain.
""",
        "object_format": """
`String`. The object file format of the platform that the toolchain is
targeting. The currently supported values are `"elf"` and `"macho"`.
""",
        "requires_autolink_extract": """
`Boolean`. `True` if the toolchain requires autolink-extract jobs to be invoked
to determine which imported libraries must be passed to the linker.
""",
        "requires_workspace_relative_module_maps": """
`Boolean`. `True` if the toolchain requires module map header paths to be
workspace-relative (because the toolchain passes `-fmodule-map-file-home-is-cwd`
to Swift's ClangImporter), or `False` if headers are to be read relative to the
location of the module map file.
""",
        "root_dir": """
`String`. The workspace-relative root directory of the toolchain.
""",
        "stamp": """
`Target`. A `cc`-providing target that should be linked into any binaries that
are built with stamping enabled.
""",
        "spawn_wrapper": """
`File`. An executable that is used to wrap invoked command lines for spawned
actions in the toolchain.
""",
        "supports_objc_interop": """
`Boolean`. Indicates whether or not the toolchain supports Objective-C interop.
""",
        "swiftc_copts": """
`List` of `strings`. Additional flags that should be passed to `swiftc` when
compiling libraries or binaries with this toolchain.
""",
        "system_name": """
`String`. The name of the operating system that the toolchain is targeting.
""",
    },
)

def merge_swift_clang_module_infos(targets):
  """Merges transitive `SwiftClangModuleInfo` providers.

  Args:
    targets: The targets whose `SwiftClangModuleInfo` providers should be
        merged.

  Returns:
    A new `SwiftClangModuleInfo` that contains the transitive closure of all the
    `SwiftClangModuleInfo` providers of the given targets.
  """
  return SwiftClangModuleInfo(
      transitive_compile_flags=collect_transitive(
          targets, SwiftClangModuleInfo, "transitive_compile_flags"),
      transitive_defines=collect_transitive(
          targets, SwiftClangModuleInfo, "transitive_defines"),
      transitive_headers=collect_transitive(
          targets, SwiftClangModuleInfo, "transitive_headers"),
      transitive_modulemaps=collect_transitive(
          targets, SwiftClangModuleInfo, "transitive_modulemaps"),
  )


def swift_cc_toolchain_info(all_files, provider):
  """Creates a value suitable for the `cc_toolchain_info` of a Swift toolchain.

  Args:
    all_files: The full set of toolchain files that includes, for example, the
        tools referenced by the provider's `ar_executable` and
        `compiler_executable` keys.
    provider: The `cc_common.CcToolchainInfo` provider propagated by the Bazel
        C++ toolchain associated with this Swift toolchain.

  Returns:
    A `struct` containing the arguments of this function as its fields.
  """
  return struct(
      all_files=all_files,
      provider=provider,
  )
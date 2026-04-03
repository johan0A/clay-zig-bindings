const std = @import("std");
const B = std.Build;

pub fn build(b: *B) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const preferred_linkage = b.option(
        std.builtin.LinkMode,
        "preferred_linkage",
        "Prefer building statically or dynamically linked libraries (default: static)",
    ) orelse .static;

    const root_module = b.addModule("zclay", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    {
        const clay_dep = b.dependency("clay", .{});

        const clay_lib_mod = b.createModule(.{
            .target = target,
            .optimize = optimize,
        });
        clay_lib_mod.addIncludePath(clay_dep.path(""));
        clay_lib_mod.addCSourceFile(.{
            .file = b.addWriteFiles().add("clay.c",
                \\#define CLAY_IMPLEMENTATION
                \\#include<clay.h>
            ),
            .flags = &.{"-ffreestanding"},
        });

        const clay_lib = b.addLibrary(.{
            .name = "clay",
            .linkage = preferred_linkage,
            .root_module = clay_lib_mod,
        });

        root_module.linkLibrary(clay_lib);
    }

    {
        const exe_unit_tests = b.addTest(.{ .root_module = root_module });
        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_exe_unit_tests.step);
    }

    {
        const tests_check = b.addTest(.{ .root_module = root_module });
        const check = b.step("check", "Check if tests compile");
        check.dependOn(&tests_check.step);
    }
}

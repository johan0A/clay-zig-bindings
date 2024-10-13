const std = @import("std");
const B = std.Build;

pub fn build(b: *B) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const clay_lib = blk: {
        const clay_lib = b.addStaticLibrary(.{
            .name = "clay",
            .target = target,
            .optimize = optimize,
        });

        const clay_dep = b.dependency("clay", .{});
        clay_lib.addIncludePath(clay_dep.path(""));
        clay_lib.addCSourceFile(.{
            .file = b.addWriteFiles().add("clay.c",
                \\#define CLAY_IMPLEMENTATION
                \\#include<clay.h>
            ),
        });

        break :blk clay_lib;
    };

    {
        const module = b.addModule("zclay", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        module.linkLibrary(clay_lib);
    }

    {
        const exe_unit_tests = b.addTest(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        exe_unit_tests.linkLibrary(clay_lib);

        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_exe_unit_tests.step);
    }

    {
        const tests_check = b.addTest(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });

        tests_check.linkLibrary(clay_lib);

        const check = b.step("check", "Check if tests compile");
        check.dependOn(&tests_check.step);
    }
}

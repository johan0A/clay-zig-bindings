const std = @import("std");
const B = std.Build;

pub fn build(b: *B) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.addModule("zclay", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    {
        const clay = b.createModule(.{ .target = target, .optimize = optimize });

        const clay_dep = b.dependency("clay", .{});
        clay.addIncludePath(clay_dep.path(""));
        clay.addCSourceFile(.{
            .file = b.addWriteFiles().add("clay.c",
                \\#define CLAY_IMPLEMENTATION
                \\#include<clay.h>
            ),
            .flags = &.{"-ffreestanding"},
        });

        const clay_lib = b.addLibrary(.{
            .name = "clay",
            .linkage = .static,
            .root_module = clay,
        });
        root_module.linkLibrary(clay_lib);
    }

    // The user provides the "raylib" import so that the renderer shares their raylib types and library
    _ = b.addModule("renderer_raylib", .{
        .root_source_file = b.path("src/renderers/raylib.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "zclay", .module = root_module }},
    });

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

const std = @import("std");
const B = std.Build;
const rl = @import("raylib");

pub fn build(b: *B) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });
    root_module.addImport("raylib", raylib_dep.module("raylib"));
    root_module.linkLibrary(raylib_dep.artifact("raylib"));

    const zclay_dep = b.dependency("zclay", .{
        .target = target,
        .optimize = optimize,
        .renderer = .raylib,
    });

    zclay_dep.module("zclay").addImport("raylib", raylib_dep.module("raylib"));
    root_module.addImport("zclay", zclay_dep.module("zclay"));

    {
        const exe = b.addExecutable(.{ .name = "zclay-example", .root_module = root_module });

        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| run_cmd.addArgs(args);

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const exe_unit_tests = b.addTest(.{ .root_module = root_module });

        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_exe_unit_tests.step);
    }

    {
        const exe_check = b.addExecutable(.{ .name = "check", .root_module = root_module });
        const tests_check = b.addTest(.{ .name = "check", .root_module = root_module });

        const check = b.step("check", "Check if exe and tests compile");
        check.dependOn(&exe_check.step);
        check.dependOn(&tests_check.step);
    }
}

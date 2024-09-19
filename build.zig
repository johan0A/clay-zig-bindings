const std = @import("std");
const B = std.Build;

pub fn build(b: *B) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        _ = b.addModule("zig-package-template", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        });
    }

    {
        const exe_unit_tests = b.addTest(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        });

        const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_exe_unit_tests.step);
    }

    {
        const tests_check = b.addTest(.{
            .name = "check",
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        });

        const check = b.step("check", "Check if tests compile");
        check.dependOn(&tests_check.step);
    }
}

fn addDependencies(
    compile_step: *B.Step.Compile,
    b: *B,
    target: B.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    _ = compile_step;
    _ = b;
    _ = target;
    _ = optimize;
}

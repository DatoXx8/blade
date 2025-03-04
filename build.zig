const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "blade",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const simulation_test_move = b.addExecutable(.{
        .name = "test-move",
        .root_source_file = b.path("src/test-move.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(simulation_test_move);
    const test_move = b.addRunArtifact(simulation_test_move);
    test_move.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        test_move.addArgs(args);
    }
    const test_move_step = b.step("test-move", "Run the simulator for move ops");
    test_move_step.dependOn(&test_move.step);

    const simulation_test_uci = b.addExecutable(.{
        .name = "test-uci",
        .root_source_file = b.path("src/test-uci.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(simulation_test_uci);
    const test_uci = b.addRunArtifact(simulation_test_uci);
    test_uci.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        test_uci.addArgs(args);
    }
    const test_uci_step = b.step("test-uci", "Run the simulator for uci encoding and decoding");
    test_uci_step.dependOn(&test_uci.step);
}

const std = @import("std");

fn CLOSE(_: void) void {
    std.debug.print("CLOSE\n", .{});
}

inline fn UI() fn (void) void {
    std.debug.print("OPEN\n", .{});
    return CLOSE;
}

pub fn main() !void {
    UI()({
        std.debug.print("INSIDE\n", .{});
    });
}

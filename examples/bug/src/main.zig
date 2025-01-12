const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const FONT_ID_BODY_30 = 6;

const COLOR_LIGHT = cl.Color{ 244, 235, 230, 255 };
const COLOR_LIGHT_HOVER = cl.Color{ 224, 215, 210, 255 };
const COLOR_BUTTON_HOVER = cl.Color{ 238, 227, 225, 255 };
const COLOR_BROWN = cl.Color{ 61, 26, 5, 255 };
const COLOR_RED = cl.Color{ 168, 66, 28, 255 };
const COLOR_RED_HOVER = cl.Color{ 148, 46, 8, 255 };
const COLOR_ORANGE = cl.Color{ 225, 138, 50, 255 };
const COLOR_BLUE = cl.Color{ 111, 173, 162, 255 };
const COLOR_TEAL = cl.Color{ 111, 173, 162, 255 };
const COLOR_BLUE_DARK = cl.Color{ 2, 32, 82, 255 };
const COLOR_ZIG_LOGO = cl.Color{ 247, 164, 29, 255 };

// Colors for top stripe
const COLORS_TOP_BORDER = [_]cl.Color{
    .{ 240, 213, 137, 255 },
    .{ 236, 189, 80, 255 },
    .{ 225, 138, 50, 255 },
    .{ 223, 110, 44, 255 },
    .{ 168, 66, 28, 255 },
};

const border_data = cl.BorderData{ .width = 2, .color = COLOR_RED };

var window_height: isize = 0;
var window_width: isize = 0;

fn LandingPageBlob_(index: u32, font_size: u16, font_id: u16, color: cl.Color, max_width: f32, text: []const u8) void {
    // std.debug.print("\nBLOB START\n", .{});
    if (cl.OPEN(&.{
        .IDI("HeroBlob", index),
        .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = max_width }) }, .padding = .all(16), .child_gap = 16, .child_alignment = .{ .y = .CENTER } }),
        .border(.outside(color, 2, 0)),
    })) {
        defer cl.CLOSE();
        cl.text(text, cl.Config.text(.{ .font_size = font_size, .font_id = font_id, .color = color }));
    }
    // std.debug.print("BLOB END\n\n", .{});
}

fn LandingPageBlob(index: u32, font_size: u16, font_id: u16, color: cl.Color, max_width: f32, text: []const u8) void {
    // std.debug.print("\nBLOB START\n", .{});
    cl.UI(&.{
        .IDI("HeroBlob", index),
        .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = max_width }) }, .padding = .all(16), .child_gap = 16, .child_alignment = .{ .y = .CENTER } }),
        .border(.outside(color, 2, 0)),
    })({
        cl.text(text, cl.Config.text(.{ .font_size = font_size, .font_id = font_id, .color = color }));
    });
    // std.debug.print("BLOB END\n\n", .{});
}

fn createLayout() cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();
    // cl.UI(&.{
    //     .ID("ScrollContainerBackgroundRectangle"),
    //     .scroll(.{ .vertical = true }),
    //     .layout(.{ .sizing = .grow, .direction = .TOP_TO_BOTTOM, .child_gap = 10 }),
    //     .rectangle(.{ .color = COLOR_LIGHT }),
    // })({
    //     LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_ZIG_LOGO, 510, "The official Clay website recreated with zclay: clay-zig-bindings");
    //     @call(.always_inline, LandingPageBlob, .{ 2, 30, FONT_ID_BODY_30, COLOR_ZIG_LOGO, 510, "The official Clay website recreated with zclay: clay-zig-bindings" });
    // });

    if (cl.OPEN(&.{
        .ID("ScrollContainerBackgroundRectangle"),
        .scroll(.{ .vertical = true }),
        .layout(.{ .sizing = .grow, .direction = .TOP_TO_BOTTOM, .child_gap = 10 }),
        .rectangle(.{ .color = COLOR_LIGHT }),
    })) {
        defer cl.CLOSE();
        // LandingPageBlob_(1, 30, FONT_ID_BODY_30, COLOR_ZIG_LOGO, 510, "The official Clay website recreated with zclay: clay-zig-bindings");
        // std.debug.print("\n==\n\n", .{});
        @call(.always_inline, LandingPageBlob_, .{ 2, 30, FONT_ID_BODY_30, COLOR_ZIG_LOGO, 510, "The official Clay website recreated with zclay: clay-zig-bindings" });
    }

    return cl.endLayout();
}

fn loadFont(file_data: ?[]const u8, font_id: u16, font_size: i32) void {
    renderer.raylib_fonts[font_id] = rl.loadFontFromMemory(".ttf", file_data, font_size * 2, null);
    rl.setTextureFilter(renderer.raylib_fonts[font_id].?.texture, .bilinear);
}

fn loadImage(comptime path: [:0]const u8) rl.Texture2D {
    const texture = rl.loadTextureFromImage(rl.loadImageFromMemory(@ptrCast(std.fs.path.extension(path)), @embedFile(path)));
    rl.setTextureFilter(texture, .bilinear);
    return texture;
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    // init clay
    const min_memory_size: u32 = cl.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);
    const arena: cl.Arena = cl.createArenaWithCapacityAndMemory(min_memory_size, @ptrCast(memory));
    cl.initialize(arena, .{ .h = 1000, .w = 1000 });
    cl.setMeasureTextFunction(renderer.measureText);

    // init raylib
    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
        .window_resizable = true,
    });
    rl.initWindow(1000, 1000, "Raylib zig Example");
    rl.setWindowMinSize(300, 100);
    rl.setTargetFPS(60);

    // load assets
    loadFont(@embedFile("resources/Quicksand-Semibold.ttf"), FONT_ID_BODY_30, 30);

    var debug_mode_enabled = false;
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.d)) {
            debug_mode_enabled = !debug_mode_enabled;
            cl.setDebugModeEnabled(debug_mode_enabled);
        }

        window_width = rl.getScreenWidth();
        window_height = rl.getScreenHeight();

        const mouse_pos = rl.getMousePosition();
        cl.setPointerState(.{
            .x = mouse_pos.x,
            .y = mouse_pos.y,
        }, rl.isMouseButtonDown(.left));

        const scroll_delta = rl.getMouseWheelMoveV().multiply(.{ .x = 6, .y = 6 });
        cl.updateScrollContainers(
            false,
            .{ .x = scroll_delta.x, .y = scroll_delta.y },
            rl.getFrameTime(),
        );

        cl.setLayoutDimensions(.{
            .w = @floatFromInt(window_width),
            .h = @floatFromInt(window_height),
        });
        var render_commands = createLayout();

        rl.beginDrawing();
        renderer.clayRaylibRender(&render_commands, allocator);
        rl.endDrawing();
        // @panic("");
    }
}

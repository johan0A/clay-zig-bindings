const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };
const white: cl.Color = .{ 250, 250, 255, 255 };

const sidebar_item_layout: cl.LayoutConfig = .{ .sizing = .{ .w = .grow, .h = .fixed(50) } };

// Re-useable components are just normal functions
fn sidebarItemComponent(index: usize) void {
    cl.UI(&.{
        .IDI("SidebarBlob", @intCast(index)),
        .layout(sidebar_item_layout),
        .rectangle(.{ .color = orange }),
    })({});
}

// An example function to begin the "root" of your layout tree
fn createLayout(profile_picture: *const rl.Texture2D) cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();
    cl.UI(&.{
        .ID("OuterContainer"),
        .layout(.{ .direction = .LEFT_TO_RIGHT, .sizing = .grow, .padding = .all(16), .child_gap = 16 }),
        .rectangle(.{ .color = white }),
    })({
        cl.UI(&.{
            .ID("SideBar"),
            .layout(.{
                .direction = .TOP_TO_BOTTOM,
                .sizing = .{ .h = .grow, .w = .fixed(300) },
                .padding = .all(16),
                .child_alignment = .{ .x = .CENTER, .y = .TOP },
                .child_gap = 16,
            }),
            .rectangle(.{ .color = light_grey }),
        })({
            cl.UI(&.{
                .ID("ProfilePictureOuter"),
                .layout(.{ .sizing = .{ .w = .grow }, .padding = .all(16), .child_alignment = .{ .x = .LEFT, .y = .CENTER }, .child_gap = 16 }),
                .rectangle(.{ .color = red }),
            })({
                cl.UI(&.{
                    .ID("ProfilePicture"),
                    .layout(.{ .sizing = .{ .h = .fixed(60), .w = .fixed(60) } }),
                    .image(.{ .source_dimensions = .{ .h = 60, .w = 60 }, .image_data = @ptrCast(profile_picture) }),
                })({});
                cl.text("Clay - UI Library", .text(.{ .font_size = 24, .color = light_grey }));
            });

            for (0..5) |i| sidebarItemComponent(i);
        });

        cl.UI(&.{
            .ID("MainContent"),
            .layout(.{ .sizing = .grow }),
            .rectangle(.{ .color = light_grey }),
        })({
            //...
        });
    });
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
    const arena: cl.Arena = cl.createArenaWithCapacityAndMemory(memory);
    _ = cl.initialize(arena, .{ .h = 1000, .w = 1000 }, .{});
    cl.setMeasureTextFunction(renderer.measureText);

    // init raylib
    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
        .window_resizable = true,
    });
    rl.initWindow(1000, 1000, "Raylib zig Example");
    rl.setWindowMinSize(300, 100);
    rl.setTargetFPS(120);

    // load assets
    loadFont(@embedFile("./resources/Roboto-Regular.ttf"), 0, 24);
    const profile_picture = loadImage("./resources/profile-picture.png");

    var debug_mode_enabled = false;
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.d)) {
            debug_mode_enabled = !debug_mode_enabled;
            cl.setDebugModeEnabled(debug_mode_enabled);
        }

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
            .w = @floatFromInt(rl.getScreenWidth()),
            .h = @floatFromInt(rl.getScreenHeight()),
        });
        var render_commands = createLayout(&profile_picture);

        rl.beginDrawing();
        renderer.clayRaylibRender(&render_commands, allocator);
        rl.endDrawing();
    }
}

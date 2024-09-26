const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };

const sidebar_item_layout: cl.LayoutConfig = .{
    .size = .{
        .w = cl.sizingGrow(.{}),
        .h = cl.sizingFixed(50),
    },
};

var side_bar_handle: struct {
    position: f32,
    dragging: bool,
    start_drag_pos: f32,
    start_drag_mouse_pos: f32,

    fn tick(self: *@This()) void {
        const mouse_pos = rl.getMousePosition();
        if (!rl.isMouseButtonDown(.mouse_button_left))
            self.dragging = false;

        if (self.dragging == true) {
            if (!rl.isMouseButtonDown(.mouse_button_left))
                self.dragging = false;
            self.position = self.start_drag_pos + mouse_pos.x - self.start_drag_mouse_pos;
            self.position = @min(@as(f32, @floatFromInt(rl.getScreenWidth() - 100)), @max(270, self.position));
        } else {
            if (rl.isMouseButtonPressed(.mouse_button_left) and cl.pointerOver(cl.ID("ResizeHandle"))) {
                self.dragging = true;
                self.start_drag_mouse_pos = mouse_pos.x;
                self.start_drag_pos = self.position;
            }
        }
        if (cl.pointerOver(cl.ID("ResizeHandle")) or self.dragging) {
            rl.setMouseCursor(.mouse_cursor_pointing_hand);
        } else {
            rl.setMouseCursor(.mouse_cursor_arrow);
        }
    }
} = .{
    .position = 300,
    .dragging = false,
    .start_drag_pos = 0,
    .start_drag_mouse_pos = 0,
};

fn sidebarItemCompoment(index: usize) void {
    cl.rectangle(cl.IDI("SidebarBlob", @intCast(index)), cl.layout(sidebar_item_layout), cl.rectangleConfig(.{ .color = orange }));
    defer cl.closeParent();
}

fn createLayout(profile_picture: *const rl.Texture2D) cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();
    {
        cl.rectangle(
            cl.ID("OuterContainer"),
            cl.layout(.{ .direction = .LEFT_TO_RIGHT, .size = .{ .h = cl.sizingGrow(.{}), .w = cl.sizingGrow(.{}) }, .padding = .{ .x = 16, .y = 16 } }),
            cl.rectangleConfig(.{ .color = .{ 250, 250, 255, 255 } }),
        );
        defer cl.closeParent();

        {
            cl.rectangle(
                cl.ID("SideBar"),
                cl.layout(.{
                    .direction = .TOP_TO_BOTTOM,
                    .size = .{ .h = cl.sizingGrow(.{}), .w = cl.sizingFixed(side_bar_handle.position) },
                    .padding = .{ .x = 16, .y = 16 },
                    .alignment = .{ .x = .CENTER, .y = .TOP },
                    .gap = 16,
                }),
                cl.rectangleConfig(.{ .color = light_grey }),
            );
            defer cl.closeParent();

            {
                cl.rectangle(
                    cl.ID("ProfilePictureOuter"),
                    cl.layout(.{ .size = .{ .w = cl.sizingGrow(.{}) }, .padding = .{ .x = 16, .y = 16 }, .alignment = .{ .y = .CENTER }, .gap = 16 }),
                    cl.rectangleConfig(.{ .color = red }),
                );
                defer cl.closeParent();

                cl.image(
                    cl.ID("ProfilePicture"),
                    cl.layout(.{ .size = .{ .h = cl.sizingFixed(60), .w = cl.sizingFixed(60) } }),
                    cl.imageConfig(.{ .source_dimensions = .{ .h = 60, .w = 60 }, .image_data = @ptrCast(@constCast(profile_picture)) }),
                );
                cl.closeParent();
                cl.text(cl.ID("profileTitle"), "Clay - UI Library", cl.textConfig(.{ .font_size = 24, .text_color = light_grey }));
            }

            for (0..5) |i| {
                sidebarItemCompoment(i);
            }
        }
        {
            cl.rectangle(
                cl.ID("ResizeHandle"),
                cl.layout(.{ .padding = .{ .x = 7, .y = 7 }, .size = .{ .h = cl.sizingGrow(.{}), .w = cl.sizingFit(.{}) } }),
                cl.rectangleConfig(.{ .color = .{ 0, 0, 0, 0 } }),
            );
            defer cl.closeParent();
            cl.rectangle(cl.ID("ResizeHandleInner"), cl.layout(.{ .size = .{ .h = cl.sizingGrow(.{}), .w = cl.sizingFixed(2) } }), cl.rectangleConfig(.{ .color = red }));
            defer cl.closeParent();
        }
        {
            cl.rectangle(
                cl.ID("MainContent"),
                cl.layout(.{ .size = .{ .h = cl.sizingGrow(.{}), .w = cl.sizingGrow(.{}) } }),
                cl.rectangleConfig(.{ .color = light_grey }),
            );
            defer cl.closeParent();
        }
    }
    return cl.endLayout();
}

fn loadFont(file_data: ?[]const u8, font_id: u16, font_size: i32) void {
    renderer.raylib_fonts[font_id] = rl.loadFontFromMemory(".ttf", file_data, font_size * 2, null);
    rl.setTextureFilter(renderer.raylib_fonts[font_id].?.texture, .texture_filter_bilinear);
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    const min_memory_size: u32 = cl.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);
    const arena: cl.Arena = cl.createArenaWithCapacityAndMemory(min_memory_size, @ptrCast(memory));

    cl.initialize(arena, .{ .h = 1000, .w = 1000 });
    cl.setMeasureTextFunction(renderer.measureText);

    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
        .vsync_hint = true,
        .window_highdpi = true,
        .window_resizable = true,
    });
    rl.initWindow(1000, 1000, "Raylib zig Example");
    rl.setTargetFPS(60);

    loadFont(@embedFile("./resources/Roboto-Regular.ttf"), 0, 100);
    const profile_picture = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("./resources/profile-picture.png")));

    var debug_mode_enabled = false;

    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.key_d)) {
            debug_mode_enabled = !debug_mode_enabled;
            cl.setDebugModeEnabled(debug_mode_enabled);
        }

        const mouse_pos = rl.getMousePosition();
        cl.setPointerState(.{
            .x = mouse_pos.x,
            .y = mouse_pos.y,
        }, rl.isMouseButtonDown(.mouse_button_left));

        cl.setLayoutDimensions(.{
            .w = @floatFromInt(rl.getScreenWidth()),
            .h = @floatFromInt(rl.getScreenHeight()),
        });
        var render_commands = createLayout(&profile_picture);

        rl.beginDrawing();
        renderer.clayRaylibRender(&render_commands, allocator);
        rl.endDrawing();

        side_bar_handle.tick();
    }
}

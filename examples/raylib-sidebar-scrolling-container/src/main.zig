const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };

const sidebarItemLayout: cl.LayoutConfig = .{
    .sizing = .{
        .width = cl.sizingGrow(.{}),
        .height = cl.sizingFixed(50),
    },
};

fn sidebarItemCompoment(index: usize) void {
    cl.rectangle(cl.IDI("SidebarBlob", @intCast(index)), cl.layout(sidebarItemLayout), cl.rectangleConfig(.{ .color = orange }));
    defer cl.closeParent();
}

fn createLayout(profile_picture: *const rl.Texture2D) cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();
    {
        cl.rectangle(
            cl.ID("OuterContainer"),
            cl.layout(.{
                .layoutDirection = .LEFT_TO_RIGHT,
                .sizing = .{ .height = cl.sizingGrow(.{}), .width = cl.sizingGrow(.{}) },
                .padding = .{ .x = 16, .y = 16 },
                .childGap = 16,
            }),
            cl.rectangleConfig(.{ .color = .{ 250, 250, 255, 255 } }),
        );
        defer cl.closeParent();

        {
            cl.rectangle(
                cl.ID("SideBar"),
                cl.layout(.{
                    .layoutDirection = .TOP_TO_BOTTOM,
                    .sizing = .{ .height = cl.sizingGrow(.{}), .width = cl.sizingFixed(300) },
                    .padding = .{ .x = 16, .y = 16 },
                    .childAlignment = .{ .x = .CENTER, .y = .TOP },
                    .childGap = 16,
                }),
                cl.rectangleConfig(.{ .color = light_grey }),
            );
            defer cl.closeParent();

            {
                cl.rectangle(
                    cl.ID("ProfilePictureOuter"),
                    cl.layout(.{
                        .sizing = .{ .width = cl.sizingGrow(.{}) },
                        .padding = .{ .x = 16, .y = 16 },
                        .childAlignment = .{ .y = .CENTER },
                        .childGap = 16,
                    }),
                    cl.rectangleConfig(.{ .color = red }),
                );
                defer cl.closeParent();

                cl.image(
                    cl.ID("ProfilePicture"),
                    cl.layout(.{ .sizing = .{ .height = cl.sizingFixed(60), .width = cl.sizingFixed(60) } }),
                    cl.imageConfig(.{ .sourceDimensions = .{ .height = 60, .width = 60 }, .imageData = @ptrCast(@constCast(profile_picture)) }),
                );
                cl.closeParent();
                cl.text(cl.ID("profileTitle"), "Clay - UI Library", cl.textConfig(.{ .fontSize = 24, .textColor = light_grey }));
            }

            for (0..5) |i| {
                sidebarItemCompoment(i);
            }
        }
        {
            cl.rectangle(
                cl.ID("MainContent"),
                cl.layout(.{ .sizing = .{ .height = cl.sizingGrow(.{}), .width = cl.sizingGrow(.{}) } }),
                cl.rectangleConfig(.{ .color = light_grey }),
            );
            defer cl.closeParent();
        }
    }
    return cl.endLayout();
}

fn loadFont(file_data: ?[]const u8, fontId: u16, fontSize: i32) void {
    renderer.raylib_fonts[fontId] = rl.loadFontFromMemory(".ttf", file_data, fontSize * 2, null);
    rl.setTextureFilter(renderer.raylib_fonts[fontId].?.texture, .texture_filter_bilinear);
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;

    const min_memory_size: u32 = cl.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);
    const arena: cl.Arena = cl.createArenaWithCapacityAndMemory(min_memory_size, @ptrCast(memory));

    cl.initialize(arena, .{ .height = 1000, .width = 1000 });
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
            .width = @floatFromInt(rl.getScreenWidth()),
            .height = @floatFromInt(rl.getScreenHeight()),
        });
        var renderCommands = createLayout(&profile_picture);

        rl.beginDrawing();
        renderer.clayRaylibRender(&renderCommands, allocator);
        rl.endDrawing();
    }
}

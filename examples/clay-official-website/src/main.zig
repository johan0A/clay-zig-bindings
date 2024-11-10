const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

var syntaxImage: rl.Texture2D = undefined;
var checkImage1: rl.Texture2D = undefined;
var checkImage2: rl.Texture2D = undefined;
var checkImage3: rl.Texture2D = undefined;
var checkImage4: rl.Texture2D = undefined;
var checkImage5: rl.Texture2D = undefined;

const FONT_ID_BODY_16 = 0;
const FONT_ID_TITLE_56 = 9;
const FONT_ID_TITLE_52 = 1;
const FONT_ID_TITLE_48 = 2;
const FONT_ID_TITLE_36 = 3;
const FONT_ID_TITLE_32 = 4;
const FONT_ID_BODY_36 = 5;
const FONT_ID_BODY_30 = 6;
const FONT_ID_BODY_28 = 7;
const FONT_ID_BODY_24 = 8;

const COLOR_LIGHT = cl.Color{ 244, 235, 230, 255 };
const COLOR_LIGHT_HOVER = cl.Color{ 224, 215, 210, 255 };
const COLOR_BUTTON_HOVER = cl.Color{ 238, 227, 225, 255 };
const COLOR_BROWN = cl.Color{ 61, 26, 5, 255 };
//COLOR_R= :: cl.Color {252, 67, 27, 255};
const COLOR_RED = cl.Color{ 168, 66, 28, 255 };
const COLOR_RED_HOVER = cl.Color{ 148, 46, 8, 255 };
const COLOR_ORANGE = cl.Color{ 225, 138, 50, 255 };
const COLOR_BLUE = cl.Color{ 111, 173, 162, 255 };
const COLOR_TEAL = cl.Color{ 111, 173, 162, 255 };
const COLOR_BLUE_DARK = cl.Color{ 2, 32, 82, 255 };

// Colors for top stripe
const COLORS_TOP_BORDER = [_]cl.Color{
    .{ 240, 213, 137, 255 },
    .{ 236, 189, 80, 255 },
    .{ 225, 138, 50, 255 },
    .{ 223, 110, 44, 255 },
    .{ 168, 66, 28, 255 },
};

const COLOR_BLOB_BORDER_1 = cl.Color{ 168, 66, 28, 255 };
const COLOR_BLOB_BORDER_2 = cl.Color{ 203, 100, 44, 255 };
const COLOR_BLOB_BORDER_3 = cl.Color{ 225, 138, 50, 255 };
const COLOR_BLOB_BORDER_4 = cl.Color{ 236, 159, 70, 255 };
const COLOR_BLOB_BORDER_5 = cl.Color{ 240, 189, 100, 255 };

const border_data = cl.BorderData{ .width = 2, .color = COLOR_RED };

var window_height: isize = 0;
var window_width: isize = 0;

fn LandingPageBlob(index: u32, fontSize: u16, fontId: u16, color: cl.Color, text: []const u8, image: *rl.Texture2D) void {
    cl.UI(&.{
        .IDI("HeroBlob", index),
        .layout(.{ .size = .{ .w = .fGrow(.{ .max = 480 }) }, .padding = .uniform(16), .gap = 16, .alignment = .{ .y = .CENTER } }),
        .border(.outside(color, 2, 10)),
    });
    {
        defer cl.CLOSE();
        cl.UI(&.{
            .IDI("CheckImage", index),
            .layout(.{ .size = .{ .w = .fixed(32) } }),
            .image(.{ .image_data = image, .source_dimensions = .{ .w = 128, .h = 128 } }),
        });
        cl.CLOSE();
        cl.text(text, cl.Config.text(.{ .font_size = fontSize, .font_id = fontId, .color = color }));
    }
}

fn landingPageDesktop() void {
    cl.UI(&.{
        .ID("LandingPage1Desktop"),
        .layout(.{
            .size = .{ .w = .grow, .h = .fFit(.{ .min = @floatFromInt(window_height - 70) }) },
            .alignment = .{ .y = .CENTER },
            .padding = .{ .x = 50 },
            .gap = 16,
        }),
    });
    {
        defer cl.CLOSE();
        cl.UI(&.{
            .ID("LandingPage1"),
            .layout(.{ .size = .grow, .alignment = .{ .y = .CENTER }, .padding = .uniform(32), .gap = 32 }),
            .border(.{ .left = border_data, .right = border_data }),
        });
        {
            defer cl.CLOSE();
            cl.UI(&.{
                .ID("LeftText"),
                .layout(.{ .size = .{ .w = .percent(0.55) }, .direction = .TOP_TO_BOTTOM, .gap = 8 }),
            });
            {
                defer cl.CLOSE();
                cl.text(
                    "Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
                    cl.Config.text(.{ .font_size = 56, .font_id = FONT_ID_TITLE_56, .color = COLOR_RED }),
                );
                cl.UI(&.{ .ID("Spacer"), .layout(.{ .size = .{ .w = .grow, .h = .fixed(32) } }) });
                cl.CLOSE();
                cl.text(
                    "Clay is laying out this webpage right now!",
                    cl.Config.text(.{ .font_size = 36, .font_id = FONT_ID_BODY_36, .color = COLOR_ORANGE }),
                );
            }

            cl.UI(&.{
                .ID("HeroImageOuter"),
                .layout(.{ .size = .{ .w = .percent(0.45) }, .direction = .TOP_TO_BOTTOM, .alignment = .{ .x = .CENTER }, .gap = 16 }),
            });
            {
                defer cl.CLOSE();
                LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_5, "High performance", &checkImage5);
                LandingPageBlob(2, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", &checkImage4);
                LandingPageBlob(3, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_3, "Declarative syntax", &checkImage3);
                LandingPageBlob(4, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_2, "Single .h file for C/C++", &checkImage2);
                LandingPageBlob(5, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", &checkImage1);
            }
        }
    }
}

const ScrollbarData = struct {
    clickOrigin: cl.Vector2,
    positionOrigin: cl.Vector2,
    mouseDown: bool,
};

const scrollbarData = ScrollbarData{};
const animationLerpValue: f32 = -1.0;

fn createLayout(lerpValue: f32) cl.ClayArray(cl.RenderCommand) {
    _ = lerpValue; // autofix
    const mobileScreen = window_width < 750;
    cl.beginLayout();

    cl.UI(&.{
        .ID("OuterContainer"),
        .layout(.{ .size = .grow, .direction = .TOP_TO_BOTTOM }),
        .rectangle(.{ .color = COLOR_LIGHT }),
    });
    {
        defer cl.CLOSE();
        cl.UI(&.{
            .ID("Header"),
            .layout(.{
                .size = .{ .h = .fixed(50), .w = .grow },
                .alignment = .{ .y = .CENTER },
                .padding = .{ .x = 32 },
                .gap = 24,
            }),
        });
        {
            defer cl.CLOSE();
            cl.text("Clay", cl.Config.text(.{
                .font_id = FONT_ID_BODY_24,
                .font_size = 24,
                .color = .{ 61, 26, 5, 255 },
            }));
            cl.UI(&.{ .ID("LinkExamplesOuter"), .layout(.{ .size = .{ .w = .grow } }) });
            cl.CLOSE();

            if (!mobileScreen) {
                cl.UI(&.{ .ID("LinkExamplesOuter"), .layout(.{}), .rectangle(.{ .color = .{ 0, 0, 0, 0 } }) });
                {
                    defer cl.CLOSE();
                    cl.text("Examples", cl.Config.text(.{ .font_id = FONT_ID_BODY_24, .font_size = 24, .color = .{ 61, 26, 5, 255 } }));
                }
                cl.UI(&.{ .ID("LinkDocsOuter"), .layout(.{}), .rectangle(.{ .color = .{ 0, 0, 0, 0 } }) });
                {
                    defer cl.CLOSE();
                    cl.text("Docs", cl.Config.text(.{ .font_id = FONT_ID_BODY_24, .font_size = 24, .color = .{ 61, 26, 5, 255 } }));
                }
            }

            // clay.Rectangle({cornerRadius = clay.CornerRadiusAll(10), color = clay.PointerOver(clay.GetElementId(clay.MakeString("LinkGithubOuter"))) ? COLOR_LIGHT_HOVER : COLOR_LIGHT})
            cl.UI(&.{
                .ID("LinkGithubOuter"),
                .layout(.{ .padding = .{ .x = 32, .y = 6 } }),
                .border(.outside(COLOR_RED, 2, 10)),
                .rectangle(.{
                    .corner_radius = .all(10),
                    .color = if (cl.pointerOver(cl.getElementId("LinkGithubOuter"))) COLOR_LIGHT_HOVER else COLOR_LIGHT,
                }),
            });
            {
                defer cl.CLOSE();
                cl.text(
                    "Github",
                    cl.Config.text(.{ .font_id = FONT_ID_BODY_24, .font_size = 24, .color = .{ 61, 26, 5, 255 } }),
                );
            }
        }
        inline for (COLORS_TOP_BORDER, 0..) |color, i| {
            cl.UI(&.{
                .ID("TopBorder" ++ .{i}),
                .layout(.{ .size = .{ .h = .fixed(4), .w = .grow } }),
                .rectangle(.{ .color = color }),
            });
            cl.CLOSE();
        }

        cl.UI(&.{
            .ID("ScrollContainerBackgroundRectangle"),
            .scroll(.{ .vertical = true }),
            .layout(.{ .size = .grow, .direction = .TOP_TO_BOTTOM }),
            .rectangle(.{ .color = COLOR_LIGHT }),
            .border(.{ .between_children = .{ .width = 2, .color = COLOR_RED } }),
        });
        {
            defer cl.CLOSE();
            // if (!mobileScreen) {
            if (true) {
                landingPageDesktop();
                // FeatureBlocksDesktop()
                // DeclarativeSyntaxPageDesktop()
                // HighPerformancePageDesktop(lerpValue)
                // RendererPageDesktop()
            } else {
                // LandingPageMobile()
                // FeatureBlocksMobile()
                // DeclarativeSyntaxPageMobile()
                // HighPerformancePageMobile(lerpValue)
                // RendererPageMobile()
            }
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
        .vsync_hint = true,
        .window_highdpi = true,
        .window_resizable = true,
    });
    rl.initWindow(1000, 1000, "Raylib zig Example");
    rl.setTargetFPS(60);

    // load assets
    loadFont(@embedFile("resources/Calistoga-Regular.ttf"), FONT_ID_TITLE_56, 56);
    loadFont(@embedFile("resources/Calistoga-Regular.ttf"), FONT_ID_TITLE_52, 52);
    loadFont(@embedFile("resources/Calistoga-Regular.ttf"), FONT_ID_TITLE_48, 48);
    loadFont(@embedFile("resources/Calistoga-Regular.ttf"), FONT_ID_TITLE_36, 36);
    loadFont(@embedFile("resources/Calistoga-Regular.ttf"), FONT_ID_TITLE_32, 32);
    loadFont(@embedFile("resources/Quicksand-Semibold.ttf"), FONT_ID_BODY_36, 36);
    loadFont(@embedFile("resources/Quicksand-Semibold.ttf"), FONT_ID_BODY_30, 30);
    loadFont(@embedFile("resources/Quicksand-Semibold.ttf"), FONT_ID_BODY_28, 28);
    loadFont(@embedFile("resources/Quicksand-Semibold.ttf"), FONT_ID_BODY_24, 24);
    loadFont(@embedFile("resources/Quicksand-Semibold.ttf"), FONT_ID_BODY_16, 16);

    syntaxImage = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("resources/declarative.png")));
    checkImage1 = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("resources/check_1.png")));
    checkImage2 = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("resources/check_2.png")));
    checkImage3 = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("resources/check_3.png")));
    checkImage4 = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("resources/check_4.png")));
    checkImage5 = rl.loadTextureFromImage(rl.loadImageFromMemory(".png", @embedFile("resources/check_5.png")));

    var debug_mode_enabled = false;
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.key_d)) {
            debug_mode_enabled = !debug_mode_enabled;
            cl.setDebugModeEnabled(debug_mode_enabled);
        }

        window_width = rl.getScreenWidth();
        window_height = rl.getScreenHeight();

        const mouse_pos = rl.getMousePosition();
        cl.setPointerState(.{
            .x = mouse_pos.x,
            .y = mouse_pos.y,
        }, rl.isMouseButtonDown(.mouse_button_left));

        cl.setLayoutDimensions(.{
            .w = @floatFromInt(window_width),
            .h = @floatFromInt(window_height),
        });
        var render_commands = createLayout(0);

        rl.beginDrawing();
        renderer.clayRaylibRender(&render_commands, allocator);
        rl.endDrawing();
    }
}

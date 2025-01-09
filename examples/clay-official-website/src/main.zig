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
var zig_logo_image6: rl.Texture2D = undefined;

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

const COLOR_BLOB_BORDER_1 = cl.Color{ 168, 66, 28, 255 };
const COLOR_BLOB_BORDER_2 = cl.Color{ 203, 100, 44, 255 };
const COLOR_BLOB_BORDER_3 = cl.Color{ 225, 138, 50, 255 };
const COLOR_BLOB_BORDER_4 = cl.Color{ 236, 159, 70, 255 };
const COLOR_BLOB_BORDER_5 = cl.Color{ 240, 189, 100, 255 };

const border_data = cl.BorderData{ .width = 2, .color = COLOR_RED };

var window_height: isize = 0;
var window_width: isize = 0;

fn LandingPageBlob(index: u32, font_size: u16, font_id: u16, color: cl.Color, image_size: f32, max_width: f32, text: []const u8, image: *rl.Texture2D) void {
    if (cl.OPEN(&.{
        .IDI("HeroBlob", index),
        .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = max_width }) }, .padding = .all(16), .gap = 16, .alignment = .{ .y = .CENTER } }),
        .border(.outside(color, 2, 10)),
    })) {
        defer cl.CLOSE();
        cl.SingleElem(&.{
            .IDI("CheckImage", index),
            .layout(.{ .sizing = .{ .w = .fixed(image_size) } }),
            .image(.{ .image_data = image, .source_dimensions = .{ .w = 128, .h = 128 } }),
        });
        cl.text(text, cl.Config.text(.{ .font_size = font_size, .font_id = font_id, .color = color }));
    }
}

fn landingPageDesktop() void {
    if (cl.OPEN(&.{
        .ID("LandingPage1Desktop"),
        .layout(.{
            .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 70) }) },
            .alignment = .{ .y = .CENTER },
            .padding = .{ .x = 50 },
            .gap = 16,
        }),
    })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("LandingPage1"),
            .layout(.{
                .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 70) }) },
                .direction = .TOP_TO_BOTTOM,
                .alignment = .{ .x = .CENTER },
                .padding = .all(32),
                .gap = 32,
            }),
            .border(.{ .left = border_data, .right = border_data }),
        })) {
            defer cl.CLOSE();
            LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_ZIG_LOGO, 64, 510, "The official Clay website recreated with zclay: clay-zig-bindings", &zig_logo_image6);

            if (cl.OPEN(&.{
                .ID("ClayPresentation"),
                .layout(.{
                    .sizing = .grow,
                    .alignment = .{ .y = .CENTER },
                    .gap = 16,
                }),
            })) {
                defer cl.CLOSE();
                if (cl.OPEN(&.{
                    .ID("LeftText"),
                    .layout(.{ .sizing = .{ .w = .percent(0.55) }, .direction = .TOP_TO_BOTTOM, .gap = 8 }),
                })) {
                    defer cl.CLOSE();
                    cl.text(
                        "Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
                        cl.Config.text(.{ .font_size = 56, .font_id = FONT_ID_TITLE_56, .color = COLOR_RED }),
                    );
                    cl.SingleElem(&.{ .ID("Spacer"), .layout(.{ .sizing = .{ .w = .grow, .h = .fixed(32) } }) });
                    cl.text(
                        "Clay is laying out this webpage .right now!",
                        cl.Config.text(.{ .font_size = 36, .font_id = FONT_ID_BODY_36, .color = COLOR_ORANGE }),
                    );
                }

                if (cl.OPEN(&.{
                    .ID("HeroImageOuter"),
                    .layout(.{ .sizing = .{ .w = .percent(0.45) }, .direction = .TOP_TO_BOTTOM, .alignment = .{ .x = .CENTER }, .gap = 16 }),
                })) {
                    defer cl.CLOSE();
                    LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_5, 32, 480, "High performance", &checkImage5);
                    LandingPageBlob(2, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_4, 32, 480, "Flexbox-style responsive layout", &checkImage4);
                    LandingPageBlob(3, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_3, 32, 480, "Declarative syntax", &checkImage3);
                    LandingPageBlob(4, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_2, 32, 480, "Single .h file for C/C++", &checkImage2);
                    LandingPageBlob(5, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_1, 32, 480, "Compile to 15kb .wasm", &checkImage1);
                }
            }
        }
    }
}

fn landingPageMobile() void {
    if (cl.OPEN(&.{
        .ID("LandingPage1Mobile"),
        .layout(.{
            .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 70) }) },
            .direction = .TOP_TO_BOTTOM,
            .alignment = .CENTER,
            .padding = .{ .x = 16, .y = 32 },
            .gap = 16,
        }),
    })) {
        defer cl.CLOSE();
        LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_ZIG_LOGO, 64, 510, "The official Clay website recreated with zclay: clay-zig-bindings", &zig_logo_image6);
        if (cl.OPEN(&.{
            .ID("LeftText"),
            .layout(.{ .sizing = .{ .w = .grow }, .direction = .TOP_TO_BOTTOM, .gap = 8 }),
        })) {
            defer cl.CLOSE();
            cl.text(
                "Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
                cl.Config.text(.{ .font_size = 56, .font_id = FONT_ID_TITLE_56, .color = COLOR_RED }),
            );
            cl.SingleElem(&.{ .ID("Spacer"), .layout(.{ .sizing = .{ .w = .grow, .h = .fixed(32) } }) });
            cl.text(
                "Clay is laying out this webpage .right now!",
                cl.Config.text(.{ .font_size = 36, .font_id = FONT_ID_BODY_36, .color = COLOR_ORANGE }),
            );
        }

        if (cl.OPEN(&.{
            .ID("HeroImageOuter"),
            .layout(.{ .sizing = .{ .w = .grow }, .direction = .TOP_TO_BOTTOM, .alignment = .{ .x = .CENTER }, .gap = 16 }),
        })) {
            defer cl.CLOSE();
            LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_5, 32, 480, "High performance", &checkImage5);
            LandingPageBlob(2, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_4, 32, 480, "Flexbox-style responsive layout", &checkImage4);
            LandingPageBlob(3, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_3, 32, 480, "Declarative syntax", &checkImage3);
            LandingPageBlob(4, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_2, 32, 480, "Single .h file for C/C++", &checkImage2);
            LandingPageBlob(5, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_1, 32, 480, "Compile to 15kb .wasm", &checkImage1);
        }
    }
}

fn featureBlocks(width_sizing: cl.SizingAxis, outer_padding: u16) void {
    const text_config = cl.Config.text(.{ .font_size = 24, .font_id = FONT_ID_BODY_24, .color = COLOR_RED });
    if (cl.OPEN(&.{
        .ID("HFileBoxOuter"),
        .layout(.{
            .direction = .TOP_TO_BOTTOM,
            .sizing = .{ .w = width_sizing },
            .alignment = .{ .y = .CENTER },
            .padding = .{ .x = outer_padding, .y = 32 },
            .gap = 8,
        }),
    })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("HFileIncludeOuter"),
            .layout(.{ .padding = .{ .x = 8, .y = 4 } }),
            .rectangle(.{ .color = COLOR_RED, .corner_radius = .all(8) }),
        })) {
            defer cl.CLOSE();
            cl.text("#include cl.h", .text(.{ .font_size = 24, .font_id = FONT_ID_BODY_24, .color = COLOR_LIGHT }));
        }
        cl.text("~2000 lines of C99.", text_config);
        cl.text("Zero dependencies, including no C standard library", text_config);
    }
    if (cl.OPEN(&.{
        .ID("BringYourOwnRendererOuter"),
        .layout(.{
            .direction = .TOP_TO_BOTTOM,
            .sizing = .{ .w = width_sizing },
            .alignment = .{ .y = .CENTER },
            .padding = .{ .x = outer_padding, .y = 32 },
            .gap = 8,
        }),
    })) {
        defer cl.CLOSE();
        cl.text("Renderer agnostic.", .text(.{ .font_size = 24, .font_id = FONT_ID_BODY_24, .color = COLOR_ORANGE }));
        cl.text("Layout with clay, then render with Raylib, WebGL Canvas or even as HTML.", text_config);
        cl.text("Flexible output for easy compositing in your custom engine or environment.", text_config);
    }
}

fn featureBlocksDesktop() void {
    if (cl.OPEN(&.{
        .ID("FeatureBlocksOuter"),
        .layout(.{
            .sizing = .{ .w = .grow },
            .alignment = .{ .y = .CENTER },
        }),
        .border(.{ .between_children = .{ .width = 2, .color = COLOR_RED } }),
    })) {
        defer cl.CLOSE();
        featureBlocks(.percent(0.5), 50);
    }
}

fn featureBlocksMobile() void {
    if (cl.OPEN(&.{
        .ID("FeatureBlocksOuter"),
        .layout(.{
            .sizing = .{ .w = .grow },
            .direction = .TOP_TO_BOTTOM,
        }),
        .border(.{ .between_children = .{ .width = 2, .color = COLOR_RED } }),
    })) {
        defer cl.CLOSE();
        featureBlocks(.grow, 16);
    }
}

fn declarativeSyntaxPage(title_text_config: cl.TextElementConfig, width_sizing: cl.SizingAxis) void {
    if (cl.OPEN(&.{ .ID("SyntaxPageLeftText"), .layout(.{ .sizing = .{ .w = width_sizing }, .direction = .TOP_TO_BOTTOM, .gap = 8 }) })) {
        defer cl.CLOSE();
        cl.text("Declarative Syntax", .text(title_text_config));
        cl.SingleElem(&.{
            .ID("SyntaxSpacer"),
            .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = 16 }) } }),
        });
        const text_conf = cl.Config.text(.{ .font_size = 28, .font_id = FONT_ID_BODY_28, .color = COLOR_RED });
        cl.text("Flexible and readable declarative syntax with nested UI element hierarchies.", text_conf);
        cl.text("Mix elements with standard C code like loops, conditionals and functions.", text_conf);
        cl.text("Create your own library of re-usable components from UI primitives like text, images and rectangles.", text_conf);
    }
    if (cl.OPEN(&.{ .ID("SyntaxPageRightImageOuter"), .layout(.{ .sizing = .{ .w = width_sizing }, .alignment = .{ .x = .CENTER } }) })) {
        defer cl.CLOSE();
        cl.SingleElem(&.{
            .ID("SyntaxPageRightImage"),
            .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = 568 }) } }),
            .image(.{ .image_data = &syntaxImage, .source_dimensions = .{ .h = 1136, .w = 1194 } }),
        });
    }
}

fn declarativeSyntaxPageDesktop() void {
    if (cl.OPEN(&.{
        .ID("SyntaxPageDesktop"),
        .layout(.{ .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 50) }) }, .alignment = .{ .y = .CENTER }, .padding = .{ .x = 50 } }),
    })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("SyntaxPage"),
            .layout(.{ .sizing = .{ .w = .grow, .h = .grow }, .alignment = .{ .y = .CENTER }, .padding = .all(32), .gap = 32 }),
            .border(.{ .left = .{ .width = 2, .color = COLOR_RED }, .right = .{ .width = 2, .color = COLOR_RED } }),
        })) {
            defer cl.CLOSE();
            declarativeSyntaxPage(.{ .font_size = 52, .font_id = FONT_ID_TITLE_52, .color = COLOR_RED }, .percent(0.5));
        }
    }
}

fn declarativeSyntaxPageMobile() void {
    if (cl.OPEN(&.{
        .ID("SyntaxPageMobile"),
        .layout(.{
            .direction = .TOP_TO_BOTTOM,
            .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 50) }) },
            .alignment = .CENTER,
            .padding = .{ .x = 16, .y = 32 },
            .gap = 16,
        }),
    })) {
        defer cl.CLOSE();
        declarativeSyntaxPage(.{ .font_size = 48, .font_id = FONT_ID_TITLE_48, .color = COLOR_RED }, .grow);
    }
}

fn colorLerp(a: cl.Color, b: cl.Color, amount: f32) cl.Color {
    return cl.Color{ a[0] + (b[0] - a[0]) * amount, a[1] + (b[1] - a[1]) * amount, a[2] + (b[2] - a[2]) * amount, a[3] + (b[3] - a[3]) * amount };
}

const LOREM_IPSUM_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

fn highPerformancePage(lerp_value: f32, title_text_tonfig: cl.TextElementConfig, width_sizing: cl.SizingAxis) void {
    if (cl.OPEN(&.{ .ID("PerformanceLeftText"), .layout(.{ .sizing = .{ .w = width_sizing }, .direction = .TOP_TO_BOTTOM, .gap = 8 }) })) {
        defer cl.CLOSE();
        cl.text("High Performance", .text(title_text_tonfig));
        cl.SingleElem(&.{ .ID("PerformanceSyntaxSpacer"), .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = 16 }) } }) });
        cl.text(
            "Fast enough to recompute your entire UI every frame.",
            .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_36, .color = COLOR_LIGHT }),
        );
        cl.text(
            "Small memory footprint (3.5mb default) with static allocation & reuse. No malloc / free.",
            .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_36, .color = COLOR_LIGHT }),
        );
        cl.text(
            "Simplify animations and reactive UI design by avoiding the standard performance hacks.",
            .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_36, .color = COLOR_LIGHT }),
        );
    }
    if (cl.OPEN(&.{ .ID("PerformanceRightImageOuter"), .layout(.{ .sizing = .{ .w = width_sizing }, .alignment = .{ .x = .CENTER } }) })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("PerformanceRightBorder"),
            .layout(.{ .sizing = .{ .w = .grow, .h = .fixed(400) } }),
            .border(.all(COLOR_LIGHT, 2, 0)),
        })) {
            defer cl.CLOSE();
            if (cl.OPEN(&.{
                .ID("AnimationDemoContainerLeft"),
                .layout(.{ .sizing = .{ .w = .percent(0.35 + 0.3 * lerp_value), .h = .grow }, .alignment = .{ .y = .CENTER }, .padding = .all(16) }),
                .rectangle(.{ .color = colorLerp(COLOR_RED, COLOR_ORANGE, lerp_value) }),
            })) {
                defer cl.CLOSE();
                cl.text(LOREM_IPSUM_TEXT, .text(.{ .font_size = 16, .font_id = FONT_ID_BODY_16, .color = COLOR_LIGHT }));
            }
            if (cl.OPEN(&.{
                .ID("AnimationDemoContainerRight"),
                .layout(.{ .sizing = .{ .w = .grow, .h = .grow }, .alignment = .{ .y = .CENTER }, .padding = .all(16) }),
                .rectangle(.{ .color = colorLerp(COLOR_ORANGE, COLOR_RED, lerp_value) }),
            })) {
                defer cl.CLOSE();
                cl.text(LOREM_IPSUM_TEXT, .text(.{ .font_size = 16, .font_id = FONT_ID_BODY_16, .color = COLOR_LIGHT }));
            }
        }
    }
}

fn highPerformancePageDesktop(lerp_value: f32) void {
    if (cl.OPEN(&.{
        .ID("PerformanceDesktop"),
        .layout(.{
            .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 50) }) },
            .alignment = .{ .y = .CENTER },
            .padding = .{ .x = 82, .y = 32 },
            .gap = 64,
        }),
        .rectangle(.{ .color = COLOR_RED }),
    })) {
        defer cl.CLOSE();
        highPerformancePage(lerp_value, .{ .font_size = 52, .font_id = FONT_ID_TITLE_52, .color = COLOR_LIGHT }, .percent(0.5));
    }
}

fn highPerformancePageMobile(lerp_value: f32) void {
    if (cl.OPEN(&.{
        .ID("PerformanceMobile"),
        .layout(
            .{
                .direction = .TOP_TO_BOTTOM,
                .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 50) }) },
                .alignment = .CENTER,
                .padding = .{ .x = 16, .y = 32 },
                .gap = 32,
            },
        ),
        .rectangle(.{ .color = COLOR_RED }),
    })) {
        defer cl.CLOSE();
        highPerformancePage(lerp_value, .{ .font_size = 48, .font_id = FONT_ID_TITLE_48, .color = COLOR_LIGHT }, .grow);
    }
}

fn rendererButtonActive(text: []const u8) void {
    if (cl.OPEN(&.{
        .layout(.{ .sizing = .{ .w = .fixed(300) }, .padding = .all(16) }),
        .rectangle(.{ .color = COLOR_RED, .corner_radius = .all(10) }),
    })) {
        defer cl.CLOSE();
        cl.text(text, .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_28, .color = COLOR_LIGHT }));
    }
}

fn rendererButtonInactive(index: u32, text: []const u8) void {
    if (cl.OPEN(&.{ .layout(.{}), .outside(.{ 2, COLOR_RED }, 10) })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("RendererButtonInactiveInner", index),
            .layout(.{ .sizing = .{ .w = .fixed(300) }, .padding = .all(16) }),
            .rectangle(.{ .color = COLOR_LIGHT, .corner_radius = .all(10) }),
        })) {
            defer cl.CLOSE();
            cl.text(text, .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_28, .color = COLOR_RED }));
        }
    }
}

fn rendererPage(title_text_config: cl.TextElementConfig, width_sizing: cl.SizingAxis) void {
    if (cl.OPEN(&.{ .ID("RendererLeftText"), .layout(.{ .sizing = .{ .w = width_sizing }, .direction = .TOP_TO_BOTTOM, .gap = 8 }) })) {
        defer cl.CLOSE();
        cl.text("Renderer & Platform Agnostic", .text(title_text_config));
        cl.SingleElem(&.{ .ID("Spacer"), .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = 16 }) } }) });
        cl.text(
            "Clay outputs a sorted array of primitive render commands, such as RECTANGLE, TEXT or IMAGE.",
            .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_36, .color = COLOR_RED }),
        );
        cl.text(
            "Write your own renderer in a few hundred lines of code, or use the provided examples for Raylib, WebGL canvas and more.",
            .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_36, .color = COLOR_RED }),
        );
        cl.text(
            "There's even an HTML renderer - you're looking at it .right now!",
            .text(.{ .font_size = 28, .font_id = FONT_ID_BODY_36, .color = COLOR_RED }),
        );
    }
    if (cl.OPEN(&.{
        .ID("RendererRightText"),
        .layout(.{ .sizing = .{ .w = width_sizing }, .alignment = .{ .x = .CENTER }, .direction = .TOP_TO_BOTTOM, .gap = 16 }),
    })) {
        defer cl.CLOSE();
        cl.text("Try changing renderer!", .text(.{ .font_size = 36, .font_id = FONT_ID_BODY_36, .color = COLOR_ORANGE }));
        cl.SingleElem(&.{ .ID("Spacer"), .layout(.{ .sizing = .{ .w = .growMinMax(.{ .max = 32 }) } }) });
        rendererButtonActive("Raylib Renderer");
    }
}

fn rendererPageDesktop() void {
    if (cl.OPEN(&.{
        .ID("RendererPageDesktop"),
        .layout(.{
            .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 50) }) },
            .alignment = .{ .y = .CENTER },
            .padding = .{ .x = 50 },
        }),
    })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("RendererPage"),
            .layout(.{ .sizing = .grow, .alignment = .{ .y = .CENTER }, .padding = .all(32), .gap = 32 }),
            .border(.{ .left = .{ .width = 2, .color = COLOR_RED }, .right = .{ .width = 2, .color = COLOR_RED } }),
        })) {
            defer cl.CLOSE();
            rendererPage(.{ .font_size = 52, .font_id = FONT_ID_TITLE_52, .color = COLOR_RED }, .percent(0.5));
        }
    }
}

fn rendererPageMobile() void {
    if (cl.OPEN(&.{
        .ID("RendererMobile"),
        .layout(
            .{
                .direction = .TOP_TO_BOTTOM,
                .sizing = .{ .w = .grow, .h = .fitMinMax(.{ .min = @floatFromInt(window_height - 50) }) },
                .alignment = .CENTER,
                .padding = .{ .x = 16, .y = 32 },
                .gap = 32,
            },
        ),
        .rectangle(.{ .color = COLOR_LIGHT }),
    })) {
        defer cl.CLOSE();
        rendererPage(.{ .font_size = 52, .font_id = FONT_ID_TITLE_52, .color = COLOR_RED }, .grow);
    }
}

fn createLayout(lerp_value: f32) cl.ClayArray(cl.RenderCommand) {
    const mobileScreen = window_width < 750;
    cl.beginLayout();

    if (cl.OPEN(&.{
        .ID("OuterContainer"),
        .layout(.{ .sizing = .grow, .direction = .TOP_TO_BOTTOM }),
        .rectangle(.{ .color = COLOR_LIGHT }),
    })) {
        defer cl.CLOSE();
        if (cl.OPEN(&.{
            .ID("Header"),
            .layout(.{
                .sizing = .{ .h = .fixed(50), .w = .grow },
                .alignment = .{ .y = .CENTER },
                .padding = .{ .x = 32 },
                .gap = 24,
            }),
        })) {
            defer cl.CLOSE();
            cl.text("Clay", cl.Config.text(.{
                .font_id = FONT_ID_BODY_24,
                .font_size = 24,
                .color = .{ 61, 26, 5, 255 },
            }));
            cl.SingleElem(&.{ .ID("HeaderSpacer"), .layout(.{ .sizing = .{ .w = .grow } }) });

            if (!mobileScreen) {
                if (cl.OPEN(&.{ .ID("LinkExamplesInner"), .layout(.{}), .rectangle(.{ .color = .{ 0, 0, 0, 0 } }) })) {
                    defer cl.CLOSE();
                    cl.text("Examples", cl.Config.text(.{ .font_id = FONT_ID_BODY_24, .font_size = 24, .color = .{ 61, 26, 5, 255 } }));
                }
                if (cl.OPEN(&.{ .ID("LinkDocsOuter"), .layout(.{}), .rectangle(.{ .color = .{ 0, 0, 0, 0 } }) })) {
                    defer cl.CLOSE();
                    cl.text("Docs", cl.Config.text(.{ .font_id = FONT_ID_BODY_24, .font_size = 24, .color = .{ 61, 26, 5, 255 } }));
                }
            }

            if (cl.OPEN(&.{
                .ID("LinkGithubOuter"),
                .layout(.{ .padding = .{ .x = 32, .y = 6 } }),
                .border(.outside(COLOR_RED, 2, 10)),
                .rectangle(.{
                    .corner_radius = .all(10),
                    .color = if (cl.pointerOver(cl.getElementId("LinkGithubOuter"))) COLOR_LIGHT_HOVER else COLOR_LIGHT,
                }),
            })) {
                defer cl.CLOSE();
                cl.text(
                    "Github",
                    cl.Config.text(.{ .font_id = FONT_ID_BODY_24, .font_size = 24, .color = .{ 61, 26, 5, 255 } }),
                );
            }
        }
        inline for (COLORS_TOP_BORDER, 0..) |color, i| {
            cl.SingleElem(&.{
                .ID("TopBorder" ++ .{i}),
                .layout(.{ .sizing = .{ .h = .fixed(4), .w = .grow } }),
                .rectangle(.{ .color = color }),
            });
        }

        if (cl.OPEN(&.{
            .ID("ScrollContainerBackgroundRectangle"),
            .scroll(.{ .vertical = true }),
            .layout(.{ .sizing = .grow, .direction = .TOP_TO_BOTTOM }),
            .rectangle(.{ .color = COLOR_LIGHT }),
            .border(.{ .between_children = .{ .width = 2, .color = COLOR_RED } }),
        })) {
            defer cl.CLOSE();
            if (!mobileScreen) {
                landingPageDesktop();
                featureBlocksDesktop();
                declarativeSyntaxPageDesktop();
                highPerformancePageDesktop(lerp_value);
                rendererPageDesktop();
            } else {
                landingPageMobile();
                featureBlocksMobile();
                declarativeSyntaxPageMobile();
                highPerformancePageMobile(lerp_value);
                rendererPageMobile();
            }
        }
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
    rl.setTargetFPS(120);

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

    syntaxImage = loadImage("resources/declarative.png");
    checkImage1 = loadImage("resources/check_1.png");
    checkImage2 = loadImage("resources/check_2.png");
    checkImage3 = loadImage("resources/check_3.png");
    checkImage4 = loadImage("resources/check_4.png");
    checkImage5 = loadImage("resources/check_5.png");
    zig_logo_image6 = loadImage("resources/zig-mark.png");

    var animation_lerp_value: f32 = -1.0;
    var debug_mode_enabled = false;
    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.d)) {
            debug_mode_enabled = !debug_mode_enabled;
            cl.setDebugModeEnabled(debug_mode_enabled);
        }

        animation_lerp_value += rl.getFrameTime();
        if (animation_lerp_value > 1) {
            animation_lerp_value = animation_lerp_value - 2;
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
        var render_commands = createLayout(if (animation_lerp_value < 0) animation_lerp_value + 1 else 1 - animation_lerp_value);

        rl.beginDrawing();
        renderer.clayRaylibRender(&render_commands, allocator);
        rl.endDrawing();
    }
}

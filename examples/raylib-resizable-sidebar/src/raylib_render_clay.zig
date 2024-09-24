const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const math = std.math;

pub fn clayColorToRaylibColor(color: cl.Color) rl.Color {
    return rl.Color{
        .r = @intFromFloat(color[0]),
        .g = @intFromFloat(color[1]),
        .b = @intFromFloat(color[2]),
        .a = @intFromFloat(color[3]),
    };
}

pub var raylib_fonts: [10]?rl.Font = .{null} ** 10;

pub fn clayRaylibRender(renderCommands: *cl.ClayArray(cl.RenderCommand), allocator: std.mem.Allocator) void {
    var i: usize = 0;
    while (i < renderCommands.length) : (i += 1) {
        const renderCommand = cl.renderCommandArrayGet(renderCommands, @intCast(i));
        const boundingBox = renderCommand.boundingBox;
        switch (renderCommand.commandType) {
            .None => {},
            .Text => {
                const text = renderCommand.text.chars[0..@intCast(renderCommand.text.length)];
                const cloned = allocator.dupeZ(c_char, text) catch unreachable;
                defer allocator.free(cloned);
                const fontToUse: rl.Font = raylib_fonts[renderCommand.config.textElementConfig.fontId].?;
                rl.setTextLineSpacing(renderCommand.config.textElementConfig.lineSpacing);
                rl.drawTextEx(
                    fontToUse,
                    @ptrCast(@alignCast(cloned.ptr)),
                    rl.Vector2{ .x = boundingBox.x, .y = boundingBox.y },
                    @floatFromInt(renderCommand.config.textElementConfig.fontSize),
                    @floatFromInt(renderCommand.config.textElementConfig.letterSpacing),
                    clayColorToRaylibColor(renderCommand.config.textElementConfig.textColor),
                );
            },
            .Image => {
                const imageTexture: *rl.Texture2D = @ptrCast(
                    @alignCast(renderCommand.config.imageElementConfig.imageData),
                );
                rl.drawTextureEx(
                    imageTexture.*,
                    rl.Vector2{ .x = boundingBox.x, .y = boundingBox.y },
                    0,
                    boundingBox.width / @as(f32, @floatFromInt(imageTexture.width)),
                    rl.Color.white,
                );
            },
            .ScissorStart => {
                rl.beginScissorMode(
                    @intFromFloat(math.round(boundingBox.x)),
                    @intFromFloat(math.round(boundingBox.y)),
                    @intFromFloat(math.round(boundingBox.width)),
                    @intFromFloat(math.round(boundingBox.height)),
                );
            },
            .ScissorEnd => rl.endScissorMode(),
            .Rectangle => {
                const config = renderCommand.config.rectangleElementConfig;
                if (config.cornerRadius.topLeft > 0) {
                    const radius: f32 = (config.cornerRadius.topLeft * 2) / @min(boundingBox.width, boundingBox.height);
                    rl.drawRectangleRounded(
                        rl.Rectangle{
                            .x = boundingBox.x,
                            .y = boundingBox.y,
                            .width = boundingBox.width,
                            .height = boundingBox.height,
                        },
                        radius,
                        8,
                        clayColorToRaylibColor(config.color),
                    );
                } else {
                    rl.drawRectangle(
                        @intFromFloat(boundingBox.x),
                        @intFromFloat(boundingBox.y),
                        @intFromFloat(boundingBox.width),
                        @intFromFloat(boundingBox.height),
                        clayColorToRaylibColor(config.color),
                    );
                }
            },
            .Border => {
                const config = renderCommand.config.borderElementConfig;
                if (config.left.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(boundingBox.x)),
                        @intFromFloat(math.round(boundingBox.y + config.cornerRadius.topLeft)),
                        @intCast(config.left.width),
                        @intFromFloat(math.round(boundingBox.height - config.cornerRadius.topLeft - config.cornerRadius.bottomLeft)),
                        clayColorToRaylibColor(config.left.color),
                    );
                }
                if (config.right.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(boundingBox.x + boundingBox.width - @as(f32, @floatFromInt(config.right.width)))),
                        @intFromFloat(math.round(boundingBox.y + config.cornerRadius.topRight)),
                        @intCast(config.right.width),
                        @intFromFloat(math.round(boundingBox.height - config.cornerRadius.topRight - config.cornerRadius.bottomRight)),
                        clayColorToRaylibColor(config.right.color),
                    );
                }
                if (config.top.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(boundingBox.x + config.cornerRadius.topLeft)),
                        @intFromFloat(math.round(boundingBox.y)),
                        @intFromFloat(math.round(boundingBox.width - config.cornerRadius.topLeft - config.cornerRadius.topRight)),
                        @intCast(config.top.width),
                        clayColorToRaylibColor(config.top.color),
                    );
                }
                if (config.bottom.width > 0) {
                    rl.drawRectangle(
                        @intFromFloat(math.round(boundingBox.x + config.cornerRadius.bottomLeft)),
                        @intFromFloat(math.round(boundingBox.y + boundingBox.height - @as(f32, @floatFromInt(config.bottom.width)))),
                        @intFromFloat(math.round(boundingBox.width - config.cornerRadius.bottomLeft - config.cornerRadius.bottomRight)),
                        @intCast(config.bottom.width),
                        clayColorToRaylibColor(config.bottom.color),
                    );
                }

                if (config.cornerRadius.topLeft > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(boundingBox.x + config.cornerRadius.topLeft),
                            .y = math.round(boundingBox.y + config.cornerRadius.topLeft),
                        },
                        math.round(config.cornerRadius.topLeft - @as(f32, @floatFromInt(config.top.width))),
                        config.cornerRadius.topLeft,
                        180,
                        270,
                        10,
                        clayColorToRaylibColor(config.top.color),
                    );
                }
                if (config.cornerRadius.topRight > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(boundingBox.x + boundingBox.width - config.cornerRadius.topRight),
                            .y = math.round(boundingBox.y + config.cornerRadius.topRight),
                        },
                        math.round(config.cornerRadius.topRight - @as(f32, @floatFromInt(config.top.width))),
                        config.cornerRadius.topRight,
                        270,
                        360,
                        10,
                        clayColorToRaylibColor(config.top.color),
                    );
                }
                if (config.cornerRadius.bottomLeft > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(boundingBox.x + config.cornerRadius.bottomLeft),
                            .y = math.round(boundingBox.y + boundingBox.height - config.cornerRadius.bottomLeft),
                        },
                        math.round(config.cornerRadius.bottomLeft - @as(f32, @floatFromInt(config.top.width))),
                        config.cornerRadius.bottomLeft,
                        90,
                        180,
                        10,
                        clayColorToRaylibColor(config.bottom.color),
                    );
                }
                if (config.cornerRadius.bottomRight > 0) {
                    rl.drawRing(
                        rl.Vector2{
                            .x = math.round(boundingBox.x + boundingBox.width - config.cornerRadius.bottomRight),
                            .y = math.round(boundingBox.y + boundingBox.height - config.cornerRadius.bottomRight),
                        },
                        math.round(config.cornerRadius.bottomRight - @as(f32, @floatFromInt(config.top.width))),
                        config.cornerRadius.bottomRight,
                        0.1,
                        90,
                        10,
                        clayColorToRaylibColor(config.bottom.color),
                    );
                }
            },
            .Custom => {
                // Implement custom element rendering here
            },
        }
    }
}

pub fn measureText(clay_text: []const u8, config: *cl.TextElementConfig) cl.Dimensions {
    const font = raylib_fonts[config.fontId].?;
    const text: []const u8 = clay_text;
    const font_size: f32 = @floatFromInt(config.fontSize);
    const letter_spacing: f32 = @floatFromInt(config.letterSpacing);
    const line_spacing = config.lineSpacing;

    var temp_byte_counter: usize = 0;
    var byte_counter: usize = 0;
    var text_width: f32 = 0.0;
    var temp_text_width: f32 = 0.0;
    var text_height: f32 = font_size;
    const scale_factor: f32 = font_size / @as(f32, @floatFromInt(font.baseSize));

    var utf8 = std.unicode.Utf8View.initUnchecked(text).iterator();

    while (utf8.nextCodepoint()) |codepoint| {
        byte_counter += std.unicode.utf8CodepointSequenceLength(codepoint) catch 1;
        const index: usize = @intCast(
            rl.getGlyphIndex(font, @as(i32, @intCast(codepoint))),
        );

        if (codepoint != '\n') {
            if (font.glyphs[index].advanceX != 0) {
                text_width += @floatFromInt(font.glyphs[index].advanceX);
            } else {
                text_width += font.recs[index].width + @as(f32, @floatFromInt(font.glyphs[index].offsetX));
            }
        } else {
            if (temp_text_width < text_width) temp_text_width = text_width;
            byte_counter = 0;
            text_width = 0;
            text_height += font_size + @as(f32, @floatFromInt(line_spacing));
        }

        if (temp_byte_counter < byte_counter) temp_byte_counter = byte_counter;
    }

    if (temp_text_width < text_width) temp_text_width = text_width;

    return cl.Dimensions{
        .h = text_height,
        .w = temp_text_width * scale_factor + @as(f32, @floatFromInt(temp_byte_counter - 1)) * letter_spacing,
    };
}

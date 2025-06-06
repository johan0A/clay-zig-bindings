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

pub fn clayRaylibRender(render_commands: *cl.ClayArray(cl.RenderCommand), allocator: std.mem.Allocator) !void {
    var i: usize = 0;
    while (i < render_commands.length) : (i += 1) {
        const render_command = cl.renderCommandArrayGet(render_commands, @intCast(i));
        const bounding_box = render_command.bounding_box;
        switch (render_command.command_type) {
            .none => {},
            .text => {
                const config = render_command.render_data.text;
                const text = config.string_contents.chars[0..@intCast(config.string_contents.length)];
                // Raylib uses standard C strings so isn't compatible with cheap slices, we need to clone the string to append null terminator
                const cloned = try allocator.dupeZ(u8, text);
                defer allocator.free(cloned);

                const fontToUse: rl.Font = raylib_fonts[config.font_id].?;
                rl.setTextLineSpacing(config.line_height);
                rl.drawTextEx(
                    fontToUse,
                    cloned,
                    rl.Vector2{ .x = bounding_box.x, .y = bounding_box.y },
                    @floatFromInt(config.font_size),
                    @floatFromInt(config.letter_spacing),
                    clayColorToRaylibColor(config.text_color),
                );
            },
            .image => {
                const config = render_command.render_data.image;
                const tint = config.background_color;

                const image_texture: *const rl.Texture2D = @ptrCast(@alignCast(config.image_data));
                rl.drawTextureEx(
                    image_texture.*,
                    rl.Vector2{ .x = bounding_box.x, .y = bounding_box.y },
                    0,
                    bounding_box.width / @as(f32, @floatFromInt(image_texture.width)),
                    // TODO: add tint support
                    clayColorToRaylibColor(tint),
                );
            },
            .scissor_start => {
                rl.beginScissorMode(
                    @intFromFloat(@round(bounding_box.x)),
                    @intFromFloat(@round(bounding_box.y)),
                    @intFromFloat(@round(bounding_box.width)),
                    @intFromFloat(@round(bounding_box.height)),
                );
            },
            .scissor_end => rl.endScissorMode(),
            .rectangle => {
                const config = render_command.render_data.rectangle;
                if (config.corner_radius.top_left > 0) {
                    const radius: f32 = (config.corner_radius.top_left * 2) / @min(bounding_box.width, bounding_box.height);
                    rl.drawRectangleRounded(
                        rl.Rectangle{
                            .x = bounding_box.x,
                            .y = bounding_box.y,
                            .width = bounding_box.width,
                            .height = bounding_box.height,
                        },
                        radius,
                        8,
                        clayColorToRaylibColor(config.background_color),
                    );
                } else {
                    rl.drawRectangle(
                        @intFromFloat(bounding_box.x),
                        @intFromFloat(bounding_box.y),
                        @intFromFloat(bounding_box.width),
                        @intFromFloat(bounding_box.height),
                        clayColorToRaylibColor(config.background_color),
                    );
                }
            },
            .border => {
                const config = render_command.render_data.border;
                const color = clayColorToRaylibColor(config.color);
                const bb = bounding_box;

                const widths = [_]u32{ config.width.left, config.width.right, config.width.top, config.width.bottom };
                const corners = [_]f32{ config.corner_radius.top_left, config.corner_radius.top_right, config.corner_radius.bottom_left, config.corner_radius.bottom_right };

                inline for (0..4) |j| {
                    if (widths[j] > 0) {
                        const is_vertical = j < 2;
                        const is_second = j % 2 == 1;

                        const x = if (is_vertical)
                            if (is_second) bb.x + bb.width - @as(f32, @floatFromInt(widths[j])) else bb.x
                        else
                            bb.x + corners[if (is_second) 2 else 0];

                        const y = if (is_vertical)
                            bb.y + corners[if (is_second) 1 else 0]
                        else
                            (if (is_second) bb.y + bb.height - @as(f32, @floatFromInt(widths[j])) else bb.y);

                        const w = if (is_vertical)
                            @as(f32, @floatFromInt(widths[j]))
                        else
                            bb.width - corners[if (is_second) 2 else 0] - corners[if (is_second) 3 else 1];

                        const h = if (is_vertical)
                            bb.height - corners[if (is_second) 1 else 0] - corners[if (is_second) 3 else 2]
                        else
                            @as(f32, @floatFromInt(widths[j]));

                        rl.drawRectangle(@intFromFloat(@round(x)), @intFromFloat(@round(y)), @intFromFloat(@round(w)), @intFromFloat(@round(h)), color);
                    }
                }

                const angle_starts = [_]f32{ 180, 270, 90, 0.1 };
                const angle_ends = [_]f32{ 270, 360, 180, 90 };

                inline for (0..4) |j| {
                    if (corners[j] > 0) {
                        const is_right = j % 2 == 1;
                        const is_bottom = j >= 2;

                        rl.drawRing(
                            rl.Vector2{
                                .x = @round(bb.x + if (is_right) bb.width - corners[j] else corners[j]),
                                .y = @round(bb.y + if (is_bottom) bb.height - corners[j] else corners[j]),
                            },
                            @round(corners[j] - @as(f32, @floatFromInt(if (j == 3) config.width.bottom else config.width.top))),
                            corners[j],
                            angle_starts[j],
                            angle_ends[j],
                            10,
                            color,
                        );
                    }
                }
            },
            .custom => {
                // Implement custom element rendering here
            },
        }
    }
}

pub fn measureText(clay_text: []const u8, config: *cl.TextElementConfig, _: void) cl.Dimensions {
    const font = raylib_fonts[config.font_id].?;
    const text: []const u8 = clay_text;
    const font_size: f32 = @floatFromInt(config.font_size);
    const letter_spacing: f32 = @floatFromInt(config.letter_spacing);
    const line_height = config.line_height;

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
            text_height += font_size + @as(f32, @floatFromInt(line_height));
        }

        if (temp_byte_counter < byte_counter) temp_byte_counter = byte_counter;
    }

    if (temp_text_width < text_width) temp_text_width = text_width;

    return cl.Dimensions{
        .h = text_height,
        .w = temp_text_width * scale_factor + (@as(f32, @floatFromInt(temp_byte_counter)) - 1) * letter_spacing,
    };
}

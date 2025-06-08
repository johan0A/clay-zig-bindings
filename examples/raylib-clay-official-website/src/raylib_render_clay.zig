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

pub fn clayRaylibRender(render_commands: []cl.RenderCommand, allocator: std.mem.Allocator) !void {
    for (0..render_commands.len) |i| {
        const render_command = render_commands[i];
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
                var tint = config.background_color;
                if (std.mem.eql(f32, &tint, &.{ 0, 0, 0, 0 })) {
                    tint = .{ 255, 255, 255, 255 };
                }

                const image_texture: *const rl.Texture2D = @ptrCast(@alignCast(config.image_data));
                rl.drawTextureEx(
                    image_texture.*,
                    rl.Vector2{ .x = bounding_box.x, .y = bounding_box.y },
                    0,
                    bounding_box.width / @as(f32, @floatFromInt(image_texture.width)),
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
                const corners = config.corner_radius;

                const drawRect = struct {
                    fn draw(x: f32, y: f32, w: f32, h: f32, c: rl.Color) void {
                        rl.drawRectangle(@intFromFloat(@round(x)), @intFromFloat(@round(y)), @intFromFloat(@round(w)), @intFromFloat(@round(h)), c);
                    }
                }.draw;

                drawRect(
                    bb.x,
                    bb.y + corners.top_left,
                    @floatFromInt(config.width.left),
                    bb.height - corners.top_left - corners.bottom_left,
                    color,
                );

                drawRect(
                    bb.x + bb.width - @as(f32, @floatFromInt(config.width.right)),
                    bb.y + corners.top_right,
                    @floatFromInt(config.width.right),
                    bb.height - corners.top_right - corners.bottom_right,
                    color,
                );

                drawRect(
                    bb.x + corners.top_left,
                    bb.y,
                    bb.width - corners.top_left - corners.top_right,
                    @floatFromInt(config.width.top),
                    color,
                );

                drawRect(
                    bb.x + corners.bottom_left,
                    bb.y + bb.height - @as(f32, @floatFromInt(config.width.bottom)),
                    bb.width - corners.bottom_left - corners.bottom_right,
                    @floatFromInt(config.width.bottom),
                    color,
                );

                const drawCorner = struct {
                    fn draw(center: rl.Vector2, innerRadius: f32, outerRadius: f32, startAngle: f32, endAngle: f32, c: rl.Color) void {
                        if (outerRadius <= 0) return;
                        rl.drawRing(center, @round(innerRadius), @round(outerRadius), startAngle, endAngle, 10, c);
                    }
                }.draw;

                drawCorner(
                    rl.Vector2{ .x = @round(bb.x + corners.top_left), .y = @round(bb.y + corners.top_left) },
                    corners.top_left - @as(f32, @floatFromInt(config.width.top)),
                    corners.top_left,
                    180,
                    270,
                    color,
                );

                drawCorner(
                    rl.Vector2{ .x = @round(bb.x + bb.width - corners.top_right), .y = @round(bb.y + corners.top_right) },
                    corners.top_right - @as(f32, @floatFromInt(config.width.top)),
                    corners.top_right,
                    270,
                    360,
                    color,
                );

                drawCorner(
                    rl.Vector2{ .x = @round(bb.x + corners.bottom_left), .y = @round(bb.y + bb.height - corners.bottom_left) },
                    corners.bottom_left - @as(f32, @floatFromInt(config.width.bottom)),
                    corners.bottom_left,
                    90,
                    180,
                    color,
                );

                drawCorner(
                    rl.Vector2{ .x = @round(bb.x + bb.width - corners.bottom_right), .y = @round(bb.y + bb.height - corners.bottom_right) },
                    corners.bottom_right - @as(f32, @floatFromInt(config.width.bottom)),
                    corners.bottom_right,
                    0.1,
                    90,
                    color,
                );
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

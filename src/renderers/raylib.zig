//! Usage:
//! ```
//! renderer.fonts[0] = try rl.loadFont("my_font.ttf");
//! clay.setMeasureTextFunction(void, {}, renderer.measureText);
//! ...
//! rl.beginDrawing();
//! renderer.render(clay.endLayout());
//! rl.endDrawing();
//! ```

const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");

pub var fonts: [16]?rl.Font = @splat(null);

pub fn render(render_commands: []const cl.RenderCommand) void {
    for (render_commands) |*render_command| {
        const bounding_box = render_command.bounding_box;
        switch (render_command.command_type) {
            .none => {},
            .text => {
                const config = render_command.render_data.text;
                drawText(
                    fontFromId(config.font_id),
                    config.string_contents.chars[0..@intCast(config.string_contents.length)],
                    .{ .x = bounding_box.x, .y = bounding_box.y },
                    @floatFromInt(config.font_size),
                    @floatFromInt(config.letter_spacing),
                    @floatFromInt(config.line_height),
                    raylibColorFromClayColor(config.text_color),
                );
            },
            .image => {
                const config = render_command.render_data.image;
                const texture: *const rl.Texture2D = @ptrCast(@alignCast(config.image_data orelse continue));
                const tint: cl.Color = if (std.mem.eql(f32, &config.background_color, &.{ 0, 0, 0, 0 })) .{ 255, 255, 255, 255 } else config.background_color;
                rl.drawTexturePro(
                    texture.*,
                    .{ .x = 0, .y = 0, .width = @floatFromInt(texture.width), .height = @floatFromInt(texture.height) },
                    .{ .x = bounding_box.x, .y = bounding_box.y, .width = bounding_box.width, .height = bounding_box.height },
                    .{ .x = 0, .y = 0 },
                    0,
                    raylibColorFromClayColor(tint),
                );
            },
            .scissor_start => rl.beginScissorMode(
                @intFromFloat(@round(bounding_box.x)),
                @intFromFloat(@round(bounding_box.y)),
                @intFromFloat(@round(bounding_box.width)),
                @intFromFloat(@round(bounding_box.height)),
            ),
            .scissor_end => rl.endScissorMode(),
            .rectangle => {
                const config = render_command.render_data.rectangle;
                const color = raylibColorFromClayColor(config.background_color);
                const rectangle: rl.Rectangle = .{
                    .x = bounding_box.x,
                    .y = bounding_box.y,
                    .width = bounding_box.width,
                    .height = bounding_box.height,
                };
                // raylib only supports a single radius for all corners
                if (config.corner_radius.top_left > 0) {
                    rl.drawRectangleRounded(
                        rectangle,
                        (config.corner_radius.top_left * 2) / @min(bounding_box.width, bounding_box.height),
                        8,
                        color,
                    );
                } else {
                    rl.drawRectangleRec(rectangle, color);
                }
            },
            .border => {
                const config = render_command.render_data.border;
                const color = raylibColorFromClayColor(config.color);
                const bb = bounding_box;
                const corners = config.corner_radius;

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

                drawCorner(
                    .{ .x = @round(bb.x + corners.top_left), .y = @round(bb.y + corners.top_left) },
                    corners.top_left - @as(f32, @floatFromInt(config.width.top)),
                    corners.top_left,
                    180,
                    270,
                    color,
                );
                drawCorner(
                    .{ .x = @round(bb.x + bb.width - corners.top_right), .y = @round(bb.y + corners.top_right) },
                    corners.top_right - @as(f32, @floatFromInt(config.width.top)),
                    corners.top_right,
                    270,
                    360,
                    color,
                );
                drawCorner(
                    .{ .x = @round(bb.x + corners.bottom_left), .y = @round(bb.y + bb.height - corners.bottom_left) },
                    corners.bottom_left - @as(f32, @floatFromInt(config.width.bottom)),
                    corners.bottom_left,
                    90,
                    180,
                    color,
                );
                drawCorner(
                    .{ .x = @round(bb.x + bb.width - corners.bottom_right), .y = @round(bb.y + bb.height - corners.bottom_right) },
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

fn drawText(font: rl.Font, text: []const u8, position: rl.Vector2, font_size: f32, letter_spacing: f32, line_spacing: f32, color: rl.Color) void {
    const scale_factor = font_size / @as(f32, @floatFromInt(font.baseSize));
    var offset: rl.Vector2 = .{ .x = 0, .y = 0 };
    var utf8 = std.unicode.Utf8View.initUnchecked(text).iterator();
    while (utf8.nextCodepoint()) |codepoint| {
        if (codepoint == '\n') {
            offset = .{ .x = 0, .y = offset.y + font_size + line_spacing };
            continue;
        }
        if (codepoint != ' ' and codepoint != '\t') {
            rl.drawTextCodepoint(font, codepoint, position.add(offset), font_size, color);
        }
        const index: usize = @intCast(rl.getGlyphIndex(font, codepoint));
        const advance: f32 = if (font.glyphs[index].advanceX != 0) @floatFromInt(font.glyphs[index].advanceX) else font.recs[index].width;
        offset.x += advance * scale_factor + letter_spacing;
    }
}

fn drawRect(x: f32, y: f32, w: f32, h: f32, color: rl.Color) void {
    rl.drawRectangle(@intFromFloat(@round(x)), @intFromFloat(@round(y)), @intFromFloat(@round(w)), @intFromFloat(@round(h)), color);
}

fn drawCorner(center: rl.Vector2, radius_inner: f32, radius_outer: f32, angle_start: f32, angle_end: f32, color: rl.Color) void {
    if (radius_outer <= 0) return;
    rl.drawRing(center, @round(radius_inner), @round(radius_outer), angle_start, angle_end, 10, color);
}

pub fn raylibColorFromClayColor(color: cl.Color) rl.Color {
    return .{
        .r = @intFromFloat(color[0]),
        .g = @intFromFloat(color[1]),
        .b = @intFromFloat(color[2]),
        .a = @intFromFloat(color[3]),
    };
}

pub fn measureText(text: []const u8, config: *cl.TextElementConfig, _: void) cl.Dimensions {
    const font = fontFromId(config.font_id);
    const font_size: f32 = @floatFromInt(config.font_size);
    const letter_spacing: f32 = @floatFromInt(config.letter_spacing);
    const scale_factor = font_size / @as(f32, @floatFromInt(font.baseSize));

    var byte_count_max: usize = 0;
    var byte_count: usize = 0;
    var width_max: f32 = 0;
    var width: f32 = 0;
    var height: f32 = font_size;

    var utf8 = std.unicode.Utf8View.initUnchecked(text).iterator();
    while (utf8.nextCodepoint()) |codepoint| {
        byte_count += std.unicode.utf8CodepointSequenceLength(codepoint) catch 1;
        if (codepoint == '\n') {
            width_max = @max(width_max, width);
            byte_count = 0;
            width = 0;
            height += font_size + @as(f32, @floatFromInt(config.line_height));
        } else {
            const index: usize = @intCast(rl.getGlyphIndex(font, codepoint));
            if (font.glyphs[index].advanceX != 0) {
                width += @floatFromInt(font.glyphs[index].advanceX);
            } else {
                width += font.recs[index].width + @as(f32, @floatFromInt(font.glyphs[index].offsetX));
            }
        }
        byte_count_max = @max(byte_count_max, byte_count);
    }
    width_max = @max(width_max, width);

    return .{
        .h = height,
        .w = width_max * scale_factor + (@as(f32, @floatFromInt(byte_count_max)) - 1) * letter_spacing,
    };
}

fn fontFromId(font_id: u16) rl.Font {
    if (font_id < fonts.len) if (fonts[font_id]) |font| return font;
    return rl.getFontDefault() catch @panic("raylib default font unavailable, load a font into `fonts`");
}

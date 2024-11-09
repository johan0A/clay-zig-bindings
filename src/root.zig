const std = @import("std");
const builtin = @import("builtin");

/// for direct calls to the clay c library
pub const cdefs = struct {
    // TODO: should use @extern instead but zls does not yet support it well and that is more important
    extern "c" fn Clay_MinMemorySize() u32;
    extern "c" fn Clay_CreateArenaWithCapacityAndMemory(capacity: u32, offset: [*c]u8) Arena;
    extern "c" fn Clay_SetPointerState(position: Vector2, pointer_down: bool) void;
    extern "c" fn Clay_Initialize(arena: Arena, layout_dimensions: Dimensions) void;
    extern "c" fn Clay_UpdateScrollContainers(is_pointer_active: bool, scroll_delta: Vector2, delta_time: f32) void;
    extern "c" fn Clay_SetLayoutDimensions(dimensions: Dimensions) void;
    extern "c" fn Clay_BeginLayout() void;
    extern "c" fn Clay_EndLayout() ClayArray(RenderCommand);
    extern "c" fn Clay_PointerOver(id: ElementId) bool;
    extern "c" fn Clay_GetScrollContainerData(id: ElementId) ScrollContainerData;
    extern "c" fn Clay_SetMeasureTextFunction(measureTextFunction: *const fn (*String, *TextElementConfig) callconv(.C) Dimensions) void;
    extern "c" fn Clay_RenderCommandArray_Get(array: *ClayArray(RenderCommand), index: i32) *RenderCommand;
    extern "c" fn Clay_SetDebugModeEnabled(enabled: bool) void;

    extern "c" fn Clay__OpenElement() void;
    extern "c" fn Clay__CloseElement() void;
    extern "c" fn Clay__ElementPostConfiguration() void;
    extern "c" fn Clay__OpenTextElement(text: String, textConfig: *TextElementConfig) void;
    extern "c" fn Clay__AttachId(id: ElementId) void;
    extern "c" fn Clay__AttachLayoutConfig(layoutConfig: *LayoutConfig) void;
    extern "c" fn Clay__AttachElementConfig(config: *anyopaque, type: ElementConfigType) void;
    extern "c" fn Clay__StoreLayoutConfig(config: LayoutConfig) *LayoutConfig;
    extern "c" fn Clay__StoreRectangleElementConfig(config: RectangleElementConfig) *RectangleElementConfig;
    extern "c" fn Clay__StoreTextElementConfig(config: TextElementConfig) *TextElementConfig;
    extern "c" fn Clay__StoreImageElementConfig(config: ImageElementConfig) *ImageElementConfig;
    extern "c" fn Clay__StoreFloatingElementConfig(config: FloatingElementConfig) *FloatingElementConfig;
    extern "c" fn Clay__StoreCustomElementConfig(config: CustomElementConfig) *CustomElementConfig;
    extern "c" fn Clay__StoreScrollElementConfig(config: ScrollElementConfig) *ScrollElementConfig;
    extern "c" fn Clay__StoreBorderElementConfig(config: BorderElementConfig) *BorderElementConfig;
    extern "c" fn Clay__HashString(toHash: String, index: u32, seed: u32) ElementId;
    extern "c" fn Clay__GetOpenLayoutElementId() u32;
};

pub const String = extern struct {
    length: c_int,
    chars: [*c]c_char,
};

pub const Vector2 = extern struct {
    x: f32,
    y: f32,
};

pub const Dimensions = extern struct {
    w: f32,
    h: f32,
};

pub const Arena = extern struct {
    label: String,
    next_allocation: u64,
    capacity: u64,
    memory: [*c]c_char,
};

pub const BoundingBox = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub const Color = [4]f32;

pub const CornerRadius = extern struct {
    top_left: f32 = 0,
    top_right: f32 = 0,
    bottom_left: f32 = 0,
    bottom_right: f32 = 0,
};

pub const BorderData = extern struct {
    width: u32 = 0,
    color: Color = .{ 255, 255, 255, 255 },
};

pub const ElementId = extern struct {
    id: u32,
    offset: u32,
    base_id: u32,
    string_id: String,
};

pub const EnumBackingType = u8;

pub const RenderCommandType = enum(EnumBackingType) {
    None,
    Rectangle,
    Border,
    Text,
    Image,
    ScissorStart,
    ScissorEnd,
    Custom,
};

pub const TextWrapMode = enum(EnumBackingType) {
    Words,
    Newlines,
    None,
};

pub const FloatingAttachPointType = enum(EnumBackingType) {
    LEFT_TOP,
    LEFT_CENTER,
    LEFT_BOTTOM,
    CENTER_TOP,
    CENTER_CENTER,
    CENTER_BOTTOM,
    RIGHT_TOP,
    RIGHT_CENTER,
    RIGHT_BOTTOM,
};

pub const FloatingAttachPoints = extern struct {
    element: FloatingAttachPointType,
    parent: FloatingAttachPointType,
};

pub const ElementConfigUnion = extern union {
    rectangle_element_config: *RectangleElementConfig,
    text_element_config: *TextElementConfig,
    image_element_config: *ImageElementConfig,
    custom_element_config: *CustomElementConfig,
    border_element_config: *BorderElementConfig,
};

pub const RenderCommand = extern struct {
    bounding_box: BoundingBox,
    config: ElementConfigUnion,
    text: String,
    id: u32,
    command_type: RenderCommandType,
};

pub const ScrollContainerData = extern struct {
    // Note: This is a pointer to the real internal scroll position, mutating it may cause a change in final layout.
    // Intended for use with external functionality that modifies scroll position, such as scroll bars or auto scrolling.
    scroll_position: *Vector2,
    scroll_container_dimensions: Dimensions,
    content_dimensions: Dimensions,
    config: ScrollElementConfig,
    // Indicates whether an actual scroll container matched the provided ID or if the default struct was returned.
    found: bool,
};

pub const SizingType = enum(EnumBackingType) {
    FIT,
    GROW,
    PERCENT,
    FIXED,
};

pub const SizingConstraintsMinMax = extern struct {
    min: f32 = 0,
    max: f32 = 0,
};

pub const SizingConstraints = extern union {
    size_minmax: SizingConstraintsMinMax,
    size_percent: f32,
};

pub const SizingAxis = extern struct {
    // Note: `min` is used for CLAY_SIZING_PERCENT, slightly different to clay.h due to lack of C anonymous unions
    constraints: SizingConstraints = .{ .size_percent = 100 },
    type: SizingType = .FIT,

    pub const grow = SizingAxis{ .type = .GROW, .constraints = .{ .size_minmax = .{ .min = 0, .max = 0 } } };
    pub const fit = SizingAxis{ .type = .FIT, .constraints = .{ .size_minmax = .{ .min = 0, .max = 0 } } };

    pub fn fGrow(size_minmax: SizingConstraintsMinMax) SizingAxis {
        return .{ .type = .GROW, .constraints = .{ .size_minmax = size_minmax } };
    }

    pub fn fixed(size: f32) SizingAxis {
        return .{ .type = .FIT, .constraints = .{ .size_minmax = .{ .max = size, .min = size } } };
    }

    pub fn percent(size_percent: f32) SizingAxis {
        return .{ .type = .PERCENT, .constraints = .{ .size_percent = size_percent } };
    }

    pub fn fFit(size_minmax: SizingConstraintsMinMax) SizingAxis {
        return .{ .type = SizingType.FIT, .constraints = .{ .size_minmax = size_minmax } };
    }
};

pub const Sizing = extern struct {
    /// width
    w: SizingAxis = .{},
    /// height
    h: SizingAxis = .{},

    pub const grow = Sizing{ .h = .grow, .w = .grow };
};

pub const Padding = extern struct {
    x: u16 = 0,
    y: u16 = 0,

    pub fn uniform(size: u16) Padding {
        return Padding{
            .x = size,
            .y = size,
        };
    }
};

pub const LayoutDirection = enum(EnumBackingType) {
    LEFT_TO_RIGHT = 0,
    TOP_TO_BOTTOM = 1,
};

pub const LayoutAlignmentX = enum(EnumBackingType) {
    LEFT,
    RIGHT,
    CENTER,
};

pub const LayoutAlignmentY = enum(EnumBackingType) {
    TOP,
    BOTTOM,
    CENTER,
};

pub const ChildAlignment = extern struct {
    x: LayoutAlignmentX = .CENTER,
    y: LayoutAlignmentY = .CENTER,
};

pub const LayoutConfig = extern struct {
    /// sizing of the element
    size: Sizing = .{
        .h = .{ .constraints = .{ .size_percent = 100 }, .type = .GROW },
        .w = .{ .constraints = .{ .size_percent = 100 }, .type = .GROW },
    },
    /// padding arround children
    padding: Padding = .{},
    /// gap between the children
    gap: u16 = 0,
    /// alignement of the children
    alignment: ChildAlignment = .{},
    /// direction of the children's layout
    direction: LayoutDirection = .LEFT_TO_RIGHT,
};

pub fn ClayArray(comptime T: type) type {
    return extern struct {
        capacity: u32,
        length: u32,
        internal_array: [*]T,
    };
}

pub const RectangleElementConfig = extern struct {
    color: Color = .{ 255, 255, 255, 255 },
    corner_radius: CornerRadius = .{},
};

pub const BorderElementConfig = extern struct {
    left: BorderData,
    right: BorderData,
    top: BorderData,
    bottom: BorderData,
    between_children: BorderData,
    corner_radius: CornerRadius,
};

pub const TextElementConfig = extern struct {
    color: Color = .{ 0, 0, 0, 255 },
    font_id: u16 = 0,
    font_size: u16 = 20,
    letter_spacing: u16 = 0,
    line_height: u16 = 0,
    wrap_mode: TextWrapMode = .Newlines,
};

pub const ImageElementConfig = extern struct {
    image_data: *const anyopaque,
    source_dimensions: Dimensions,
};

pub const FloatingElementConfig = extern struct {
    offset: Vector2,
    expand: Dimensions,
    z_index: u16,
    parent_id: u32,
    attachment: FloatingAttachPoints,
};

pub const CustomElementConfig = extern struct {
    custom_data: *anyopaque,
};

pub const ScrollElementConfig = extern struct {
    horizontal: bool,
    vertical: bool,
};

pub const ElementConfigType = enum(EnumBackingType) {
    Rectangle = 1,
    Border = 2,
    Floating = 4,
    Scroll = 8,
    Image = 16,
    Text = 32,
    Custom = 64,
    // zig specific enum types
    id,
    Layout,
};

pub const Config = union(ElementConfigType) {
    Rectangle: *RectangleElementConfig,
    Border: *BorderElementConfig,
    Floating: *FloatingElementConfig,
    Scroll: *ScrollElementConfig,
    Image: *ImageElementConfig,
    Text: *TextElementConfig,
    Custom: *CustomElementConfig,
    id: ElementId,
    Layout: *LayoutConfig,

    pub fn layout(config: LayoutConfig) Config {
        return Config{ .Layout = cdefs.Clay__StoreLayoutConfig(config) };
    }
    pub fn rectangle(config: RectangleElementConfig) Config {
        return Config{ .Rectangle = cdefs.Clay__StoreRectangleElementConfig(config) };
    }
    pub fn text(config: TextElementConfig) Config {
        return Config{ .Text = cdefs.Clay__StoreTextElementConfig(config) };
    }
    pub fn image(config: ImageElementConfig) Config {
        return Config{ .Image = cdefs.Clay__StoreImageElementConfig(config) };
    }
    pub fn floating(config: FloatingElementConfig) Config {
        return Config{ .Floating = cdefs.Clay__StoreFloatingElementConfig(config) };
    }
    pub fn custom(config: CustomElementConfig) Config {
        return Config{ .Custom = cdefs.Clay__StoreCustomElementConfig(config) };
    }
    pub fn scroll(config: ScrollElementConfig) Config {
        return Config{ .Scroll = cdefs.Clay__StoreScrollElementConfig(config) };
    }
    pub fn border(config: BorderElementConfig) Config {
        return Config{ .Border = cdefs.Clay__StoreBorderElementConfig(config) };
    }
    pub fn ID(string: []const u8) Config {
        return Config{ .id = hashString(makeClayString(string), 0, 0) };
    }
    pub fn IDI(string: []const u8, index: u32) Config {
        return Config{ .id = hashString(makeClayString(string), index, 0) };
    }
};

pub const minMemorySize = cdefs.Clay_MinMemorySize;
pub const createArenaWithCapacityAndMemory = cdefs.Clay_CreateArenaWithCapacityAndMemory;
pub const initialize = cdefs.Clay_Initialize;
pub const setLayoutDimensions = cdefs.Clay_SetLayoutDimensions;
pub const beginLayout = cdefs.Clay_BeginLayout;
pub const endLayout = cdefs.Clay_EndLayout;
pub const pointerOver = cdefs.Clay_PointerOver;
pub const getScrollContainerData = cdefs.Clay_GetScrollContainerData;
pub const renderCommandArrayGet = cdefs.Clay_RenderCommandArray_Get;
pub const setDebugModeEnabled = cdefs.Clay_SetDebugModeEnabled;
pub const hashString = cdefs.Clay__HashString;

pub fn UI(configs: []const Config) void {
    cdefs.Clay__OpenElement();
    for (configs) |config| {
        switch (config) {
            .Layout => |layoutConf| cdefs.Clay__AttachLayoutConfig(layoutConf),
            .id => |id| cdefs.Clay__AttachId(id),
            inline else => |elem_config| cdefs.Clay__AttachElementConfig(@ptrCast(elem_config), config),
        }
    }
    cdefs.Clay__ElementPostConfiguration();
}

pub fn CLOSE() void {
    cdefs.Clay__CloseElement();
}

pub fn setPointerState(position: Vector2, pointer_down: bool) void {
    cdefs.Clay_SetPointerState(position, pointer_down);
}

pub fn updateScrollContainers(is_pointer_active: bool, scroll_delta: Vector2, delta_time: f32) void {
    cdefs.Clay_UpdateScrollContainers(is_pointer_active, scroll_delta, delta_time);
}

pub fn setMeasureTextFunction(comptime measureTextFunction: fn ([]const u8, *TextElementConfig) Dimensions) void {
    cdefs.Clay_SetMeasureTextFunction(struct {
        pub fn f(string: *String, config: *TextElementConfig) callconv(.C) Dimensions {
            return measureTextFunction(@ptrCast(string.chars[0..@intCast(string.length)]), config);
        }
    }.f);
}

pub fn makeClayString(string: []const u8) String {
    return .{
        .chars = @ptrCast(@constCast(string)),
        .length = @intCast(string.len),
    };
}

pub fn text(string: []const u8, config: Config) void {
    cdefs.Clay__OpenTextElement(makeClayString(string), config.Text);
}

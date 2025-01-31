const std = @import("std");
const builtin = @import("builtin");

pub extern var CLAY_LAYOUT_DEFAULT: LayoutConfig;
pub extern var Clay__debugViewHighlightColor: Color;
pub extern var Clay__debugViewWidth: u32;

/// for direct calls to the clay c library
pub const cdefs = struct {
    // TODO: should use @extern instead but zls does not yet support it well and that is more important
    pub extern fn Clay_MinMemorySize() u32;
    pub extern fn Clay_CreateArenaWithCapacityAndMemory(capacity: u32, offset: [*c]u8) Arena;
    pub extern fn Clay_SetPointerState(position: Vector2, pointerDown: bool) void;
    pub extern fn Clay_Initialize(arena: Arena, layoutDimensions: Dimensions, errorHandler: ErrorHandler) *Context;
    pub extern fn Clay_GetCurrentContext() *Context;
    pub extern fn Clay_SetCurrentContext(context: *Context) void;
    pub extern fn Clay_UpdateScrollContainers(enableDragScrolling: bool, scrollDelta: Vector2, deltaTime: f32) void;
    pub extern fn Clay_SetLayoutDimensions(dimensions: Dimensions) void;
    pub extern fn Clay_BeginLayout() void;
    pub extern fn Clay_EndLayout() ClayArray(RenderCommand);
    pub extern fn Clay_GetElementId(idString: String) ElementId;
    pub extern fn Clay_GetElementIdWithIndex(idString: String, index: u32) ElementId;
    pub extern fn Clay_Hovered() bool;
    pub extern fn Clay_OnHover(onHoverFunction: ?*const fn (ElementId, PointerData, *anyopaque) callconv(.c) void, userData: *anyopaque) void;
    pub extern fn Clay_PointerOver(elementId: ElementId) bool;
    pub extern fn Clay_GetScrollContainerData(id: ElementId) ScrollContainerData;
    pub extern fn Clay_SetMeasureTextFunction(measureTextFunction: *const fn (*String, *TextElementConfig) callconv(.c) Dimensions) void;
    pub extern fn Clay_SetQueryScrollOffsetFunction(queryScrollOffsetFunction: ?*const fn (u32) callconv(.c) Vector2) void;
    pub extern fn Clay_RenderCommandArray_Get(array: *ClayArray(RenderCommand), index: i32) *RenderCommand;
    pub extern fn Clay_SetDebugModeEnabled(enabled: bool) void;
    pub extern fn Clay_IsDebugModeEnabled() bool;
    pub extern fn Clay_SetCullingEnabled(enabled: bool) void;
    pub extern fn Clay_GetMaxElementCount() i32;
    pub extern fn Clay_SetMaxElementCount(maxElementCount: i32) void;
    pub extern fn Clay_GetMaxMeasureTextCacheWordCount() i32;
    pub extern fn Clay_SetMaxMeasureTextCacheWordCount(maxMeasureTextCacheWordCount: i32) void;
    pub extern fn Clay_ResetMeasureTextCache() void;

    pub extern fn Clay__OpenElement() void;
    pub extern fn Clay__CloseElement() void;
    pub extern fn Clay__StoreLayoutConfig(config: LayoutConfig) *LayoutConfig;
    pub extern fn Clay__ElementPostConfiguration() void;
    pub extern fn Clay__AttachId(id: ElementId) void;
    pub extern fn Clay__AttachLayoutConfig(config: *LayoutConfig) void;
    pub extern fn Clay__AttachElementConfig(config: ElementConfigUnion, @"type": ElementConfigType) void;
    pub extern fn Clay__StoreRectangleElementConfig(config: RectangleElementConfig) *RectangleElementConfig;
    pub extern fn Clay__StoreTextElementConfig(config: TextElementConfig) *TextElementConfig;
    pub extern fn Clay__StoreImageElementConfig(config: ImageElementConfig) *ImageElementConfig;
    pub extern fn Clay__StoreFloatingElementConfig(config: FloatingElementConfig) *FloatingElementConfig;
    pub extern fn Clay__StoreCustomElementConfig(config: CustomElementConfig) *CustomElementConfig;
    pub extern fn Clay__StoreScrollElementConfig(config: ScrollElementConfig) *ScrollElementConfig;
    pub extern fn Clay__StoreBorderElementConfig(config: BorderElementConfig) *BorderElementConfig;
    pub extern fn Clay__HashString(key: String, offset: u32, seed: u32) ElementId;
    pub extern fn Clay__OpenTextElement(text: String, textConfig: *TextElementConfig) void;
    pub extern fn Clay__GetParentElementId() u32;
};

pub const EnumBackingType = u8;

pub const String = extern struct {
    length: i32,
    chars: [*:0]const u8,
};

pub const Context = opaque {};

pub const Arena = extern struct {
    nextAllocation: usize,
    capacity: usize,
    memory: [*]u8,
};

pub const Dimensions = extern struct {
    w: f32,
    h: f32,
};

pub const Vector2 = extern struct {
    x: f32,
    y: f32,
};

pub const Color = [4]f32;

pub const BoundingBox = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub const SizingMinMax = extern struct {
    min: f32 = 0,
    max: f32 = 0,
};

const SizingConstraint = extern union {
    minmax: SizingMinMax,
    percent: f32,
};

pub const SizingAxis = extern struct {
    // Note: `min` is used for CLAY_SIZING_PERCENT, slightly different to clay.h due to lack of C anonymous unions
    size: SizingConstraint = .{ .minmax = .{} },
    type: SizingType = .FIT,

    pub const grow = SizingAxis{ .type = .GROW, .size = .{ .minmax = .{ .min = 0, .max = 0 } } };
    pub const fit = SizingAxis{ .type = .FIT, .size = .{ .minmax = .{ .min = 0, .max = 0 } } };

    pub fn growMinMax(size_minmax: SizingMinMax) SizingAxis {
        return .{ .type = .GROW, .size = .{ .minmax = size_minmax } };
    }

    pub fn fitMinMax(size_minmax: SizingMinMax) SizingAxis {
        return .{ .type = .FIT, .size = .{ .minmax = size_minmax } };
    }

    pub fn fixed(size: f32) SizingAxis {
        return .{ .type = .FIXED, .size = .{ .minmax = .{ .max = size, .min = size } } };
    }

    pub fn percent(size_percent: f32) SizingAxis {
        return .{ .type = .PERCENT, .size = .{ .percent = size_percent } };
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

    pub fn all(size: u16) Padding {
        return Padding{
            .x = size,
            .y = size,
        };
    }
};

pub const TextElementConfigWrapMode = enum(c_uint) {
    words = 0,
    newlines = 1,
    none = 2,
};

pub const TextElementConfig = extern struct {
    color: Color = .{ 0, 0, 0, 255 },
    font_id: u16 = 0,
    font_size: u16 = 20,
    letter_spacing: u16 = 0,
    line_height: u16 = 0,
    wrap_mode: TextElementConfigWrapMode = .words,
};

pub const FloatingAttachPointType = enum(u8) {
    LEFT_TOP = 0,
    LEFT_CENTER = 1,
    LEFT_BOTTOM = 2,
    CENTER_TOP = 3,
    CENTER_CENTER = 4,
    CENTER_BOTTOM = 5,
    RIGHT_TOP = 6,
    RIGHT_CENTER = 7,
    RIGHT_BOTTOM = 8,
};

pub const FloatingAttachPoints = extern struct {
    element: FloatingAttachPointType,
    parent: FloatingAttachPointType,
};

pub const PointerCaptureMode = enum(c_uint) {
    CAPTURE = 0,
    PASSTHROUGH = 1,
};

pub const FloatingElementConfig = extern struct {
    offset: Vector2,
    expand: Dimensions,
    zIndex: u16,
    parentId: u32,
    attachment: FloatingAttachPoints,
    pointerCaptureMode: PointerCaptureMode,
};

pub const Border = extern struct {
    width: u32,
    color: Color,
};

pub const ElementConfigUnion = extern union {
    rectangle_config: *RectangleElementConfig,
    text_config: *TextElementConfig,
    image_config: *ImageElementConfig,
    floating_config: *FloatingElementConfig,
    custom_config: *CustomElementConfig,
    scroll_config: *ScrollElementConfig,
    border_config: *BorderElementConfig,
};

pub const ElementConfig = extern struct {
    type: ElementConfigType,
    config: ElementConfigUnion,
};

pub const RenderCommandType = enum(u8) {
    none = 0,
    rectangle = 1,
    border = 2,
    text = 3,
    image = 4,
    scissor_start = 5,
    scissor_end = 6,
    custom = 7,
};

pub const RenderCommandArray = extern struct {
    capacity: i32,
    length: i32,
    internalArray: [*]RenderCommand,
};

pub const PointerDataInteractionState = enum(c_uint) {
    pressed_this_frame = 0,
    pressed = 1,
    released_this_frame = 2,
    released = 3,
};

pub const PointerData = extern struct {
    position: Vector2,
    state: PointerDataInteractionState,
};

pub const ErrorType = enum(c_uint) {
    text_measurement_function_not_provided = 0,
    arena_capacity_exceeded = 1,
    elements_capacity_exceeded = 2,
    text_measurement_capacity_exceeded = 3,
    duplicate_id = 4,
    floating_container_parent_not_found = 5,
    internal_error = 6,
};

pub const ErrorData = extern struct {
    errorType: ErrorType,
    errorText: String,
    userData: usize,
};

pub const ErrorHandler = extern struct {
    error_handler_function: ?*const fn (ErrorData) callconv(.c) void = null,
    user_data: usize = 0,
};

pub const CornerRadius = extern struct {
    top_left: f32 = 0,
    top_right: f32 = 0,
    bottom_left: f32 = 0,
    bottom_right: f32 = 0,

    pub fn all(radius: f32) CornerRadius {
        return .{
            .top_left = radius,
            .top_right = radius,
            .bottom_left = radius,
            .bottom_right = radius,
        };
    }
};

pub const BorderData = extern struct {
    width: u32 = 0,
    color: Color = .{ 0, 0, 0, 0 },
};

pub const ElementId = extern struct {
    id: u32,
    offset: u32,
    base_id: u32,
    string_id: String,
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
    FIT = 0,
    GROW = 1,
    PERCENT = 2,
    FIXED = 3,
};

pub const SizingConstraints = extern union {
    size_minmax: SizingMinMax,
    size_percent: f32,
};

pub const LayoutDirection = enum(EnumBackingType) {
    LEFT_TO_RIGHT = 0,
    TOP_TO_BOTTOM = 1,
};

pub const LayoutAlignmentX = enum(EnumBackingType) {
    LEFT = 0,
    RIGHT = 1,
    CENTER = 2,
};

pub const LayoutAlignmentY = enum(EnumBackingType) {
    TOP = 0,
    BOTTOM = 1,
    CENTER = 2,
};

pub const ChildAlignment = extern struct {
    x: LayoutAlignmentX = .LEFT,
    y: LayoutAlignmentY = .TOP,

    pub const CENTER = ChildAlignment{ .x = .CENTER, .y = .CENTER };
};

pub const LayoutConfig = extern struct {
    /// sizing of the element
    sizing: Sizing = .{},
    /// padding arround children
    padding: Padding = .{},
    /// gap between the children
    child_gap: u16 = 0,
    /// alignement of the children
    child_alignment: ChildAlignment = .{},
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
    left: BorderData = .{},
    right: BorderData = .{},
    top: BorderData = .{},
    bottom: BorderData = .{},
    between_children: BorderData = .{},
    corner_radius: CornerRadius = .{},

    pub fn outside(color: Color, width: u32, radius: f32) BorderElementConfig {
        const data = BorderData{ .color = color, .width = width };
        return BorderElementConfig{
            .left = data,
            .right = data,
            .top = data,
            .bottom = data,
            .between_children = .{},
            .corner_radius = .all(radius),
        };
    }

    pub fn all(color: Color, width: u32, radius: f32) BorderElementConfig {
        const data = BorderData{ .color = color, .width = width };
        return BorderElementConfig{
            .left = data,
            .right = data,
            .top = data,
            .bottom = data,
            .between_children = data,
            .corner_radius = .all(radius),
        };
    }
};

pub const ImageElementConfig = extern struct {
    image_data: *const anyopaque,
    source_dimensions: Dimensions,
};

pub const CustomElementConfig = extern struct {
    custom_data: *anyopaque,
};

pub const ScrollElementConfig = extern struct {
    horizontal: bool = false,
    vertical: bool = false,
};

pub const ElementConfigType = enum(EnumBackingType) {
    rectangle_config = 1,
    border_config = 2,
    floating_config = 4,
    scroll_config = 8,
    image_config = 16,
    text_config = 32,
    custom_config = 64,
    // zig specific enum types
    id,
    layout_config,
};

pub const Config = union(ElementConfigType) {
    rectangle_config: *RectangleElementConfig,
    border_config: *BorderElementConfig,
    floating_config: *FloatingElementConfig,
    scroll_config: *ScrollElementConfig,
    image_config: *ImageElementConfig,
    text_config: *TextElementConfig,
    custom_config: *CustomElementConfig,
    id: ElementId,
    layout_config: *LayoutConfig,

    pub fn rectangle(config: RectangleElementConfig) Config {
        return Config{ .rectangle_config = cdefs.Clay__StoreRectangleElementConfig(config) };
    }
    pub fn border(config: BorderElementConfig) Config {
        return Config{ .border_config = cdefs.Clay__StoreBorderElementConfig(config) };
    }
    pub fn floating(config: FloatingElementConfig) Config {
        return Config{ .floating_config = cdefs.Clay__StoreFloatingElementConfig(config) };
    }
    pub fn scroll(config: ScrollElementConfig) Config {
        return Config{ .scroll_config = cdefs.Clay__StoreScrollElementConfig(config) };
    }
    pub fn image(config: ImageElementConfig) Config {
        return Config{ .image_config = cdefs.Clay__StoreImageElementConfig(config) };
    }
    pub fn text(config: TextElementConfig) Config {
        return Config{ .text_config = cdefs.Clay__StoreTextElementConfig(config) };
    }
    pub fn custom(config: CustomElementConfig) Config {
        return Config{ .custom_config = cdefs.Clay__StoreCustomElementConfig(config) };
    }
    pub fn ID(string: []const u8) Config {
        return Config{ .id = cdefs.Clay__HashString(makeClayString(string), 0, 0) };
    }
    pub fn IDI(string: []const u8, index: u32) Config {
        return Config{ .id = cdefs.Clay__HashString(makeClayString(string), index, 0) };
    }
    pub fn layout(config: LayoutConfig) Config {
        return Config{ .layout_config = cdefs.Clay__StoreLayoutConfig(config) };
    }
};

pub const minMemorySize = cdefs.Clay_MinMemorySize;
pub const setPointerState = cdefs.Clay_SetPointerState;
pub const initialize = cdefs.Clay_Initialize;
pub const getCurrentContext = cdefs.Clay_GetCurrentContext;
pub const setCurrentContext = cdefs.Clay_SetCurrentContext;
pub const updateScrollContainers = cdefs.Clay_UpdateScrollContainers;
pub const setLayoutDimensions = cdefs.Clay_SetLayoutDimensions;
pub const beginLayout = cdefs.Clay_BeginLayout;
pub const endLayout = cdefs.Clay_EndLayout;
pub const hovered = cdefs.Clay_Hovered;
pub const onHover = cdefs.Clay_OnHover;
pub const pointerOver = cdefs.Clay_PointerOver;
pub const getScrollContainerData = cdefs.Clay_GetScrollContainerData;
pub const setQueryScrollOffsetFunction = cdefs.Clay_SetQueryScrollOffsetFunction;
pub const renderCommandArrayGet = cdefs.Clay_RenderCommandArray_Get;
pub const setDebugModeEnabled = cdefs.Clay_SetDebugModeEnabled;
pub const isDebugModeEnabled = cdefs.Clay_IsDebugModeEnabled;
pub const setCullingEnabled = cdefs.Clay_SetCullingEnabled;
pub const getMaxElementCount = cdefs.Clay_GetMaxElementCount;
pub const setMaxElementCount = cdefs.Clay_SetMaxElementCount;
pub const getMaxMeasureTextCacheWordCount = cdefs.Clay_GetMaxMeasureTextCacheWordCount;
pub const setMaxMeasureTextCacheWordCount = cdefs.Clay_SetMaxMeasureTextCacheWordCount;
pub const resetMeasureTextCache = cdefs.Clay_ResetMeasureTextCache;

pub fn createArenaWithCapacityAndMemory(buffer: []u8) Arena {
    return cdefs.Clay_CreateArenaWithCapacityAndMemory(@intCast(buffer.len), buffer.ptr);
}

pub inline fn UI(configs: []const Config) fn (void) void {
    cdefs.Clay__OpenElement();
    for (configs) |config| {
        switch (config) {
            .layout_config => |layoutConf| cdefs.Clay__AttachLayoutConfig(layoutConf),
            .id => |id| cdefs.Clay__AttachId(id),
            inline else => |elem_config, tag| cdefs.Clay__AttachElementConfig(@unionInit(ElementConfigUnion, @tagName(tag), elem_config), config),
        }
    }
    cdefs.Clay__ElementPostConfiguration();
    return struct {
        fn f(_: void) void {
            cdefs.Clay__CloseElement();
        }
    }.f;
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
    cdefs.Clay__OpenTextElement(makeClayString(string), config.text_config);
}

pub fn ID(string: []const u8) ElementId {
    return cdefs.Clay__HashString(makeClayString(string), 0, 0);
}

pub fn IDI(string: []const u8, index: u32) ElementId {
    return cdefs.Clay__HashString(makeClayString(string), index, 0);
}

pub fn getElementId(string: []const u8) ElementId {
    return cdefs.Clay_GetElementId(makeClayString(string));
}

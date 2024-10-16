const std = @import("std");
const builtin = @import("builtin");

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

pub const RectangleElementConfig = extern struct {
    color: Color = .{ 255, 255, 255, 255 },
    corner_radius: CornerRadius = .{},
};

pub const TextWrapMode = enum(EnumBackingType) {
    Words,
    Newlines,
    None,
};

pub const TextElementConfig = extern struct {
    color: Color = .{ 0, 0, 0, 255 },
    font_id: u16 = 0,
    font_size: u16 = 20,
    letter_spacing: u16 = 0,
    line_spacing: u16 = 0,
    wrap_mode: TextWrapMode = .Newlines,
};

pub const ImageElementConfig = extern struct {
    image_data: *anyopaque,
    source_dimensions: Dimensions,
};

pub const CustomElementConfig = extern struct {
    custom_data: *anyopaque,
};

pub const BorderElementConfig = extern struct {
    left: BorderData,
    right: BorderData,
    top: BorderData,
    bottom: BorderData,
    between_children: BorderData,
    corner_radius: CornerRadius,
};

pub const ScrollElementConfig = extern struct {
    horizontal: bool,
    vertical: bool,
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

pub const FloatingElementConfig = extern struct {
    offset: Vector2,
    expand: Dimensions,
    z_index: u16,
    parent_id: u32,
    attachment: FloatingAttachPoints,
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
    scroll_position: *Vector2,
    scroll_container_dimensions: Dimensions,
    content_dimensions: Dimensions,
    config: ScrollElementConfig,
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
    constraints: SizingConstraints = .{ .size_percent = 100 },
    type: SizingType = .FIT,
};

pub const Sizing = extern struct {
    /// width
    w: SizingAxis = .{},
    /// height
    h: SizingAxis = .{},
};

pub const Padding = extern struct {
    x: u16 = 0,
    y: u16 = 0,
};

pub const LayoutDirection = enum(EnumBackingType) {
    LEFT_TO_RIGHT,
    TOP_TO_BOTTOM,
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
        internal_array: [*c]T,
    };
}

/// for direct calls to the clay c library
pub const extern_functions = struct {
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

    extern "c" fn Clay__OpenContainerElement(id: ElementId, layout_config: *LayoutConfig) void;
    extern "c" fn Clay__OpenRectangleElement(id: ElementId, layout_config: *LayoutConfig, rectangle_config: *RectangleElementConfig) void;
    extern "c" fn Clay__OpenTextElement(id: ElementId, text: String, text_config: *TextElementConfig) void;
    extern "c" fn Clay__OpenImageElement(id: ElementId, layout_config: *LayoutConfig, image_config: *ImageElementConfig) void;
    extern "c" fn Clay__OpenScrollElement(id: ElementId, layout_config: *LayoutConfig, scroll_config: *ScrollElementConfig) void;
    extern "c" fn Clay__OpenFloatingElement(id: ElementId, layout_config: *LayoutConfig, floating_config: *FloatingElementConfig) void;
    extern "c" fn Clay__OpenBorderElement(id: ElementId, layout_config: *LayoutConfig, border_config: *BorderElementConfig) void;
    extern "c" fn Clay__OpenCustomElement(id: ElementId, layout_config: *LayoutConfig, custom_config: *CustomElementConfig) void;
    extern "c" fn Clay__CloseElementWithChildren() void;
    extern "c" fn Clay__CloseScrollElement() void;
    extern "c" fn Clay__CloseFloatingElement() void;
    extern "c" fn Clay__StoreLayoutConfig(config: LayoutConfig) *LayoutConfig;
    extern "c" fn Clay__StoreRectangleElementConfig(config: RectangleElementConfig) *RectangleElementConfig;
    extern "c" fn Clay__StoreTextElementConfig(config: TextElementConfig) *TextElementConfig;
    extern "c" fn Clay__StoreImageElementConfig(config: ImageElementConfig) *ImageElementConfig;
    extern "c" fn Clay__StoreFloatingElementConfig(config: FloatingElementConfig) *FloatingElementConfig;
    extern "c" fn Clay__StoreCustomElementConfig(config: CustomElementConfig) *CustomElementConfig;
    extern "c" fn Clay__StoreScrollElementConfig(config: ScrollElementConfig) *ScrollElementConfig;
    extern "c" fn Clay__StoreBorderElementConfig(config: BorderElementConfig) *BorderElementConfig;
    extern "c" fn Clay__HashString(to_hash: String, index: u32) ElementId;
};

pub const minMemorySize = extern_functions.Clay_MinMemorySize;
pub const createArenaWithCapacityAndMemory = extern_functions.Clay_CreateArenaWithCapacityAndMemory;
pub const initialize = extern_functions.Clay_Initialize;
pub const setLayoutDimensions = extern_functions.Clay_SetLayoutDimensions;
pub const beginLayout = extern_functions.Clay_BeginLayout;
pub const endLayout = extern_functions.Clay_EndLayout;
pub const pointerOver = extern_functions.Clay_PointerOver;
pub const getScrollContainerData = extern_functions.Clay_GetScrollContainerData;
pub const renderCommandArrayGet = extern_functions.Clay_RenderCommandArray_Get;
pub const setDebugModeEnabled = extern_functions.Clay_SetDebugModeEnabled;

pub const container = extern_functions.Clay__OpenContainerElement;
pub const rectangle = extern_functions.Clay__OpenRectangleElement;
pub const image = extern_functions.Clay__OpenImageElement;
pub const scroll = extern_functions.Clay__OpenScrollElement;
pub const floating = extern_functions.Clay__OpenFloatingElement;
pub const border = extern_functions.Clay__OpenBorderElement;
pub const customElement = extern_functions.Clay__OpenCustomElement;
pub const closeParent = extern_functions.Clay__CloseElementWithChildren;
pub const closeScroll = extern_functions.Clay__CloseScrollElement;
pub const closeFloating = extern_functions.Clay__CloseFloatingElement;
pub const layout = extern_functions.Clay__StoreLayoutConfig;
pub const rectangleConfig = extern_functions.Clay__StoreRectangleElementConfig;
pub const textConfig = extern_functions.Clay__StoreTextElementConfig;
pub const imageConfig = extern_functions.Clay__StoreImageElementConfig;
pub const floatingConfig = extern_functions.Clay__StoreFloatingElementConfig;
pub const customConfig = extern_functions.Clay__StoreCustomElementConfig;
pub const scrollConfig = extern_functions.Clay__StoreScrollElementConfig;
pub const borderConfig = extern_functions.Clay__StoreBorderElementConfig;
pub const hashString = extern_functions.Clay__HashString;

pub fn setPointerState(position: Vector2, pointer_down: bool) void {
    extern_functions.Clay_SetPointerState(position, pointer_down);
}

pub fn updateScrollContainers(is_pointer_active: bool, scroll_delta: Vector2, delta_time: f32) void {
    extern_functions.Clay_UpdateScrollContainers(is_pointer_active, scroll_delta, delta_time);
}

pub fn setMeasureTextFunction(comptime measureTextFunction: fn ([]const u8, *TextElementConfig) Dimensions) void {
    extern_functions.Clay_SetMeasureTextFunction(struct {
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

pub fn text(id: ElementId, string: []const u8, config: *TextElementConfig) void {
    extern_functions.Clay__OpenTextElement(id, makeClayString(string), config);
}

pub fn ID(string: []const u8) ElementId {
    return hashString(makeClayString(string), 0);
}

pub fn IDI(string: []const u8, index: u32) ElementId {
    return hashString(makeClayString(string), index);
}

pub fn sizingGrow(size_minmax: SizingConstraintsMinMax) SizingAxis {
    return .{ .type = .GROW, .constraints = .{ .size_minmax = size_minmax } };
}

pub fn sizingFixed(size: f32) SizingAxis {
    return .{ .type = .FIT, .constraints = .{ .size_minmax = .{ .max = size, .min = size } } };
}

pub fn sizingPercent(size_percent: f32) SizingAxis {
    return .{ .type = .PERCENT, .constraints = .{ .size_percent = size_percent } };
}

pub fn sizingFit(size_minmax: SizingConstraintsMinMax) SizingAxis {
    return .{ .type = SizingType.FIT, .constraints = .{ .size_minmax = size_minmax } };
}

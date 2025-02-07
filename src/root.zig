const std = @import("std");
const builtin = @import("builtin");

pub extern var CLAY_LAYOUT_DEFAULT: LayoutConfig;
pub extern var Clay__debugViewHighlightColor: Color;
pub extern var Clay__debugViewWidth: u32;

/// for direct calls to the clay c library
pub const cdefs = struct {
    // TODO: should use @extern instead but zls does not yet support it well and that is more important
    pub extern fn Clay_GetElementData(id: ElementId) ElementData;
    pub extern fn Clay_MinMemorySize() u32;
    pub extern fn Clay_CreateArenaWithCapacityAndMemory(capacity: u32, offset: ?*anyopaque) Arena;
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
    pub extern fn Clay_OnHover(onHoverFunction: *const fn (ElementId, PointerData, ?*anyopaque) callconv(.c) void, userData: ?*anyopaque) void;
    pub extern fn Clay_PointerOver(elementId: ElementId) bool;
    pub extern fn Clay_GetScrollContainerData(id: ElementId) ScrollContainerData;
    pub extern fn Clay_SetMeasureTextFunction(measureTextFunction: *const fn (StringSlice, *TextElementConfig, ?*anyopaque) callconv(.c) Dimensions, userData: ?*anyopaque) void;
    pub extern fn Clay_SetQueryScrollOffsetFunction(queryScrollOffsetFunction: *const fn (u32, ?*anyopaque) callconv(.c) Vector2, userData: ?*anyopaque) void;
    pub extern fn Clay_RenderCommandArray_Get(array: *ClayArray(RenderCommand), index: i32) *RenderCommand;
    pub extern fn Clay_SetDebugModeEnabled(enabled: bool) void;
    pub extern fn Clay_IsDebugModeEnabled() bool;
    pub extern fn Clay_SetCullingEnabled(enabled: bool) void;
    pub extern fn Clay_GetMaxElementCount() i32;
    pub extern fn Clay_SetMaxElementCount(maxElementCount: i32) void;
    pub extern fn Clay_GetMaxMeasureTextCacheWordCount() i32;
    pub extern fn Clay_SetMaxMeasureTextCacheWordCount(maxMeasureTextCacheWordCount: i32) void;
    pub extern fn Clay_ResetMeasureTextCache() void;

    pub extern fn Clay__ConfigureOpenElement(config: ElementDeclaration) void;
    pub extern fn Clay__OpenElement() void;
    pub extern fn Clay__CloseElement() void;
    pub extern fn Clay__StoreLayoutConfig(config: LayoutConfig) *LayoutConfig;
    pub extern fn Clay__AttachId(id: ElementId) ElementId;
    pub extern fn Clay__StoreTextElementConfig(config: TextElementConfig) *TextElementConfig;
    pub extern fn Clay__HashString(key: String, offset: u32, seed: u32) ElementId;
    pub extern fn Clay__OpenTextElement(text: String, textConfig: *TextElementConfig) void;
    pub extern fn Clay__GetParentElementId() u32;
};

pub const EnumBackingType = u8;

pub const String = extern struct {
    length: i32,
    chars: [*]const u8,
};

pub const StringSlice = extern struct {
    length: i32 = 0,
    chars: [*]const u8,
    base_chars: [*]const u8,
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

/// order: r, g, b, a
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
    type: SizingType = .fit,

    pub const grow = SizingAxis{ .type = .grow, .size = .{ .minmax = .{ .min = 0, .max = 0 } } };
    pub const fit = SizingAxis{ .type = .fit, .size = .{ .minmax = .{ .min = 0, .max = 0 } } };

    pub fn growMinMax(size_minmax: SizingMinMax) SizingAxis {
        return .{ .type = .grow, .size = .{ .minmax = size_minmax } };
    }

    pub fn fitMinMax(size_minmax: SizingMinMax) SizingAxis {
        return .{ .type = .fit, .size = .{ .minmax = size_minmax } };
    }

    pub fn fixed(size: f32) SizingAxis {
        return .{ .type = .fixed, .size = .{ .minmax = .{ .max = size, .min = size } } };
    }

    pub fn percent(size_percent: f32) SizingAxis {
        return .{ .type = .percent, .size = .{ .percent = size_percent } };
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
    left: u16 = 0,
    right: u16 = 0,
    top: u16 = 0,
    bottom: u16 = 0,

    pub fn xy(vertical_padding: u16, horizontal_padding: u16) Padding {
        return .{
            .top = vertical_padding,
            .bottom = vertical_padding,
            .left = horizontal_padding,
            .right = horizontal_padding,
        };
    }

    pub fn all(size: u16) Padding {
        return Padding{
            .left = size,
            .right = size,
            .top = size,
            .bottom = size,
        };
    }
};

pub const TextElementConfigWrapMode = enum(EnumBackingType) {
    words = 0,
    new_lines = 1,
    none = 2,
};

pub const TextElementConfig = extern struct {
    color: Color = .{ 0, 0, 0, 255 },
    font_id: u16 = 0,
    font_size: u16 = 20,
    letter_spacing: u16 = 0,
    line_height: u16 = 0,
    wrap_mode: TextElementConfigWrapMode = .words,
    hash_string_contents: bool = false,
};

pub const FloatingAttachPointType = enum(EnumBackingType) {
    left_top = 0,
    left_center = 1,
    left_bottom = 2,
    center_top = 3,
    center_center = 4,
    center_bottom = 5,
    right_top = 6,
    right_center = 7,
    right_bottom = 8,
};

pub const FloatingAttachPoints = extern struct {
    element: FloatingAttachPointType,
    parent: FloatingAttachPointType,
};

pub const FloatingAttachToElement = enum(EnumBackingType) {
    to_none = 0,
    to_parent = 1,
    to_element_with_id = 2,
    to_root = 3,
};

pub const PointerCaptureMode = enum(EnumBackingType) {
    capture = 0,
    passthrough = 1,
};

pub const FloatingElementConfig = extern struct {
    offset: Vector2 = .{ .x = 0, .y = 0 },
    expand: Dimensions = .{ .w = 0, .h = 0 },
    parentId: u32 = 0,
    zIndex: i16 = 0,
    attach_points: FloatingAttachPoints = .{ .element = .left_top, .parent = .left_top },
    pointer_capture_mode: PointerCaptureMode = .capture,
    attach_to: FloatingAttachToElement = .to_none,
};

pub const RenderCommandType = enum(EnumBackingType) {
    none = 0,
    rectangle = 1,
    border = 2,
    text = 3,
    image = 4,
    scissor_start = 5,
    scissor_end = 6,
    custom = 7,
};

pub const PointerDataInteractionState = enum(EnumBackingType) {
    pressed_this_frame = 0,
    pressed = 1,
    released_this_frame = 2,
    released = 3,
};

pub const PointerData = extern struct {
    position: Vector2,
    state: PointerDataInteractionState,
};

pub const ErrorType = enum(EnumBackingType) {
    text_measurement_function_not_provided = 0,
    arena_capacity_exceeded = 1,
    elements_capacity_exceeded = 2,
    text_measurement_capacity_exceeded = 3,
    duplicate_id = 4,
    floating_container_parent_not_found = 5,
    internal_error = 6,
};

pub const ErrorData = extern struct {
    error_type: ErrorType,
    error_text: String,
    user_data: ?*anyopaque,
};

pub const ErrorHandler = extern struct {
    error_handler_function: ?*const fn (ErrorData) callconv(.c) void = null,
    user_data: ?*anyopaque = null,
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

pub const ElementId = extern struct {
    id: u32,
    offset: u32,
    base_id: u32,
    string_id: String,

    pub fn ID(string: []const u8) ElementId {
        return cdefs.Clay__HashString(makeClayString(string), 0, 0);
    }

    pub fn IDI(string: []const u8, index: u32) ElementId {
        return cdefs.Clay__HashString(makeClayString(string), index, 0);
    }

    pub fn localID(string: []const u8) ElementId {
        return cdefs.Clay__HashString(makeClayString(string), 0, cdefs.Clay__GetParentElementId());
    }

    pub fn localIDI(string: []const u8, index: u32) ElementId {
        return cdefs.Clay__HashString(makeClayString(string), index, cdefs.Clay__GetParentElementId());
    }
};

pub const RenderCommand = extern struct {
    bounding_box: BoundingBox,
    render_data: RenderData,
    user_data: *anyopaque,
    id: u32,
    z_index: i16,
    command_type: RenderCommandType,
};

pub const SizingType = enum(EnumBackingType) {
    fit = 0,
    grow = 1,
    percent = 2,
    fixed = 3,
};

pub const LayoutDirection = enum(EnumBackingType) {
    left_to_right = 0,
    top_to_bottom = 1,
};

pub const LayoutAlignmentX = enum(EnumBackingType) {
    left = 0,
    right = 1,
    center = 2,
};

pub const LayoutAlignmentY = enum(EnumBackingType) {
    top = 0,
    bottom = 1,
    center = 2,
};

pub const ChildAlignment = extern struct {
    x: LayoutAlignmentX = .left,
    y: LayoutAlignmentY = .top,

    pub const center = ChildAlignment{ .x = .center, .y = .center };
};

pub const LayoutConfig = extern struct {
    /// sizing of the element
    sizing: Sizing = .{},
    /// padding arround children
    padding: Padding = .{},
    /// gap between the children
    child_gap: u16 = 0,
    /// alignment of the children
    child_alignment: ChildAlignment = .{},
    /// direction of the children's layout
    direction: LayoutDirection = .left_to_right,
};

pub fn ClayArray(comptime T: type) type {
    return extern struct {
        capacity: u32,
        length: u32,
        internal_array: [*]T,
    };
}

pub const BorderWidth = extern struct {
    left: u16 = 0,
    right: u16 = 0,
    top: u16 = 0,
    bottom: u16 = 0,
    between_children: u16 = 0,

    pub fn outside(width: u16) BorderWidth {
        return .{
            .left = width,
            .right = width,
            .top = width,
            .bottom = width,
            .between_children = 0,
        };
    }

    pub fn all(width: u16) BorderWidth {
        return .{
            .left = width,
            .right = width,
            .top = width,
            .bottom = width,
            .between_children = width,
        };
    }
};

pub const BorderElementConfig = extern struct {
    color: Color = .{ 0, 0, 0, 255 },
    width: BorderWidth = .{},
};

pub const TextRenderData = extern struct {
    string_contents: StringSlice,
    text_color: Color,
    font_id: u16,
    font_size: u16,
    letter_spacing: u16,
    line_height: u16,
};

pub const RectangleRenderData = extern struct {
    background_color: Color,
    corner_radius: CornerRadius,
};

pub const ImageRenderData = extern struct {
    background_color: Color,
    corner_radius: CornerRadius,
    source_dimensions: Dimensions,
    image_data: ?*anyopaque,
};

pub const CustomRenderData = extern struct {
    background_color: Color,
    corner_radius: CornerRadius,
    custom_data: ?*anyopaque,
};

pub const ImageElementConfig = extern struct {
    image_data: ?*const anyopaque,
    source_dimensions: Dimensions,
};

pub const BorderRenderData = extern struct {
    color: Color,
    corner_radius: CornerRadius,
    width: BorderWidth,
};

pub const RenderData = extern union {
    rectangle: RectangleRenderData,
    text: TextRenderData,
    image: ImageRenderData,
    custom: CustomRenderData,
    border: BorderRenderData,
};

pub const CustomElementConfig = extern struct {
    custom_data: ?*anyopaque = null,
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

pub const ElementData = extern struct {
    bounding_box: BoundingBox,
    found: bool,
};

pub const ScrollElementConfig = extern struct {
    horizontal: bool = false,
    vertical: bool = false,
};

pub const SharedElementConfig = extern struct {
    backgroundColor: Color,
    cornerRadius: CornerRadius,
    userData: ?*anyopaque,
};

pub const ElementConfigType = enum(EnumBackingType) {
    none = 0,
    border = 1,
    floating = 2,
    scroll = 3,
    image = 4,
    text = 5,
    custom = 6,
    shared = 7,
};

pub const ElementDeclaration = extern struct {
    id: ElementId = .{ .base_id = 0, .id = 0, .offset = 0, .string_id = .{ .chars = undefined, .length = 0 } },
    layout: LayoutConfig = .{},
    background_color: Color = .{ 0, 0, 0, 0 },
    corner_radius: CornerRadius = .{},
    image: ImageElementConfig = .{ .image_data = null, .source_dimensions = .{ .h = 0, .w = 0 } },
    floating: FloatingElementConfig = .{},
    custom: CustomElementConfig = .{},
    scroll: ScrollElementConfig = .{},
    border: BorderElementConfig = .{},
    user_data: ?*anyopaque = null,
};

pub inline fn UI() fn (config: ElementDeclaration) callconv(.@"inline") fn (void) void {
    const local = struct {
        fn CloseElement(_: void) void {
            cdefs.Clay__CloseElement();
        }

        inline fn ConfigureOpenElement(config: ElementDeclaration) fn (void) void {
            cdefs.Clay__ConfigureOpenElement(config);
            return CloseElement;
        }
    };

    cdefs.Clay__OpenElement();
    return local.ConfigureOpenElement;
}

pub const getElementData = cdefs.Clay_GetElementData;
pub const minMemorySize = cdefs.Clay_MinMemorySize;
pub const setPointerState = cdefs.Clay_SetPointerState;
pub const initialize = cdefs.Clay_Initialize;
pub const getCurrentContext = cdefs.Clay_GetCurrentContext;
pub const setCurrentContext = cdefs.Clay_SetCurrentContext;
pub const updateScrollContainers = cdefs.Clay_UpdateScrollContainers;
pub const setLayoutDimensions = cdefs.Clay_SetLayoutDimensions;
pub const beginLayout = cdefs.Clay_BeginLayout;
pub const endLayout = cdefs.Clay_EndLayout;
pub const getElementIdWithIndex = cdefs.Clay_GetElementIdWithIndex;
pub const hovered = cdefs.Clay_Hovered;
pub const pointerOver = cdefs.Clay_PointerOver;
pub const getScrollContainerData = cdefs.Clay_GetScrollContainerData;
pub const renderCommandArrayGet = cdefs.Clay_RenderCommandArray_Get;
pub const setDebugModeEnabled = cdefs.Clay_SetDebugModeEnabled;
pub const isDebugModeEnabled = cdefs.Clay_IsDebugModeEnabled;
pub const setCullingEnabled = cdefs.Clay_SetCullingEnabled;
pub const getMaxElementCount = cdefs.Clay_GetMaxElementCount;
pub const setMaxElementCount = cdefs.Clay_SetMaxElementCount;
pub const getMaxMeasureTextCacheWordCount = cdefs.Clay_GetMaxMeasureTextCacheWordCount;
pub const setMaxMeasureTextCacheWordCount = cdefs.Clay_SetMaxMeasureTextCacheWordCount;
pub const resetMeasureTextCache = cdefs.Clay_ResetMeasureTextCache;

/// `context` must be of same size as a pointer or be of type `void`
pub fn onHover(
    user_data: anytype,
    comptime onHoverFunction: fn (
        element_id: ElementId,
        pointer_data: PointerData,
        context: @TypeOf(user_data),
    ) void,
) void {
    if (!(@TypeOf(user_data) == void) and @sizeOf(@TypeOf(user_data)) != @sizeOf(usize))
        @compileError("`context` must be of same size as a pointer or be of type `void`");

    cdefs.Clay_OnHover(
        struct {
            pub fn f(element_id: ElementId, pointer_data: PointerData, userData: ?*anyopaque) callconv(.C) void {
                onHoverFunction(
                    element_id,
                    pointer_data,
                    AnyopaquePtrToAnytype(@TypeOf(user_data), userData),
                );
            }
        }.f,
        anytypeToAnyopaquePtr(user_data),
    );
}

/// `context` must be of same size as a pointer or be of type `void`
pub fn setMeasureTextFunction(
    user_data: anytype,
    comptime measureTextFunction: fn (
        []const u8,
        *TextElementConfig,
        context: @TypeOf(user_data),
    ) Dimensions,
) void {
    if (!(@TypeOf(user_data) == void) and @sizeOf(@TypeOf(user_data)) != @sizeOf(usize))
        @compileError("`context` must be of same size as a pointer or be of type `void`");

    cdefs.Clay_SetMeasureTextFunction(
        struct {
            pub fn f(string: StringSlice, config: *TextElementConfig, userData: ?*anyopaque) callconv(.c) Dimensions {
                return measureTextFunction(
                    string.chars[0..@intCast(string.length)],
                    config,
                    AnyopaquePtrToAnytype(@TypeOf(user_data), userData),
                );
            }
        }.f,
        anytypeToAnyopaquePtr(user_data),
    );
}

/// `context` must be of same size as a pointer or be of type `void`
pub fn setQueryScrollOffsetFunction(
    user_data: anytype,
    comptime queryScrollOffsetFunction: fn (
        u32,
        @TypeOf(user_data),
    ) Vector2,
) void {
    if (!(@TypeOf(user_data) == void) and @sizeOf(@TypeOf(user_data)) != @sizeOf(usize))
        @compileError("`context` must be of same size as a pointer or be of type `void`");

    cdefs.Clay_SetQueryScrollOffsetFunction(
        struct {
            pub fn f(scroll: u32, userData: ?*anyopaque) callconv(.c) Dimensions {
                return queryScrollOffsetFunction(
                    scroll,
                    AnyopaquePtrToAnytype(@TypeOf(user_data), userData),
                );
            }
        }.f,
        anytypeToAnyopaquePtr(user_data),
    );
}

pub fn createArenaWithCapacityAndMemory(buffer: []u8) Arena {
    return cdefs.Clay_CreateArenaWithCapacityAndMemory(@intCast(buffer.len), buffer.ptr);
}

pub fn makeClayString(string: []const u8) String {
    return .{
        .chars = @ptrCast(@constCast(string)),
        .length = @intCast(string.len),
    };
}

pub fn text(string: []const u8, config: TextElementConfig) void {
    cdefs.Clay__OpenTextElement(makeClayString(string), cdefs.Clay__StoreTextElementConfig(config));
}

pub fn getElementId(string: []const u8) ElementId {
    return cdefs.Clay_GetElementId(makeClayString(string));
}

fn anytypeToAnyopaquePtr(user_data: anytype) ?*anyopaque {
    if (@TypeOf(user_data) == void) {
        return null;
    } else if (@typeInfo(@TypeOf(user_data)) == .pointer) {
        return @ptrCast(@alignCast(@constCast(user_data)));
    } else {
        return @ptrFromInt(@as(usize, @bitCast(user_data)));
    }
}

fn AnyopaquePtrToAnytype(T: type, userData: ?*anyopaque) T {
    if (T == void) {
        return {};
    } else if (@typeInfo(T) == .pointer) {
        return @ptrCast(@alignCast(@constCast(userData)));
    } else {
        return @bitCast(@as(usize, @intFromPtr(userData)));
    }
}

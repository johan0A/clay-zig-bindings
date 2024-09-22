const std = @import("std");
const builtin = @import("builtin");

pub const String = extern struct {
    length: c_int,
    chars: [*]c_char,
};

pub const Vector2 = [2]f32;

pub const Dimensions = extern struct {
    width: f32,
    height: f32,
};

pub const Arena = extern struct {
    label: String,
    nextAllocation: u64,
    capacity: u64,
    memory: [*]c_char,
};

pub const BoundingBox = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub const Color = [4]f32;

pub const CornerRadius = extern struct {
    topLeft: f32 = 0,
    topRight: f32 = 0,
    bottomLeft: f32 = 0,
    bottomRight: f32 = 0,
};

pub const BorderData = extern struct {
    width: u32 = 0,
    color: Color = .{ 255, 255, 255, 255 },
};

pub const ElementId = extern struct {
    id: u32,
    offset: u32,
    baseId: u32,
    stringId: String,
};

pub const EnumBackingType = if (builtin.os.tag == .windows) u32 else u8;

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
    cornerRadius: CornerRadius = .{},
};

pub const TextWrapMode = enum(EnumBackingType) {
    Words,
    Newlines,
    None,
};

pub const TextElementConfig = extern struct {
    textColor: Color = .{ 0, 0, 0, 255 },
    fontId: u16 = 0,
    fontSize: u16 = 20,
    letterSpacing: u16 = 0,
    lineSpacing: u16 = 0,
    wrapMode: TextWrapMode = .Newlines,
};

pub const ImageElementConfig = extern struct {
    imageData: *anyopaque,
    sourceDimensions: Dimensions,
};

pub const CustomElementConfig = extern struct {
    customData: *anyopaque,
};

pub const BorderElementConfig = extern struct {
    left: BorderData,
    right: BorderData,
    top: BorderData,
    bottom: BorderData,
    betweenChildren: BorderData,
    cornerRadius: CornerRadius,
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
    zIndex: u16,
    parentId: u32,
    attachment: FloatingAttachPoints,
};

pub const ElementConfigUnion = extern union {
    rectangleElementConfig: *RectangleElementConfig,
    textElementConfig: *TextElementConfig,
    imageElementConfig: *ImageElementConfig,
    customElementConfig: *CustomElementConfig,
    borderElementConfig: *BorderElementConfig,
};

pub const RenderCommand = extern struct {
    boundingBox: BoundingBox,
    config: ElementConfigUnion,
    text: String,
    id: u32,
    commandType: RenderCommandType,
};

pub const ScrollContainerData = extern struct {
    scrollPosition: *Vector2,
    scrollContainerDimensions: Dimensions,
    contentDimensions: Dimensions,
    config: ScrollElementConfig,
    found: bool,
};

pub const SizingType = enum(EnumBackingType) {
    FIT,
    GROW,
    PERCENT,
};

pub const SizingConstraintsMinMax = extern struct {
    min: f32 = 0,
    max: f32 = 0,
};

pub const SizingConstraints = extern union {
    sizeMinMax: SizingConstraintsMinMax,
    sizePercent: f32,
};

pub const SizingAxis = extern struct {
    constraints: SizingConstraints = .{ .sizePercent = 100 },
    type: SizingType = .FIT,
};

pub const Sizing = extern struct {
    width: SizingAxis = .{},
    height: SizingAxis = .{},
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
    sizing: Sizing = .{
        .height = .{ .constraints = .{ .sizePercent = 100 }, .type = .GROW },
        .width = .{ .constraints = .{ .sizePercent = 100 }, .type = .GROW },
    },
    padding: Padding = .{},
    childGap: u16 = 0,
    layoutDirection: LayoutDirection = .LEFT_TO_RIGHT,
    childAlignment: ChildAlignment = .{},
};

pub fn ClayArray(comptime T: type) type {
    return extern struct {
        capacity: u32,
        length: u32,
        internalArray: [*]T,
    };
}

const extern_elements = struct {
    // TODO: should use @extern instead but zls does not yet support it well
    extern "c" fn Clay_MinMemorySize() u32;
    extern "c" fn Clay_CreateArenaWithCapacityAndMemory(capacity: u32, offset: [*]u8) Arena;
    extern "c" fn Clay_SetPointerState(position: [*]f32, pointerDown: bool) void;
    extern "c" fn Clay_Initialize(arena: Arena, layoutDimensions: Dimensions) void;
    extern "c" fn Clay_UpdateScrollContainers(isPointerActive: bool, scrollDelta: [*]f32, deltaTime: f32) void;
    extern "c" fn Clay_SetLayoutDimensions(dimensions: Dimensions) void;
    extern "c" fn Clay_BeginLayout() void;
    extern "c" fn Clay_EndLayout() ClayArray(RenderCommand);
    extern "c" fn Clay_PointerOver(id: ElementId) bool;
    extern "c" fn Clay_GetScrollContainerData(id: ElementId) ScrollContainerData;
    extern "c" fn Clay_SetMeasureTextFunction(measureTextFunction: *const fn (*String, *TextElementConfig) callconv(.C) Dimensions) void;
    extern "c" fn Clay_RenderCommandArray_Get(array: *ClayArray(RenderCommand), index: i32) *RenderCommand;
    extern "c" fn Clay_SetDebugModeEnabled(enabled: bool) void;

    extern "c" fn Clay__OpenContainerElement(id: ElementId, layoutConfig: *LayoutConfig) void;
    extern "c" fn Clay__OpenRectangleElement(id: ElementId, layoutConfig: *LayoutConfig, rectangleConfig: *RectangleElementConfig) void;
    extern "c" fn Clay__OpenTextElement(id: ElementId, text: String, textConfig: *TextElementConfig) void;
    extern "c" fn Clay__OpenImageElement(id: ElementId, layoutConfig: *LayoutConfig, imageConfig: *ImageElementConfig) void;
    extern "c" fn Clay__OpenScrollElement(id: ElementId, layoutConfig: *LayoutConfig, scrollConfig: *ScrollElementConfig) void;
    extern "c" fn Clay__OpenFloatingElement(id: ElementId, layoutConfig: *LayoutConfig, floatingConfig: *FloatingElementConfig) void;
    extern "c" fn Clay__OpenBorderElement(id: ElementId, layoutConfig: *LayoutConfig, borderConfig: *BorderElementConfig) void;
    extern "c" fn Clay__OpenCustomElement(id: ElementId, layoutConfig: *LayoutConfig, customConfig: *CustomElementConfig) void;
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
    extern "c" fn Clay__HashString(toHash: String, index: u32) ElementId;
};

pub const minMemorySize = extern_elements.Clay_MinMemorySize;
pub const createArenaWithCapacityAndMemory = extern_elements.Clay_CreateArenaWithCapacityAndMemory;
pub const initialize = extern_elements.Clay_Initialize;
pub const setLayoutDimensions = extern_elements.Clay_SetLayoutDimensions;
pub const beginLayout = extern_elements.Clay_BeginLayout;
pub const endLayout = extern_elements.Clay_EndLayout;
pub const pointerOver = extern_elements.Clay_PointerOver;
pub const getScrollContainerData = extern_elements.Clay_GetScrollContainerData;
pub const setMeasureTextFunction = extern_elements.Clay_SetMeasureTextFunction;
pub const renderCommandArray_Get = extern_elements.Clay_RenderCommandArray_Get;
pub const setDebugModeEnabled = extern_elements.Clay_SetDebugModeEnabled;

pub const rontainer = extern_elements.Clay__OpenContainerElement;
pub const rectangle = extern_elements.Clay__OpenRectangleElement;
pub const image = extern_elements.Clay__OpenImageElement;
pub const scroll = extern_elements.Clay__OpenScrollElement;
pub const floating = extern_elements.Clay__OpenFloatingElement;
pub const border = extern_elements.Clay__OpenBorderElement;
pub const customElement = extern_elements.Clay__OpenCustomElement;
pub const closeParent = extern_elements.Clay__CloseElementWithChildren;
pub const closeScroll = extern_elements.Clay__CloseScrollElement;
pub const closeFloating = extern_elements.Clay__CloseFloatingElement;
pub const layout = extern_elements.Clay__StoreLayoutConfig;
pub const rectangleConfig = extern_elements.Clay__StoreRectangleElementConfig;
pub const textConfig = extern_elements.Clay__StoreTextElementConfig;
pub const imageConfig = extern_elements.Clay__StoreImageElementConfig;
pub const floatingConfig = extern_elements.Clay__StoreFloatingElementConfig;
pub const customConfig = extern_elements.Clay__StoreCustomElementConfig;
pub const scrollConfig = extern_elements.Clay__StoreScrollElementConfig;
pub const borderConfig = extern_elements.Clay__StoreBorderElementConfig;
pub const hashString = extern_elements.Clay__HashString;

pub fn setPointerState(position: Vector2, pointerDown: bool) void {
    extern_elements.Clay_SetPointerState(@ptrCast(@constCast(&position)), pointerDown);
}

pub fn updateScrollContainers(isPointerActive: bool, scrollDelta: Vector2, deltaTime: f32) void {
    extern_elements.Clay_UpdateScrollContainers(isPointerActive, @ptrCast(@constCast(&scrollDelta)), deltaTime);
}

pub fn text(id: ElementId, string: []const u8, config: *TextElementConfig) void {
    extern_elements.Clay__OpenTextElement(id, .{
        .chars = @ptrCast(@constCast(string)),
        .length = @intCast(string.len),
    }, config);
}

fn measureText(str: *String, conf: *TextElementConfig) callconv(.C) Dimensions {
    _ = str;
    _ = conf;
    return Dimensions{
        .height = 10,
        .width = 10,
    };
}

test {
    const allocator = std.testing.allocator;

    const min_memory_size: u32 = minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);
    const arena: Arena = createArenaWithCapacityAndMemory(min_memory_size, @ptrCast(memory));
    setMeasureTextFunction(measureText);
    initialize(arena, .{ .width = 1000, .height = 1000 });

    beginLayout();

    {
        rectangle(
            ID("name"),
            layout(.{}),
            rectangleConfig(.{}),
        );
        defer closeParent();
    }

    const _layout = endLayout();
    std.debug.print("{any}", .{_layout.internalArray[0..1]});
}

pub fn ID(name: []const u8) ElementId {
    return hashString(.{
        .chars = @ptrCast(@constCast(name)),
        .length = @intCast(name.len),
    }, 0);
}

pub fn IDI(name: []const u8, index: u32) ElementId {
    return hashString(.{
        .chars = @ptrCast(@constCast(name)),
        .length = @intCast(name.len),
    }, index);
}

pub fn sizingGrow(sizeMinMax: SizingConstraintsMinMax) SizingAxis {
    return .{ .type = .GROW, .constraints = .{ .sizeMinMax = sizeMinMax } };
}

pub fn sizingFixed(size: f32) SizingAxis {
    return SizingAxis{ .type = .FIT, .constraints = .{ .sizeMinMax = .{ .max = size, .min = size } } };
}

pub fn SizingPercent(sizePercent: f32) SizingAxis {
    return .{ .type = .PERCENT, .constraints = .{ .sizePercent = sizePercent } };
}

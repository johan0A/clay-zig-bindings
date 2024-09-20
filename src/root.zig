const std = @import("std");
const builtin = @import("builtin");

const c = @cImport({
    @cInclude("stdint.h");
    @cInclude("stdbool.h");
});

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
    topLeft: f32,
    topRight: f32,
    bottomLeft: f32,
    bottomRight: f32,
};

pub const BorderData = extern struct {
    width: u32,
    color: Color,
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
    color: Color,
    cornerRadius: CornerRadius,
};

pub const TextWrapMode = enum(EnumBackingType) {
    Words,
    Newlines,
    None,
};

pub const TextElementConfig = extern struct {
    textColor: Color,
    fontId: u16,
    fontSize: u16,
    letterSpacing: u16,
    lineSpacing: u16,
    wrapMode: TextWrapMode,
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
    min: f32,
    max: f32,
};

pub const SizingConstraints = extern union {
    sizeMinMax: SizingConstraintsMinMax,
    sizePercent: f32,
};

pub const SizingAxis = extern struct {
    constraints: SizingConstraints,
    type: SizingType,
};

pub const Sizing = extern struct {
    width: SizingAxis,
    height: SizingAxis,
};

pub const Padding = extern struct {
    x: u16,
    y: u16,
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
    x: LayoutAlignmentX,
    y: LayoutAlignmentY,
};

pub const LayoutConfig = extern struct {
    sizing: Sizing,
    padding: Padding,
    childGap: u16,
    layoutDirection: LayoutDirection,
    childAlignment: ChildAlignment,
};

pub fn ClayArray(comptime T: type) type {
    return extern struct {
        capacity: u32,
        length: u32,
        internalArray: [*]T,
    };
}

const extern_elements = struct {
    // Foreign function declarations
    extern "c" fn Clay_MinMemorySize() u32;
    extern "c" fn Clay_CreateArenaWithCapacityAndMemory(capacity: u32, offset: [*]u8) Arena;
    extern "c" fn Clay_SetPointerState(position: Vector2, pointerDown: bool) void;
    extern "c" fn Clay_Initialize(arena: Arena, layoutDimensions: Dimensions) void;
    extern "c" fn Clay_UpdateScrollContainers(isPointerActive: bool, scrollDelta: Vector2, deltaTime: f32) void;
    extern "c" fn Clay_SetLayoutDimensions(dimensions: Dimensions) void;
    extern "c" fn Clay_BeginLayout() void;
    extern "c" fn Clay_EndLayout() ClayArray(RenderCommand);
    extern "c" fn Clay_PointerOver(id: ElementId) bool;
    extern "c" fn Clay_GetScrollContainerData(id: ElementId) ScrollContainerData;
    extern "c" fn Clay_SetMeasureTextFunction(measureTextFunction: *const fn (*String, *TextElementConfig) callconv(.C) Dimensions) void;
    extern "c" fn Clay_RenderCommandArray_Get(array: *ClayArray(RenderCommand), index: i32) *RenderCommand;
    extern "c" fn Clay_SetDebugModeEnabled(enabled: bool) void;

    // Private external functions
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
    extern "c" fn Clay__LayoutConfigArray_Add(array: *ClayArray(LayoutConfig), config: LayoutConfig) *LayoutConfig;
    extern "c" fn Clay__RectangleElementConfigArray_Add(array: *ClayArray(RectangleElementConfig), config: RectangleElementConfig) *RectangleElementConfig;
    extern "c" fn Clay__TextElementConfigArray_Add(array: *ClayArray(TextElementConfig), config: TextElementConfig) *TextElementConfig;
    extern "c" fn Clay__ImageElementConfigArray_Add(array: *ClayArray(ImageElementConfig), config: ImageElementConfig) *ImageElementConfig;
    extern "c" fn Clay__FloatingElementConfigArray_Add(array: *ClayArray(FloatingElementConfig), config: FloatingElementConfig) *FloatingElementConfig;
    extern "c" fn Clay__CustomElementConfigArray_Add(array: *ClayArray(CustomElementConfig), config: CustomElementConfig) *CustomElementConfig;
    extern "c" fn Clay__ScrollElementConfigArray_Add(array: *ClayArray(ScrollElementConfig), config: ScrollElementConfig) *ScrollElementConfig;
    extern "c" fn Clay__BorderElementConfigArray_Add(array: *ClayArray(BorderElementConfig), config: BorderElementConfig) *BorderElementConfig;
    extern "c" fn Clay__HashString(toHash: String, index: u32) ElementId;
};

// Foreign function
pub const MinMemorySize = extern_elements.Clay_MinMemorySize;
pub const CreateArenaWithCapacityAndMemory = extern_elements.Clay_CreateArenaWithCapacityAndMemory;
pub const SetPointerState = extern_elements.Clay_SetPointerState;
pub const Initialize = extern_elements.Clay_Initialize;
pub const UpdateScrollContainers = extern_elements.Clay_UpdateScrollContainers;
pub const SetLayoutDimensions = extern_elements.Clay_SetLayoutDimensions;
pub const BeginLayout = extern_elements.Clay_BeginLayout;
pub const EndLayout = extern_elements.Clay_EndLayout;
pub const PointerOver = extern_elements.Clay_PointerOver;
pub const GetScrollContainerData = extern_elements.Clay_GetScrollContainerData;
pub const SetMeasureTextFunction = extern_elements.Clay_SetMeasureTextFunction;
pub const RenderCommandArray_Get = extern_elements.Clay_RenderCommandArray_Get;
pub const SetDebugModeEnabled = extern_elements.Clay_SetDebugModeEnabled;

// Private external variables
extern "c" var Clay__layoutConfigs: ClayArray(LayoutConfig);
extern "c" var Clay__rectangleElementConfigs: ClayArray(RectangleElementConfig);
extern "c" var Clay__textElementConfigs: ClayArray(TextElementConfig);
extern "c" var Clay__imageElementConfigs: ClayArray(ImageElementConfig);
extern "c" var Clay__floatingElementConfigs: ClayArray(FloatingElementConfig);
extern "c" var Clay__customElementConfigs: ClayArray(CustomElementConfig);
extern "c" var Clay__scrollElementConfigs: ClayArray(ScrollElementConfig);
extern "c" var Clay__borderElementConfigs: ClayArray(BorderElementConfig);

pub const OpenContainerElement = extern_elements.Clay__OpenContainerElement;
pub const OpenRectangleElement = extern_elements.Clay__OpenRectangleElement;
pub const OpenTextElement = extern_elements.Clay__OpenTextElement;
pub const OpenImageElement = extern_elements.Clay__OpenImageElement;
pub const OpenScrollElement = extern_elements.Clay__OpenScrollElement;
pub const OpenFloatingElement = extern_elements.Clay__OpenFloatingElement;
pub const OpenBorderElement = extern_elements.Clay__OpenBorderElement;
pub const OpenCustomElement = extern_elements.Clay__OpenCustomElement;
pub const CloseElementWithChildren = extern_elements.Clay__CloseElementWithChildren;
pub const CloseScrollElement = extern_elements.Clay__CloseScrollElement;
pub const CloseFloatingElement = extern_elements.Clay__CloseFloatingElement;
pub const LayoutConfigArray_Add = extern_elements.Clay__LayoutConfigArray_Add;
pub const RectangleElementConfigArray_Add = extern_elements.Clay__RectangleElementConfigArray_Add;
pub const TextElementConfigArray_Add = extern_elements.Clay__TextElementConfigArray_Add;
pub const ImageElementConfigArray_Add = extern_elements.Clay__ImageElementConfigArray_Add;
pub const FloatingElementConfigArray_Add = extern_elements.Clay__FloatingElementConfigArray_Add;
pub const CustomElementConfigArray_Add = extern_elements.Clay__CustomElementConfigArray_Add;
pub const ScrollElementConfigArray_Add = extern_elements.Clay__ScrollElementConfigArray_Add;
pub const BorderElementConfigArray_Add = extern_elements.Clay__BorderElementConfigArray_Add;
pub const HashString = extern_elements.Clay__HashString;

fn measureText(str: *String, conf: *TextElementConfig) callconv(.C) Dimensions {
    _ = str;
    _ = conf;
    return Dimensions{
        .height = 10,
        .width = 10,
    };
}

test {
    std.debug.print("{}", .{MinMemorySize()});
    const allocator = std.testing.allocator;

    const minMemorySize: u32 = MinMemorySize();
    const memory = try allocator.alloc(u8, minMemorySize);
    defer allocator.free(memory);
    const arena: Arena = CreateArenaWithCapacityAndMemory(minMemorySize, @ptrCast(memory));
    SetMeasureTextFunction(measureText);
    Initialize(arena, .{ .width = 1000, .height = 1000 });

    BeginLayout();

    // CLAY_RECTANGLE(CLAY_ID("OuterContainer"), CLAY_LAYOUT(.sizing = { .width = CLAY_SIZING_GROW(), .height = CLAY_SIZING_GROW() }, .padding = { 16, 16 }, .childGap = 16), CLAY_RECTANGLE_CONFIG(.color = {200, 200, 200, 255})

    {
        var layout_config = LayoutConfig{
            .sizing = .{
                .height = .{ .constraints = .{ .sizePercent = 10 }, .type = .GROW },
                .width = .{ .constraints = .{ .sizePercent = 10 }, .type = .GROW },
            },
            .padding = .{ .x = 5, .y = 5 },
            .childGap = 10,
            .layoutDirection = .LEFT_TO_RIGHT,
            .childAlignment = .{ .x = .LEFT, .y = .TOP },
        };

        OpenRectangleElement(
            HashString(.{
                .chars = @ptrCast(@constCast("string")),
                .length = 6,
            }, 0),
            &layout_config,
            @constCast(&RectangleElementConfig{
                .color = .{ 200, 200, 200, 255 },
                .cornerRadius = .{ .bottomLeft = 1, .topLeft = 1, .topRight = 1, .bottomRight = 1 },
            }),
        );
        defer CloseElementWithChildren();
    }

    const layout = EndLayout();
    std.debug.print("{any}", .{layout.internalArray[0..1]});
}

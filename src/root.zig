const std = @import("std");
const builtin = @import("builtin");

pub extern var CLAY_LAYOUT_DEFAULT: LayoutConfig;

/// Color used for highlighting elements with the debug inspector panel (can be modified directly)
pub extern var Clay__debugViewHighlightColor: Color;

/// Width of the panel in pixels when the debug inspector panel is enabled (can be modified directly)
pub extern var Clay__debugViewWidth: u32;

/// for direct calls to the clay C library
pub const cdefs = struct {
    pub extern fn Clay_GetElementData(id: ElementId) ElementData;
    pub extern fn Clay_MinMemorySize() u32;
    pub extern fn Clay_CreateArenaWithCapacityAndMemory(capacity: usize, memory: ?*anyopaque) Arena;
    pub extern fn Clay_SetPointerState(position: Vector2, pointerDown: bool) void;
    pub extern fn Clay_Initialize(arena: Arena, layoutDimensions: Dimensions, errorHandler: ErrorHandler) *Context;
    pub extern fn Clay_GetCurrentContext() *Context;
    pub extern fn Clay_SetCurrentContext(context: *Context) void;
    pub extern fn Clay_UpdateScrollContainers(enableDragScrolling: bool, scrollDelta: Vector2, deltaTime: f32) void;
    pub extern fn Clay_GetScrollOffset() Vector2;
    pub extern fn Clay_SetLayoutDimensions(dimensions: Dimensions) void;
    pub extern fn Clay_BeginLayout() void;
    pub extern fn Clay_EndLayout() ClayArray(RenderCommand);
    pub extern fn Clay_GetElementId(idString: String) ElementId;
    pub extern fn Clay_GetElementIdWithIndex(idString: String, index: u32) ElementId;
    pub extern fn Clay_Hovered() bool;
    pub extern fn Clay_OnHover(onHoverFunction: *const fn (ElementId, PointerData, ?*anyopaque) callconv(.c) void, user_data: ?*anyopaque) void;
    pub extern fn Clay_PointerOver(elementId: ElementId) bool;
    pub extern fn Clay_GetPointerOverIds() ClayArray(ElementId);
    pub extern fn Clay_GetScrollContainerData(id: ElementId) ScrollContainerData;
    pub extern fn Clay_SetMeasureTextFunction(measureTextFunction: *const fn (StringSlice, *TextElementConfig, ?*anyopaque) callconv(.c) Dimensions, user_data: ?*anyopaque) void;
    pub extern fn Clay_SetQueryScrollOffsetFunction(queryScrollOffsetFunction: *const fn (u32, ?*anyopaque) callconv(.c) Vector2, user_data: ?*anyopaque) void;
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
    pub extern fn Clay__ConfigureOpenElementPtr(config: *ElementDeclaration) void; // TODO: investigate uses
    pub extern fn Clay__OpenElement() void;
    pub extern fn Clay__CloseElement() void;
    pub extern fn Clay__StoreTextElementConfig(config: TextElementConfig) *TextElementConfig;
    pub extern fn Clay__HashString(key: String, offset: u32, seed: u32) ElementId;
    pub extern fn Clay__OpenTextElement(text: String, textConfig: *TextElementConfig) void;
    pub extern fn Clay__GetParentElementId() u32;
};

pub const EnumBackingType = u8;

/// Clay String representation, not guaranteed to be null terminated
pub const String = extern struct {
    /// Set this boolean to true if the `chars: [*]const u8` data underlying this string will live for the entire lifetime of the program.
    /// This will automatically be set for strings created with CLAY_STRING, as the macro requires a string literal.
    is_statically_allocated: bool,
    /// Length of the string in bytes
    length: i32,
    /// Pointer to the character data
    chars: [*]const u8,

    /// Converts a Zig comptime string slice to a Clay_String, see `fromRuntimeSlice` form non-comptime strings.
    pub fn fromSlice(comptime string: []const u8) String {
        return .{
            .is_statically_allocated = true,
            .chars = @ptrCast(@constCast(string)),
            .length = @intCast(string.len),
        };
    }

    /// Converts a Zig string slice to a Clay_String
    pub fn fromRuntimeSlice(string: []const u8) String {
        return .{
            .is_statically_allocated = false,
            .chars = @ptrCast(@constCast(string)),
            .length = @intCast(string.len),
        };
    }
};

/// Clay StringSlice is used to represent non-owning string slices
/// Includes a baseChars field which points to the string this slice is derived from
pub const StringSlice = extern struct {
    /// Length of the string slice in bytes
    length: i32 = 0,
    /// Pointer to the character data
    chars: [*]const u8,
    /// Pointer to the source string that this slice was derived from
    base_chars: [*]const u8,
};

pub const Context = opaque {};

/// Clay Arena is a memory arena structure used by Clay to manage its internal allocations
/// Create using createArenaWithCapacityAndMemory() instead of manually
pub const Arena = extern struct {
    /// Pointer to the next allocation (internal use)
    next_allocation: usize,
    /// Total capacity of the arena in bytes
    capacity: usize,
    /// Pointer to the arena's memory
    memory: [*]u8,
};

pub const Dimensions = extern struct {
    /// Width in pixels
    w: f32,
    /// Height in pixels
    h: f32,
};

pub const Vector2 = extern struct {
    x: f32,
    y: f32,
};

/// Represents an RGBA color where components are in 0-255 range
/// order: r, g, b, a
pub const Color = [4]f32;

pub const BoundingBox = extern struct {
    /// X coordinate of the top-left corner
    x: f32,
    /// Y coordinate of the top-left corner
    y: f32,
    /// Width of the bounding box
    width: f32,
    /// Height of the bounding box
    height: f32,
};

pub const SizingMinMax = extern struct {
    /// Element won't shrink below this size even if content is smaller
    min: f32 = 0,
    /// Content will wrap/overflow if larger than this size
    max: f32 = 0,
};

const SizingConstraint = extern union {
    /// Min/max sizing constraints in pixels
    minmax: SizingMinMax,
    /// Percentage of parent container size (0.0-1.0)
    percent: f32,
};

pub const SizingType = enum(EnumBackingType) {
    /// (default) Wraps tightly to the size of element's contents
    fit = 0,
    /// Expands to fill available space, sharing with other GROW elements
    grow = 1,
    /// Clamps size to a percent of parent (0.0-1.0 range)
    percent = 2,
    /// Clamps size to an exact size in pixels
    fixed = 3,
};

/// Controls the sizing of an element along one axis inside its parent container
pub const SizingAxis = extern struct {
    /// Size constraints
    size: SizingConstraint = .{ .minmax = .{} },
    /// How the element takes up space (fit, grow, fixed, percent)
    type: SizingType = .fit,

    /// Element will grow to fill available space
    pub const grow = SizingAxis{ .type = .grow, .size = .{ .minmax = .{ .min = 0, .max = 0 } } };

    /// Element will size to fit its child elements
    pub const fit = SizingAxis{ .type = .fit, .size = .{ .minmax = .{ .min = 0, .max = 0 } } };

    /// Element will grow to fill available space with min/max constraints
    pub fn growMinMax(size_minmax: SizingMinMax) SizingAxis {
        return .{ .type = .grow, .size = .{ .minmax = size_minmax } };
    }

    /// Element will fit its contents with min/max constraints
    pub fn fitMinMax(size_minmax: SizingMinMax) SizingAxis {
        return .{ .type = .fit, .size = .{ .minmax = size_minmax } };
    }

    /// Creates a fixed size element (min = max = size)
    pub fn fixed(size: f32) SizingAxis {
        return .{ .type = .fixed, .size = .{ .minmax = .{ .max = size, .min = size } } };
    }

    /// Creates a sizing that's a percentage of parent size (0.0-1.0)
    pub fn percent(size_percent: f32) SizingAxis {
        return .{ .type = .percent, .size = .{ .percent = size_percent } };
    }
};

pub const Sizing = extern struct {
    /// Width
    w: SizingAxis = .{},
    /// Height
    h: SizingAxis = .{},

    /// Grow to fill available space in both dimensions
    pub const grow = Sizing{ .h = .grow, .w = .grow };

    /// will size to fit its child elements in both dimensions
    pub const fit = Sizing{ .h = .fit, .w = .fit };
};

/// Controls "padding" in pixels, which is a gap between the element's bounding box
/// and where its children will be placed
pub const Padding = extern struct {
    /// Padding on left side
    left: u16 = 0,
    /// Padding on right side
    right: u16 = 0,
    /// Padding on top side
    top: u16 = 0,
    /// Padding on bottom side
    bottom: u16 = 0,

    pub const xy = @compileError("renamed to axes"); // TODO: remove this in v0.3.0

    /// Padding with vertical and horizontal values
    pub fn axes(top_bottom: u16, left_right: u16) Padding {
        return .{
            .top = top_bottom,
            .bottom = top_bottom,
            .left = left_right,
            .right = left_right,
        };
    }

    /// Equal padding on all sides
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
    /// (default) Breaks text on whitespace characters
    words = 0,
    /// Don't break on space characters, only on newlines
    new_lines = 1,
    /// Disable text wrapping entirely
    none = 2,
};

pub const TextAlignment = enum(EnumBackingType) {
    /// (default) Aligns text to the left edge
    left = 0,
    /// Aligns text to the center
    center = 1,
    /// Aligns text to the right edge
    right = 2,
};

pub const TextElementConfig = extern struct {
    /// A pointer that will be transparently passed through to the resulting render command.
    user_data: ?*anyopaque = null,
    /// The RGBA color of the font to render, conventionally specified as 0-255.
    color: Color = .{ 0, 0, 0, 255 },
    /// An integer transparently passed to Clay_MeasureText to identify the font to use.
    /// The debug view will pass fontId = 0 for its internal text.
    font_id: u16 = 0,
    /// Controls the size of the font. Handled by the function provided to Clay_MeasureText.
    font_size: u16 = 20,
    /// Controls extra horizontal spacing between characters. Handled by the function provided to Clay_MeasureText.
    letter_spacing: u16 = 0,
    /// Additional vertical space between wrapped lines of text
    line_height: u16 = 0,
    /// Controls how text "wraps", that is how it is broken into multiple lines when there is insufficient horizontal space.
    wrap_mode: TextElementConfigWrapMode = .words,
    /// Controls how wrapped lines of text are horizontally aligned within the outer text bounding box.
    alignment: TextAlignment = .left,
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
    /// Controls the origin point on the floating element that attaches to its parent
    element: FloatingAttachPointType,
    /// Controls the origin point on the parent element that the floating element attaches to
    parent: FloatingAttachPointType,
};

pub const FloatingAttachToElement = enum(EnumBackingType) {
    /// (default) Disables floating for this element
    to_none = 0,
    /// Attaches to parent, positioned based on attachPoints and offset
    to_parent = 1,
    /// Attaches to element with specific ID (specified with parentId field)
    to_element_with_id = 2,
    /// Attaches to the root of the layout (similar to absolute positioning)
    to_root = 3,
};

pub const FloatingClipToElement = enum(EnumBackingType) {
    /// (default) - The floating element does not inherit clipping.
    to_none = 0,
    /// The floating element is clipped to the same clipping rectangle as the element it's attached to.
    to_attached_parent = 1,
};

/// Controls how pointer events are handled by floating elements
pub const PointerCaptureMode = enum(EnumBackingType) {
    /// (default) Captures pointer events and doesn't pass through to elements underneath
    capture = 0,
    /// Transparently passes through pointer events to elements underneath
    passthrough = 1,
};

pub const FloatingElementConfig = extern struct {
    /// Offsets this floating element by these x,y coordinates from its attachPoints
    offset: Vector2 = .{ .x = 0, .y = 0 },
    /// Expands the boundaries of the outer floating element without affecting children
    expand: Dimensions = .{ .w = 0, .h = 0 },
    /// When using CLAY_ATTACH_TO_ELEMENT_WITH_ID, attaches to element with this ID
    parentId: u32 = 0,
    /// Z-index controls stacking order (ascending)
    z_index: i16 = 0,
    /// Controls attachment points between floating element and its parent
    attach_points: FloatingAttachPoints = .{ .element = .left_top, .parent = .left_top },
    /// Controls whether pointer events are captured or pass through to elements underneath
    pointer_capture_mode: PointerCaptureMode = .capture,
    /// Controls which element this floating element is attached to
    attach_to: FloatingAttachToElement = .to_none,
    /// Controls whether or not a floating element is clipped to the same clipping rectangle as the element it's attached to.
    clip_to: FloatingClipToElement = .to_none,
};

pub const RenderCommandType = enum(EnumBackingType) {
    /// This command type should be skipped
    none = 0,
    /// Draw a solid color rectangle
    rectangle = 1,
    /// Draw a colored border inset into the bounding box
    border = 2,
    /// Draw text
    text = 3,
    /// Draw an image
    image = 4,
    /// Begin clipping (scissor) - render only content within the boundingBox
    scissor_start = 5,
    /// End clipping - resume rendering elements without restriction
    scissor_end = 6,
    /// Custom implementation based on the render command's customData
    custom = 7,
};

pub const PointerDataInteractionState = enum(EnumBackingType) {
    /// A mouse click or touch occurred this frame
    pressed_this_frame = 0,
    /// Mouse button or touch is currently held down
    pressed = 1,
    /// Mouse button or touch was released this frame
    released_this_frame = 2,
    /// Mouse button or touch is not currently down
    released = 3,
};

pub const PointerData = extern struct {
    /// Position of the mouse/touch relative to the root of the layout
    position: Vector2,
    state: PointerDataInteractionState,
};

pub const ErrorType = enum(EnumBackingType) {
    /// Text measurement function wasn't provided or was null
    text_measurement_function_not_provided = 0,
    /// Clay ran out of space in the provided arena
    arena_capacity_exceeded = 1,
    /// Clay ran out of capacity for storing elements
    elements_capacity_exceeded = 2,
    /// Clay ran out of capacity for text measurement cache
    text_measurement_capacity_exceeded = 3,
    /// Two elements were declared with exactly the same ID
    duplicate_id = 4,
    /// Invalid parentId or no element with the provided parentId was found
    floating_container_parent_not_found = 5,
    /// Percentage value was over 1.0 (should be 0.0-1.0)
    percentage_over_1 = 6,
    /// Internal Clay error (please report this)
    internal_error = 7,
};

pub const ErrorData = extern struct {
    error_type: ErrorType,
    /// Human-readable error message
    error_text: String,
    /// Transparent pointer passed from when error handler was provided
    user_data: ?*anyopaque,
};

pub const ErrorHandler = extern struct {
    /// Function to call when Clay encounters an error during layout
    error_handler_function: ?*const fn (ErrorData) callconv(.c) void = null,
    /// Pointer passed through to error handler when called
    user_data: ?*anyopaque = null,
};

/// Controls corner rounding of elements (rectangles, borders, images)
pub const CornerRadius = extern struct {
    top_left: f32 = 0,
    top_right: f32 = 0,
    bottom_left: f32 = 0,
    bottom_right: f32 = 0,

    /// Sets all corners to the same radius
    pub fn all(radius: f32) CornerRadius {
        return .{
            .top_left = radius,
            .top_right = radius,
            .bottom_left = radius,
            .bottom_right = radius,
        };
    }
};

/// Identifies a UI element for interaction and lookups
pub const ElementId = extern struct {
    /// The resulting hash generated from the other fields
    id: u32,
    /// Numerical offset applied after computing the hash
    offset: u32,
    /// Base hash value to start from (e.g., parent element ID for local IDs)
    base_id: u32,
    /// The string ID to hash
    string_id: String,

    /// Creates a global element ID from a string
    pub fn ID(string: []const u8) ElementId {
        return cdefs.Clay__HashString(.fromRuntimeSlice(string), 0, 0); // TODO move hashing to zig side for performance
    }

    /// Creates a global element ID with an index component for use in loops
    /// Equivalent to `ID("prefix0")`, `ID("prefix1")`, etc. without string allocations
    pub fn IDI(string: []const u8, index: u32) ElementId {
        return cdefs.Clay__HashString(.fromRuntimeSlice(string), index, 0);
    }

    /// Creates a local element ID from a string
    /// Local IDs are scoped to the current parent element
    pub fn localID(string: []const u8) ElementId {
        return cdefs.Clay__HashString(.fromRuntimeSlice(string), 0, cdefs.Clay__GetParentElementId());
    }

    /// Creates a local element ID from a string with index
    /// Local IDs are scoped to the current parent element
    pub fn localIDI(string: []const u8, index: u32) ElementId {
        return cdefs.Clay__HashString(.fromRuntimeSlice(string), index, cdefs.Clay__GetParentElementId());
    }

    /// Creates a global element ID from a source location (@src())
    /// Useful for auto-generating unique IDs based on code location
    pub fn fromSrc(comptime src: std.builtin.SourceLocation) ElementId {
        return cdefs.Clay__HashString(.fromSlice(src.module ++ ":" ++ src.file ++ ":" ++ std.fmt.comptimePrint("{}", .{src.column})), 0, 0);
    }

    /// Creates a global element ID from a source location (@src()) with an index
    /// Useful for auto-generating unique IDs based on code location in loops
    pub fn fromSrcI(comptime src: std.builtin.SourceLocation, index: u32) ElementId {
        return cdefs.Clay__HashString(.fromSlice(src.module ++ ":" ++ src.file ++ ":" ++ std.fmt.comptimePrint("{}", .{src.column})), index, 0);
    }
};

/// Represents a single render command to be processed by a renderer
pub const RenderCommand = extern struct {
    /// Rectangular box that fully encloses this UI element
    bounding_box: BoundingBox,
    /// Data specific to this command's type
    render_data: RenderData,
    /// Pointer passed through from the original element declaration
    user_data: ?*anyopaque,
    /// ID of this element
    id: u32,
    /// Z-order for correct drawing (commands are already sorted in ascending order)
    z_index: i16,
    /// Specifies how to handle rendering of this command
    command_type: RenderCommandType,
};

pub const LayoutDirection = enum(EnumBackingType) {
    /// (default) Lays out children from left to right with increasing x
    left_to_right = 0,
    /// Lays out children from top to bottom with increasing y
    top_to_bottom = 1,
};

pub const LayoutAlignmentX = enum(EnumBackingType) {
    /// (default) Aligns children to the left, offset by padding.left
    left = 0,
    /// Aligns children to the right, offset by padding.right
    right = 1,
    /// Aligns children horizontally to the center
    center = 2,
};

pub const LayoutAlignmentY = enum(EnumBackingType) {
    /// (default) Aligns children to the top, offset by padding.top
    top = 0,
    /// Aligns children to the bottom, offset by padding.bottom
    bottom = 1,
    /// Aligns children vertically to the center
    center = 2,
};

pub const ChildAlignment = extern struct {
    x: LayoutAlignmentX = .left,
    y: LayoutAlignmentY = .top,

    /// Centers children on both axes
    pub const center = ChildAlignment{ .x = .center, .y = .center };
};

pub const LayoutConfig = extern struct {
    /// Controls sizing of this element inside its parent container
    sizing: Sizing = .{},
    /// Controls gap between element bounds and where children are placed
    padding: Padding = .{},
    /// Controls gap between child elements along layout axis
    child_gap: u16 = 0,
    /// Controls how child elements are aligned on each axis
    child_alignment: ChildAlignment = .{},
    /// Controls the direction of children's layout
    direction: LayoutDirection = .left_to_right,
};

pub fn ClayArray(comptime T: type) type {
    return extern struct {
        /// Maximum capacity of the array (not all elements may be initialized)
        capacity: i32,
        /// Number of initialized elements in the array
        length: i32,
        /// Pointer to the first element in the array
        internal_array: [*]T,
    };
}

pub const BorderWidth = extern struct {
    /// Width of left border in pixels
    left: u16 = 0,
    /// Width of right border in pixels
    right: u16 = 0,
    /// Width of top border in pixels
    top: u16 = 0,
    /// Width of bottom border in pixels
    bottom: u16 = 0,
    /// Width of borders between child elements
    between_children: u16 = 0,

    /// Creates borders on all outer edges (not between children)
    pub fn outside(width: u16) BorderWidth {
        return .{
            .left = width,
            .right = width,
            .top = width,
            .bottom = width,
            .between_children = 0,
        };
    }

    /// Creates borders on all edges, including between children
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
    /// Color of all borders with width > 0
    color: Color = .{ 0, 0, 0, 255 },
    /// Widths of individual borders
    width: BorderWidth = .{},
};

pub const TextRenderData = extern struct {
    /// Text to be rendered
    string_contents: StringSlice,
    /// Color of the text (0-255 range)
    text_color: Color,
    /// Font identifier passed to the text measurement function
    font_id: u16,
    /// Size of the font
    font_size: u16,
    /// Extra space between characters
    letter_spacing: u16,
    /// Height of this line of text
    line_height: u16,
};

pub const RectangleRenderData = extern struct {
    /// Fill color for the rectangle
    background_color: Color,
    /// Corner rounding for the rectangle
    corner_radius: CornerRadius,
};

pub const ImageRenderData = extern struct {
    /// Tint color for the image (0,0,0,0 = untinted)
    background_color: Color,
    /// Corner rounding for the image
    corner_radius: CornerRadius,
    /// Transparent pointer to image data
    image_data: ?*anyopaque,
};

pub const CustomRenderData = extern struct {
    /// Background color passed from the element declaration
    background_color: Color,
    /// Corner rounding for the custom element
    corner_radius: CornerRadius,
    /// Transparent pointer from the element declaration
    custom_data: ?*anyopaque,
};

pub const AspectRatioElementConfig = extern struct {
    /// A float representing the target "Aspect ratio" for an element, which is its final width divided by its final height.
    aspect_ratio: f32 = 0,
};

pub const ImageElementConfig = extern struct {
    /// Transparent pointer to image data
    image_data: ?*const anyopaque,
};

/// Render command data for scissor (clipping) commands
pub const ClipRenderData = extern struct {
    /// Whether to clip/scroll horizontally
    horizontal: bool,
    /// Whether to clip/scroll vertically
    vertical: bool,
};

pub const BorderRenderData = extern struct {
    /// Color of all borders
    color: Color,
    /// Corner rounding for the borders
    corner_radius: CornerRadius,
    /// Widths of individual borders
    width: BorderWidth,
};

pub const RenderData = extern union {
    rectangle: RectangleRenderData,
    text: TextRenderData,
    image: ImageRenderData,
    custom: CustomRenderData,
    border: BorderRenderData,
    scroll: ClipRenderData,
};

/// Configuration for custom elements
pub const CustomElementConfig = extern struct {
    /// Transparent pointer for passing custom data to the renderer
    custom_data: ?*anyopaque = null,
};

/// Data representing the current internal state of a scrolling element
pub const ScrollContainerData = extern struct {
    /// Pointer to the internal scroll position (mutable)
    /// Modifying this will change the actual scroll position
    scroll_position: *Vector2,
    /// Bounding box of the scroll container
    scroll_container_dimensions: Dimensions,
    /// Dimensions of the inner content, including parent padding
    content_dimensions: Dimensions,
    /// Original scroll config
    config: ClipElementConfig,
    /// Whether a scroll container was found with the provided ID
    found: bool,
};

/// Bounding box and other data for a specific UI element
pub const ElementData = extern struct {
    /// Rectangle enclosing this element, position relative to layout root
    bounding_box: BoundingBox,
    /// Whether an element with the provided ID was found
    found: bool,
};

/// Controls the axes on which an element can scroll
pub const ClipElementConfig = extern struct {
    /// Whether to enable horizontal scrolling
    horizontal: bool = false,
    /// Whether to enable vertical scrolling
    vertical: bool = false,
    // Offsets the x,y positions of all child elements. Used primarily for scrolling containers.
    child_offset: Vector2 = .{ .x = 0, .y = 0 },
};

/// Shared configuration properties for multiple element types
pub const SharedElementConfig = extern struct {
    /// Background color of the element
    background_color: Color,
    /// Corner rounding of the element
    corner_radius: CornerRadius,
    /// Transparent pointer passed to render commands
    user_data: ?*anyopaque,
};

/// Element configuration type identifiers
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
    /// Element IDs have two main use cases.
    ///
    /// Firstly, tagging an element with an ID allows you to query information about the element later, such as its mouseover state or dimensions.
    ///
    /// Secondly, IDs are visually useful when attempting to read and modify UI code, as well as when using the built-in debug tools.
    id: ElementId = .{ .base_id = 0, .id = 0, .offset = 0, .string_id = .{ .chars = &.{}, .length = 0, .is_statically_allocated = false } },
    /// Controls various settings that affect the size and position of an element, as well as the sizes and positions of any child elements.
    layout: LayoutConfig = .{},
    /// Controls the background color of the resulting element.
    /// By convention specified as 0-255, but interpretation is up to the renderer.
    /// If no other config is specified, `.background_color` will generate a `RECTANGLE` render command, otherwise it will be passed as a property to `IMAGE` or `CUSTOM` render commands.
    background_color: Color = .{ 0, 0, 0, 0 },
    /// Controls the "radius", or corner rounding of elements, including rectangles, borders and images.
    corner_radius: CornerRadius = .{},
    // Controls settings related to aspect ratio scaling.
    aspect_ratio: AspectRatioElementConfig = .{},
    /// Controls settings related to image elements.
    image: ImageElementConfig = .{ .image_data = null },
    /// Controls whether and how an element "floats", which means it layers over the top of other elements in z order, and doesn't affect the position and size of siblings or parent elements.
    /// Note: in order to activate floating, `.floating.attachTo` must be set to something other than the default value.
    floating: FloatingElementConfig = .{},
    /// Used to create CUSTOM render commands, usually to render element types not supported by Clay.
    custom: CustomElementConfig = .{},
    /// Controls whether an element should clip its contents and allow scrolling rather than expanding to contain them.
    clip: ClipElementConfig = .{},
    /// Controls settings related to element borders, and will generate BORDER render command
    border: BorderElementConfig = .{},
    /// A pointer that will be transparently passed through to resulting render command
    user_data: ?*anyopaque = null,
};

/// Main API for creating UI elements with children
///
/// Clay should be initialized with initialize() before using this function
/// The beginLayout() function should be called before using this function
///
/// The default background_color is fully transparent,
/// so background_color should be set for the element to be visible
///
/// Example:
/// ```
/// UI()(.{
///    .id = .ID("container"),
///    .layout = .{
///       .padding = .all(16),
///       .direction = .top_to_bottom,
///    },
///    .background_color = .{220, 220, 230, 255},
/// })({
///    text("Hello world", .{ .font_size = 24 });
///
///    UI()(.{
///       .background_color = .{180, 180, 200, 255},
///       .corner_radius = .all(8),
///    })({
///       text("Nested element", .{});
///    });
/// });
/// ```
pub inline fn UI() fn (config: ElementDeclaration) callconv(.@"inline") fn (void) void {
    const local = struct {
        fn closeElement(_: void) void {
            cdefs.Clay__CloseElement();
        }

        inline fn configureOpenElement(config: ElementDeclaration) fn (void) void {
            cdefs.Clay__ConfigureOpenElement(config);
            return closeElement;
        }
    };

    cdefs.Clay__OpenElement();
    return local.configureOpenElement;
}

/// Returns layout data for an element with the given ID
/// The returned data includes the element's position and size
/// The 'found' field indicates if an element with that ID exists
pub const getElementData = cdefs.Clay_GetElementData;

/// Returns the minimum required memory size in bytes for Clay initialization
/// Use this to allocate an appropriate buffer before initializing Clay
pub const minMemorySize = cdefs.Clay_MinMemorySize;

/// Sets mouse/touch position for hover detection and scrolling
/// Must be called before updateScrollContainers() and every frame to enable hover/click detection
pub const setPointerState = cdefs.Clay_SetPointerState;

/// Initializes Clay with a memory arena and screen dimensions
/// Returns a context pointer that can be used with setCurrentContext() for multi-instance support
///
/// The errorHandler allows you to receive notifications of layout errors
///
/// Example:
/// ```
/// // Create a buffer for Clay
/// const buffer_size = minMemorySize();
/// var buffer = try allocator.alloc(u8, buffer_size);
/// defer allocator.free(buffer);
///
/// // Create arena and initialize Clay
/// const arena = createArenaWithCapacityAndMemory(buffer);
/// const ctx = initialize(arena, .{ .w = screen_width, .h = screen_height }, .{});
/// ```
pub const initialize = cdefs.Clay_Initialize;

/// Gets current Clay context - useful when working with multiple UI instances
pub const getCurrentContext = cdefs.Clay_GetCurrentContext;

/// Sets current Clay context - required when working with multiple UI instances
pub const setCurrentContext = cdefs.Clay_SetCurrentContext;

/// Updates internal scroll containers with mouse wheel/touchpad input
///
/// - enableDragScrolling: enables mobile-like touch drag scrolling with momentum
/// - scrollDelta: amount to scroll this frame in pixels (e.g., from mouse wheel)
/// - deltaTime: time in seconds since last frame
///
pub const updateScrollContainers = cdefs.Clay_UpdateScrollContainers;

/// Sets layout size (typically window dimensions)
/// Should be called whenever the window is resized
pub const setLayoutDimensions = cdefs.Clay_SetLayoutDimensions;

/// Begins new layout frame - must be called before UI elements
/// Use endLayout to complete the layout and compute the render commands
pub const beginLayout = cdefs.Clay_BeginLayout;

/// Completes the layout and computes the render commands
/// Returns an array of render commands to be processed by your renderer
///
/// Example:
/// ```
/// beginLayout();
/// // UI elements...
/// const commands = endLayout();
/// // Now render the commands with your graphics API
/// ```
pub fn endLayout() []RenderCommand {
    const commands = cdefs.Clay_EndLayout();
    return commands.internal_array[0..@intCast(commands.length)];
}

/// Gets an element ID with a numeric index - useful for loops
/// Generally only used for dynamic strings when ElementId.IDI() can't be used
pub const getElementIdWithIndex = cdefs.Clay_GetElementIdWithIndex;

/// Returns true if pointer is over the currently open element
/// Works during element declaration for dynamic styling
///
/// Example:
/// ```
/// UI()(.{
///     .background_color = if(hovered()) .{100, 120, 255, 255} else .{80, 80, 80, 255},
/// })({
///     text("Hover me!", .{});
/// });
/// ```
pub const hovered = cdefs.Clay_Hovered;

/// Returns true if the pointer is over the element with the given ID
/// Can be called after layout is complete
///
/// Example:
/// ```
/// // Check after layout if button was hovered
/// const buttonId = ElementId.ID("SubmitButton");
/// if (pointerOver(buttonId) && mouse_clicked) {
///     handleSubmit();
/// }
/// ```
pub const pointerOver = cdefs.Clay_PointerOver;

/// Gets scrolling information about an element
/// Returns position and dimensions that can be used to implement custom scrollbars
pub const getScrollContainerData = cdefs.Clay_GetScrollContainerData;

/// Gets individual render command from a ClayArray
/// Provides bounds-checked access to render commands
pub const renderCommandArrayGet = cdefs.Clay_RenderCommandArray_Get;

/// Enables/disables the visual inspector debugging tools
/// When enabled, adds a side panel showing element hierarchy and properties
///
/// This setting is retained across frames
pub const setDebugModeEnabled = cdefs.Clay_SetDebugModeEnabled;

/// Returns whether debug mode is currently enabled
pub const isDebugModeEnabled = cdefs.Clay_IsDebugModeEnabled;

/// Enables/disables render culling for off-screen elements
/// Culling is enabled by default and improves performance by not rendering invisible elements
pub const setCullingEnabled = cdefs.Clay_SetCullingEnabled;

/// Gets the maximum number of UI elements Clay can handle
pub const getMaxElementCount = cdefs.Clay_GetMaxElementCount;

/// Sets the maximum number of UI elements Clay can handle
/// Must be called before initialization; affects memory requirements
pub const setMaxElementCount = cdefs.Clay_SetMaxElementCount;

/// Gets the maximum number of text words that can be cached
pub const getMaxMeasureTextCacheWordCount = cdefs.Clay_GetMaxMeasureTextCacheWordCount;

/// Sets the maximum number of text words that can be cached
/// Must be called before initialization; affects memory requirements
pub const setMaxMeasureTextCacheWordCount = cdefs.Clay_SetMaxMeasureTextCacheWordCount;

/// Refreshes text measurement cache
/// Call when fonts associated with fontids are changed
pub const resetMeasureTextCache = cdefs.Clay_ResetMeasureTextCache;

/// Registers a hover callback for the current element
/// `T` must be a type of the same size as a pointer or be of type `void`
///
/// Call this inside a UI element declaration to detect when the mouse/pointer
/// hovers over that element. The callback will receive the element ID, pointer
/// data, and your user_data of type T.
///
/// Example:
/// ```
/// UI()(.{ .background_color = .{80, 80, 200, 255} })({
///     const user_data: usize = 42;
///     onHover(usize, user_data, struct {
///         pub fn callback(id: ElementId, pointer: PointerData, user_data: usize) void {
///             std.debug.print("hovered with user_data: {}\n", .{user_data});
///         }
///     }.callback);
/// });
/// ```
pub fn onHover(
    T: type,
    user_data: T,
    comptime onHoverFunction: fn (
        element_id: ElementId,
        pointer_data: PointerData,
        user_data: T,
    ) void,
) void {
    if (!(T == void) and @sizeOf(T) != @sizeOf(usize))
        @compileError("`T` must be a type of same size as a pointer or be the type `void`");

    cdefs.Clay_OnHover(
        struct {
            pub fn f(element_id: ElementId, pointer_data: PointerData, user_data_: ?*anyopaque) callconv(.C) void {
                onHoverFunction(
                    element_id,
                    pointer_data,
                    anyopaquePtrToAnytype(T, user_data_),
                );
            }
        }.f,
        anytypeToAnyopaquePtr(user_data),
    );
}

/// Experimental - Used for integrating with external scrolling systems
/// `T` must be a type of the same size as a pointer or be of type `void`
///
/// Allows Clay to query an external system for scroll position. The provided callback
/// function will be used to retrieve the scroll position for a given scroll container.
///
/// From Clay's original documentation:
/// "Experimental - Used in cases where Clay needs to integrate with a system that manages its own scrolling containers externally.
/// Please reach out if you plan to use this function, as it may be subject to change."
pub fn setQueryScrollOffsetFunction(
    T: type,
    user_data: T,
    comptime queryScrollOffsetFunction: fn (
        element_id: u32,
        user_data: T,
    ) Vector2,
) void {
    if (!(T == void) and @sizeOf(T) != @sizeOf(usize))
        @compileError("`T` must be a type of same size as a pointer or be the type `void`");

    cdefs.Clay_SetQueryScrollOffsetFunction(
        struct {
            pub fn f(element_id_: u32, user_data_: ?*anyopaque) callconv(.c) Dimensions {
                return queryScrollOffsetFunction(
                    element_id_,
                    anyopaquePtrToAnytype(T, user_data_),
                );
            }
        }.f,
        anytypeToAnyopaquePtr(user_data),
    );
}

/// Sets a function to measure text dimensions
/// `T` must be a type of the same size as a pointer or be of type `void`
///
/// This function is required for text layout and must be set before using text elements.
/// Your measurement function should calculate the width and height of text with the
/// given configuration.
///
/// Example:
/// ```
/// // Load your fonts, then implement measurement
/// fn measureText(text: []const u8, config: *TextElementConfig, font_context: MyFontContext) Dimensions {
///     // Compute the text dimensions based on font, size, etc.
///     const width = font_context.measureWidth(text, config.font_id, config.font_size);
///     const height = config.font_size;
///     return .{ .w = width, .h = height };
/// }
///
/// // Set the measurement function with your font context
/// const font_context = MyFontContext{};
/// setMeasureTextFunction(MyFontContext, font_context, measureText);
/// ```
pub fn setMeasureTextFunction(
    T: type,
    user_data: T,
    comptime measureTextFunction: fn (
        []const u8,
        *TextElementConfig,
        user_data: T,
    ) Dimensions,
) void {
    if (!(T == void) and @sizeOf(T) != @sizeOf(usize))
        @compileError("`T` must be a type of same size as a pointer or be the type `void`");

    cdefs.Clay_SetMeasureTextFunction(
        struct {
            pub fn f(string: StringSlice, config: *TextElementConfig, user_data_: ?*anyopaque) callconv(.c) Dimensions {
                return measureTextFunction(
                    string.chars[0..@intCast(string.length)],
                    config,
                    anyopaquePtrToAnytype(T, user_data_),
                );
            }
        }.f,
        anytypeToAnyopaquePtr(user_data),
    );
}

/// Creates a Clay arena with the given memory buffer
/// Used to initialize Clay's memory management
pub fn createArenaWithCapacityAndMemory(buffer: []u8) Arena {
    return cdefs.Clay_CreateArenaWithCapacityAndMemory(@intCast(buffer.len), buffer.ptr);
}

/// Creates a text element with the given string literal and configuration
///
/// see `textDynamic` for runtime known strings
///
/// Example:
/// ```
/// text("Hello World", .{ .font_size = 24, .color = .{255, 0, 0, 255} });
/// ```
pub fn text(string: []const u8, config: TextElementConfig) void { //TODO: re-evaluate the value of having a comptime and runtime version of this
    cdefs.Clay__OpenTextElement(.fromRuntimeSlice(string), cdefs.Clay__StoreTextElementConfig(config));
}

/// Creates a text element with the given string and configuration
///
/// Example:
/// ```
/// text(foor_text, .{ .font_size = 24, .color = .{255, 0, 0, 255} });
/// ```
pub fn textDynamic(string: []const u8, config: TextElementConfig) void {
    cdefs.Clay__OpenTextElement(.fromSlice(string), cdefs.Clay__StoreTextElementConfig(config));
}

/// Gets an element's ID from a string
/// Generally only used for dynamic strings when ElementId.ID() can't be used
///
/// Example:
/// ```
/// const buttonId = getElementId("SubmitButton");
/// const isHovered = pointerOver(buttonId);
/// ```
pub fn getElementId(string: []const u8) ElementId {
    return cdefs.Clay_GetElementId(.fromSlice(string));
}

// Returns the internally stored scroll offset for the currently open element.
// Generally intended for use with clip elements to create scrolling containers.
pub const getScrollOffset = cdefs.Clay_GetScrollOffset;

// Returns the array of element IDs that the pointer is currently over.
fn getPointerOverIds() []ElementId {
    const ids = cdefs.Clay_GetPointerOverIds();
    return ids.internal_array[0..@intCast(ids.length)];
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

fn anyopaquePtrToAnytype(T: type, user_data: ?*anyopaque) T {
    if (T == void) {
        return {};
    } else if (@typeInfo(T) == .pointer) {
        return @ptrCast(@alignCast(@constCast(user_data)));
    } else {
        return @bitCast(@as(usize, @intFromPtr(user_data)));
    }
}

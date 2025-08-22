### Zig Bindings for clay.h

![Screenshot from 2025-01-07 17-05-01](https://github.com/user-attachments/assets/8f38e8bf-00aa-4e16-be96-b7a0d81f4313)

This repository contains Zig bindings for the [clay UI layout library](https://github.com/nicbarker/clay), as well as an example implementation of the [clay website](https://nicbarker.com/clay) in Zig.

This README is abbreviated and applies to using clay in Zig specifically: If you haven't taken a look at the [full documentation for clay](https://github.com/nicbarker/clay/blob/main/README.md), it's recommended that you take a look there first to familiarise yourself with the general concepts.

Some differences between the C API and the Zig bindings include:

 - minor naming changes
 - ability to initialize a parameter by calling a function that is part of its type's namespace for example `.fixed()` or `.layout()`
 - ability to initialize a parameter by using a public constant that is part of its type's namespace for example `.grow`

In C:
```C
CLAY({ // C macro for creating a scope
    .id = CLAY_ID("SideBar"),
    .layout = { 
        .layoutDirection = CLAY_TOP_TO_BOTTOM, 
        .sizing = { .width = CLAY_SIZING_FIXED(300), .height = CLAY_SIZING_GROW(0) }, 
        .padding = CLAY_PADDING_ALL(16), 
        .childAlignment = .{ .x = CLAY_ALIGN_X_CENTER , .y = .CLAY_ALIGN_Y_TOP },
        .childGap = 16 
    },
    .backgroundColor = COLOR_LIGHT 
}){
    // Child elements here
}
```
In Zig:
```Zig
clay.UI()(.{ // function call for creating a scope
    .id = .ID("SideBar"),
    .layout = .{
        .direction = .top_to_bottom,
        .sizing = .{ .w = .fixed(300), .h = .grow },
        .padding = .all(16),
        .child_alignment = .{ .x = .center, .y = .top },
        .child_gap = 16,
    },
    .background_color = light_grey,
})({
    // Child elements here
});
```

## installation:

Compatible Zig Version: `0.15.1`

1. Add `zclay` to the dependency list in `build.zig.zon`: 

```sh
zig fetch --save git+https://github.com/johan0A/clay-zig-bindings#v0.2.2+0.14
```

2. Config `build.zig`:

```zig
...
const zclay_dep = b.dependency("zclay", .{
    .target = target,
    .optimize = optimize,
});
compile_step.root_module.addImport("zclay", zclay_dep.module("zclay"));
...
```

## quickstart

2. Ask clay for how much static memory it needs using [clay.minMemorySize()](https://github.com/nicbarker/clay/blob/main/README.md#clay_minmemorysize), create an Arena for it to use with [clay.createArenaWithCapacityAndMemory(minMemorySize, memory)](https://github.com/nicbarker/clay/blob/main/README.md#clay_createarenawithcapacityandmemory), and initialize it with [clay.Initialize(arena)](https://github.com/nicbarker/clay/blob/main/README.md#clay_initialize).

```zig
const min_memory_size: u32 = clay.minMemorySize();
const memory = try allocator.alloc(u8, min_memory_size);
defer allocator.free(memory);
const arena: clay.Arena = clay.createArenaWithCapacityAndMemory(memory);
_ = clay.initialize(arena, .{ .h = 1000, .w = 1000 }, .{});
clay.setMeasureTextFunction(void, {}, renderer.measureText);
```

3. Provide a `measureText(text, config)` function with [clay.setMeasureTextFunction(function)](https://github.com/nicbarker/clay/blob/main/README.md#clay_setmeasuretextfunction) so that clay can measure and wrap text.

```zig
// Example measure text function
pub fn measureText(clay_text: []const u8, config: *clay.TextElementConfig, user_data: void) clay.Dimensions {
    // clay.TextElementConfig contains members such as fontId, fontSize, letterSpacing etc
    // Note: clay.String.chars is not guaranteed to be null terminated
}

// Tell clay how to measure text
clay.setMeasureTextFunction({}, measureText)
``` 

4. **Optional** - Call [clay.setPointerPosition(pointerPosition)](https://github.com/nicbarker/clay/blob/main/README.md#clay_setpointerposition) if you want to use mouse interactions.

```Zig
// Update internal pointer position for handling mouseover / click / touch events
clay.setPointerState(.{
    .x = mouse_position_x,
    .y = mouse_position_y,
}, is_left_mouse_button_down);
```

5. Call [clay.beginLayout()](https://github.com/nicbarker/clay/blob/main/README.md#clay_beginlayout) and declare your layout using the provided functions.

```Zig
const light_grey: clay.Color = .{ 224, 215, 210, 255 };
const red: clay.Color = .{ 168, 66, 28, 255 };
const orange: clay.Color = .{ 225, 138, 50, 255 };
const white: clay.Color = .{ 250, 250, 255, 255 };

const sidebar_item_layout: clay.LayoutConfig = .{ .sizing = .{ .w = .grow, .h = .fixed(50) } };

// Re-useable components are just normal functions
fn sidebarItemComponent(index: u32) void {
    clay.UI()(.{
        .id = .IDI("SidebarBlob", index),
        .layout = sidebar_item_layout,
        .background_color = orange,
    })({});
}

// An example function to begin the "root" of your layout tree
fn createLayout(profile_picture: *const rl.Texture2D) clay.ClayArray(clay.RenderCommand) {
    clay.beginLayout();
    clay.UI()(.{
        .id = .ID("OuterContainer"),
        .layout = .{ .direction = .left_to_right, .sizing = .grow, .padding = .all(16), .child_gap = 16 },
        .background_color = white,
    })({
        clay.UI()(.{
            .id = .ID("SideBar"),
            .layout = .{
                .direction = .top_to_bottom,
                .sizing = .{ .h = .grow, .w = .fixed(300) },
                .padding = .all(16),
                .child_alignment = .{ .x = .center, .y = .top },
                .child_gap = 16,
            },
            .background_color = light_grey,
        })({
            clay.UI()(.{
                .id = .ID("ProfilePictureOuter"),
                .layout = .{ .sizing = .{ .w = .grow }, .padding = .all(16), .child_alignment = .{ .x = .left, .y = .center }, .child_gap = 16 },
                .background_color = red,
            })({
                clay.UI()(.{
                    .id = .ID("ProfilePicture"),
                    .layout = .{ .sizing = .{ .h = .fixed(60), .w = .fixed(60) } },
                    .image = .{ .source_dimensions = .{ .h = 60, .w = 60 }, .image_data = @ptrCast(profile_picture) },
                })({});
                clay.text("Clay - UI Library", .{ .font_size = 24, .color = light_grey });
            });

            for (0..5) |i| sidebarItemComponent(@intCast(i));
        });

        clay.UI()(.{
            .id = .ID("MainContent"),
            .layout = .{ .sizing = .grow },
            .background_color = light_grey,
        })({
            //...
        });
    });
    return clay.endLayout();
}
```

6. Call [clay.endLayout()](https://github.com/nicbarker/clay/blob/main/README.md#clay_endlayout) and process the resulting [clay.RenderCommandArray](https://github.com/nicbarker/clay/blob/main/README.md#clay_rendercommandarray) in your choice of renderer.

```zig
pub fn clayRaylibRender(render_commands: *clay.ClayArray(clay.RenderCommand), allocator: std.mem.Allocator) void {
    var i: usize = 0;
    while (i < render_commands.length) : (i += 1) {
        const render_command = clay.renderCommandArrayGet(render_commands, @intCast(i));
        const bounding_box = render_command.bounding_box;
        switch (render_command.command_type) {
            .none => {},
            .text => {
                ...
```

Please see the [full C documentation for clay](https://github.com/nicbarker/clay/blob/main/README.md) for API details and the example folder in this repo. All public C functions and Macros have Zig binding equivalents, generally of the form `Clay_BeginLayout` (C) -> `clay.beginLayout` (zig)

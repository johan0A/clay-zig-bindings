### Zig Bindings for clay.h

![Screenshot from 2025-01-07 17-05-01](https://github.com/user-attachments/assets/8f38e8bf-00aa-4e16-be96-b7a0d81f4313)

> [!IMPORTANT]  
> Zig 0.14.0 or higher is required. (tested with zig 0.14.0-dev.2639+15fe99957)

> [!NOTE]
> This project is currently in beta.

This repository contains Zig bindings for the [clay UI layout library](https://github.com/nicbarker/clay), as well as an example implementation of the [clay website](https://nicbarker.com/clay) in Zig.

This README is abbreviated and applies to using clay in Zig specifically: If you haven't taken a look at the [full documentation for clay](https://github.com/nicbarker/clay/blob/main/README.md), it's recommended that you take a look there first to familiarise yourself with the general concepts.

Some differences between the C API and the Zig bindings include:
 - minor naming changes
 - ability to initialize a parameter by calling a function that is part of its type's namespace for example `.fixed()` or `.layout()`
 - ability to initialize a parameter by using a public constant that is part of its type's namespace for example `.grow`
 - clay.singleElem() is available to create a clay element without creating a scope

In C:
```C
// C macro for creating a scope
CLAY(
    CLAY_ID("SideBar"),
    CLAY_LAYOUT({ 
        .layoutDirection = CLAY_TOP_TO_BOTTOM, 
        .sizing = { .height = CLAY_SIZING_GROW(), .width = CLAY_SIZING_FIXED(300) }, 
        .padding = {16, 16},
        .childAlignment = { .x = CLAY_ALIGN_X_CENTER, .y = CLAY_ALIGN_Y_TOP  },
        .childGap = 16,
    }),
    CLAY_RECTANGLE({ .color = COLOR_LIGHT })
) {
    // Child elements here
}
```

In Zig:
```Zig
clay.UI(&.{ // function call to open the scope
    .ID("SideBar"),
    .layout(.{
        .direction = .TOP_TO_BOTTOM,
        .sizing = .{ .h = .grow, .w = .fixed(300) },
        .padding = .all(16),
        .child_alignment = .{ .x = .CENTER, .y = .TOP },
        .child_gap = 16,
    }),
    .rectangle(.{ .color = light_grey }),
})({
    // Child elements here
});
```

## install

1. Add `zclay` to the depency list in `build.zig.zon`: 

```sh
zig fetch --save https://github.com/johan0A/clay-zig-bindings/archive/<commit sha>.tar.gz
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
const min_memory_size: u32 = cl.minMemorySize();
const memory = try allocator.alloc(u8, min_memory_size);
defer allocator.free(memory);
const arena: cl.Arena = cl.createArenaWithCapacityAndMemory(memory);
_ = cl.initialize(arena, .{ .h = 1000, .w = 1000 }, .{});
cl.setMeasureTextFunction(renderer.measureText);
```

3. Provide a `measureText(text, config)` function with [clay.setMeasureTextFunction(function)](https://github.com/nicbarker/clay/blob/main/README.md#clay_setmeasuretextfunction) so that clay can measure and wrap text.

```zig
// Example measure text function
pub fn measureText(clay_text: []const u8, config: *clay.TextElementConfig) clay.Dimensions {
    // clay.TextElementConfig contains members such as fontId, fontSize, letterSpacing etc
    // Note: clay.String.chars is not guaranteed to be null terminated
}

// Tell clay how to measure text
clay.setMeasureTextFunction(measureText)
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
const light_grey: cl.Color = .{ 224, 215, 210, 255 };
const red: cl.Color = .{ 168, 66, 28, 255 };
const orange: cl.Color = .{ 225, 138, 50, 255 };
const white: cl.Color = .{ 250, 250, 255, 255 };

const sidebar_item_layout: cl.LayoutConfig = .{ .sizing = .{ .w = .grow, .h = .fixed(50) } };

// Re-useable components are just normal functions
fn sidebarItemComponent(index: usize) void {
    cl.UI(&.{
        .IDI("SidebarBlob", @intCast(index)),
        .layout(sidebar_item_layout),
        .rectangle(.{ .color = orange }),
    })({});
}

// An example function to begin the "root" of your layout tree
fn createLayout(profile_picture: *const rl.Texture2D) cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();
    cl.UI(&.{
        .ID("OuterContainer"),
        .layout(.{ .direction = .LEFT_TO_RIGHT, .sizing = .grow, .padding = .all(16), .child_gap = 16 }),
        .rectangle(.{ .color = white }),
    })({
        cl.UI(&.{
            .ID("SideBar"),
            .layout(.{
                .direction = .TOP_TO_BOTTOM,
                .sizing = .{ .h = .grow, .w = .fixed(300) },
                .padding = .all(16),
                .child_alignment = .{ .x = .CENTER, .y = .TOP },
                .child_gap = 16,
            }),
            .rectangle(.{ .color = light_grey }),
        })({
            cl.UI(&.{
                .ID("ProfilePictureOuter"),
                .layout(.{ .sizing = .{ .w = .grow }, .padding = .all(16), .child_alignment = .{ .x = .LEFT, .y = .CENTER }, .child_gap = 16 }),
                .rectangle(.{ .color = red }),
            })({
                cl.UI(&.{
                    .ID("ProfilePicture"),
                    .layout(.{ .sizing = .{ .h = .fixed(60), .w = .fixed(60) } }),
                    .image(.{ .source_dimensions = .{ .h = 60, .w = 60 }, .image_data = @ptrCast(profile_picture) }),
                })({});
                cl.text("Clay - UI Library", .text(.{ .font_size = 24, .color = light_grey }));
            });

            for (0..5) |i| sidebarItemComponent(i);
        });

        cl.UI(&.{
            .ID("MainContent"),
            .layout(.{ .sizing = .grow }),
            .rectangle(.{ .color = light_grey }),
        })({
            //...
        });
    });
    return cl.endLayout();
}
```

6. Call [clay.endLayout()](https://github.com/nicbarker/clay/blob/main/README.md#clay_endlayout) and process the resulting [clay.RenderCommandArray](https://github.com/nicbarker/clay/blob/main/README.md#clay_rendercommandarray) in your choice of renderer.

```zig
render_commands: clay.ClayArray(clay.RenderCommand) = clay.endLayout(window_width, window_height)

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

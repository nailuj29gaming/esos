const zigvale = @import("zigvale").v2;
const tags = @import("./stivale/tags.zig").fb_tag;

export var stack_bytes: [16 * 1024:0]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export const header linksection(".stivale2hdr") = zigvale.Header {
    .stack = &stack_bytes[stack_bytes.len], // reverse stack_bytes
    .flags = .{
        .higher_half = 1,
        .pmr = 1,
        .fully_virtual_mapping = 1,
    },
    .tags = &tags.tag,
};

comptime {
    const entry = zigvale.entryPoint(kmain);
    @export(entry, .{ .name = "_start", .linkage = .Strong });
}

pub fn kmain(zv: *const zigvale.Struct.Parsed) noreturn {
    if (zv.terminal == null) {
        while (true) {
            asm volatile ("hlt");
        }
    }

    const term_write = @intToPtr(fn([*]const u8, usize) callconv(.C) void, zv.terminal.?.term_write);

    term_write("Hello World", 11);

    while (true) {
        asm volatile ("hlt");
    }
}
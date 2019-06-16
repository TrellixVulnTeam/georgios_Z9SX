const platform = @import("platform.zig");

pub const Color = enum {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

inline fn combine_colors(fg: Color, bg: Color) u8 {
    return @enumToInt(fg) | (@intCast(u8, @enumToInt(bg)) << 4);
}

inline fn colored_char(c: u8, colors: u8) u16 {
    return @intCast(u16, c) | (@intCast(u16, colors) << 8);
}

const width: u32 = 80;
const height: u32 = 25;
const command_port: u16 = 0x03D4;
const data_port: u16 = 0x03D5;
const high_byte_command: u8 = 14;
const low_byte_command: u8 = 15;

var row: u32 = 0;
var column: u32 = 0;
var default_colors: u8 = combine_colors(Color.LightGrey, Color.Black);

var buffer: [*]u16 = undefined;

pub fn initialize() void {
    buffer = @intToPtr([*]u16, platform.offset(0xB8000));
    fill_screen(' ');
    cursor(0, 0);
}

pub fn set_colors(fg: Color, bg: Color) void {
    default_colors = combine_colors(fg, bg);
}

pub fn new_page() void {
    row = 0;
    column = 0;
}

pub fn place_char(c: u8, x: u32, y: u32) void {
    const index: u32 = (y *% width) +% x;
    buffer[index] = colored_char(c, default_colors);
}

pub fn fill_screen(c: u8) void {
    var y: u32 = 0;
    while (y < height) : (y +%= 1) {
        var x: u32 = 0;
        while (x < width) : (x +%= 1) {
            place_char(c, x, y);
        }
    }
}

pub fn cursor(x: u32, y: u32) void {
    const index: u32 = (y *% width) +% x;
    platform.out8(command_port, high_byte_command);
    platform.out8(data_port, @intCast(u8, (index >> 8) & 0xFF));
    platform.out8(command_port, low_byte_command);
    platform.out8(data_port, @intCast(u8, index & 0xFF));
}

pub fn scroll() void {
    var y: u32 = 1;
    while (y < height) : (y +%= 1) {
        var x: u32 = 0;
        while (x < width) : (x +%= 1) {
            const src: u32 = (y *% width) +% x;
            const dest: u32 = ((y-1) *% width) +% x;
            buffer[dest] = buffer[src];
        }
    }
    var x: u32 = 0;
    while (x < width) : (x +%= 1) {
        place_char(' ', x, height-1);
    }
}

pub fn print_char(c: u8) void {
    if (c == '\n') {
        column = 0;
        if (row == (height-1)) {
            scroll();
        } else {
            row += 1;
        }
        cursor(column + 1, row);
    } else {
        column += 1;
        if (column == width) {
            if (row == (height-1)) {
                scroll();
            } else {
                row += 1;
            }
            column = 0;
        }
        place_char(c, column, row);
        cursor(column + 1, row);
    }
}
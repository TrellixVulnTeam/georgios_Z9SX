const builtin = @import("builtin");

pub inline fn KiB(x: usize) usize {
    return x * (1 << 10);
}

pub inline fn MiB(x: usize) usize {
    return x * (1 << 20);
}

pub inline fn GiB(x: usize) usize {
    return x * (1 << 30);
}

pub inline fn TiB(x: usize) usize {
    return x * (1 << 40);
}

pub inline fn alignment(value: usize, align_by: usize) usize {
    return (value + align_by - 1) & -%(align_by);
}

pub inline fn padding(value: usize, align_by: usize) usize {
    return -%value & (align_by - 1);
}

pub fn isspace(c: u8) bool {
    return c == ' ' or c == '\n' or c == '\t' or c == '\r';
}

pub fn zero_init(comptime Type: type) Type {
    comptime const Traits = @typeInfo(Type);
    comptime var CastThrough = Type;
    switch (Traits) {
        builtin.TypeId.Int => |int_type| {
            CastThrough = Type;
        },
        builtin.TypeId.Bool => {
            return false;
        },
        builtin.TypeId.Struct => |struct_type| {
            if (struct_type.layout != builtin.TypeInfo.ContainerLayout.Packed) {
                @compileError("Struct must be packed!");
            }
            var struct_var: Type = undefined;
            inline for (struct_type.fields) |field| {
                @field(struct_var, field.name) = zero_init(field.field_type);
            }
            return struct_var;
        },
        else => CastThrough = @IntType(false, @sizeOf(Type) * 8),
    }
    return @bitCast(Type, @intCast(CastThrough, 0));
}

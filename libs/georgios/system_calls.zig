// Generated by scripts/codegen/generate_system_calls.py from
// kernel/platform/system_calls.zig. See system_calls.zig for more info.

const utils = @import("utils");
const georgios = @import("georgios.zig");
const ErrorCode = enum(u32) {
    Unknown = 1,
    OutOfBounds = 2,
    NotEnoughSource = 3,
    NotEnoughDestination = 4,
    OutOfMemory = 5,
    ZeroSizedAlloc = 6,
    InvalidFree = 7,
    FileNotFound = 8,
    NotADirectory = 9,
    NotAFile = 10,
    InvalidFilesystem = 11,
    Unsupported = 12,
    Internal = 13,
    InvalidFileId = 14,
    InvalidElfFile = 15,
    InvalidElfObjectType = 16,
    InvalidElfPlatform = 17,
    _,
};

pub fn ValueOrError(comptime ValueType: type, comptime ErrorType: type) type {
    return union (enum) {
        const Self = @This();

        value: ValueType,
        error_code: ErrorCode,

        pub fn set_value(self: *Self, value: ValueType) void {
            self.* = Self{.value = value};
        }

        pub fn set_error(self: *Self, err: ErrorType) void {
            self.* = Self{.error_code = switch (ErrorType) {
                georgios.ExecError => switch (err) {
                    georgios.ExecError.FileNotFound => ErrorCode.FileNotFound,
                    georgios.ExecError.NotADirectory => ErrorCode.NotADirectory,
                    georgios.ExecError.NotAFile => ErrorCode.NotAFile,
                    georgios.ExecError.InvalidFilesystem => ErrorCode.InvalidFilesystem,
                    georgios.ExecError.Unsupported => ErrorCode.Unsupported,
                    georgios.ExecError.Internal => ErrorCode.Internal,
                    georgios.ExecError.InvalidFileId => ErrorCode.InvalidFileId,
                    georgios.ExecError.Unknown => ErrorCode.Unknown,
                    georgios.ExecError.OutOfBounds => ErrorCode.OutOfBounds,
                    georgios.ExecError.NotEnoughSource => ErrorCode.NotEnoughSource,
                    georgios.ExecError.NotEnoughDestination => ErrorCode.NotEnoughDestination,
                    georgios.ExecError.OutOfMemory => ErrorCode.OutOfMemory,
                    georgios.ExecError.ZeroSizedAlloc => ErrorCode.ZeroSizedAlloc,
                    georgios.ExecError.InvalidFree => ErrorCode.InvalidFree,
                    georgios.ExecError.InvalidElfFile => ErrorCode.InvalidElfFile,
                    georgios.ExecError.InvalidElfObjectType => ErrorCode.InvalidElfObjectType,
                    georgios.ExecError.InvalidElfPlatform => ErrorCode.InvalidElfPlatform,
                },
                georgios.fs.Error => switch (err) {
                    georgios.fs.Error.FileNotFound => ErrorCode.FileNotFound,
                    georgios.fs.Error.NotADirectory => ErrorCode.NotADirectory,
                    georgios.fs.Error.NotAFile => ErrorCode.NotAFile,
                    georgios.fs.Error.InvalidFilesystem => ErrorCode.InvalidFilesystem,
                    georgios.fs.Error.Unsupported => ErrorCode.Unsupported,
                    georgios.fs.Error.Internal => ErrorCode.Internal,
                    georgios.fs.Error.InvalidFileId => ErrorCode.InvalidFileId,
                    georgios.fs.Error.Unknown => ErrorCode.Unknown,
                    georgios.fs.Error.OutOfBounds => ErrorCode.OutOfBounds,
                    georgios.fs.Error.NotEnoughSource => ErrorCode.NotEnoughSource,
                    georgios.fs.Error.NotEnoughDestination => ErrorCode.NotEnoughDestination,
                    georgios.fs.Error.OutOfMemory => ErrorCode.OutOfMemory,
                    georgios.fs.Error.ZeroSizedAlloc => ErrorCode.ZeroSizedAlloc,
                    georgios.fs.Error.InvalidFree => ErrorCode.InvalidFree,
                },
                georgios.io.FileError => switch (err) {
                    georgios.io.FileError.Unsupported => ErrorCode.Unsupported,
                    georgios.io.FileError.Internal => ErrorCode.Internal,
                    georgios.io.FileError.InvalidFileId => ErrorCode.InvalidFileId,
                    georgios.io.FileError.Unknown => ErrorCode.Unknown,
                    georgios.io.FileError.OutOfBounds => ErrorCode.OutOfBounds,
                    georgios.io.FileError.NotEnoughSource => ErrorCode.NotEnoughSource,
                    georgios.io.FileError.NotEnoughDestination => ErrorCode.NotEnoughDestination,
                    georgios.io.FileError.OutOfMemory => ErrorCode.OutOfMemory,
                    georgios.io.FileError.ZeroSizedAlloc => ErrorCode.ZeroSizedAlloc,
                    georgios.io.FileError.InvalidFree => ErrorCode.InvalidFree,
                },
                else => @compileError(
                    "Invalid ErrorType for " ++ @typeName(Self) ++ ".set_error: " ++
                    @typeName(ErrorType)),
            }};
        }

        pub fn get(self: *const Self) ErrorType!ValueType {
            return switch (self.*) {
                Self.value => |value| return value,
                Self.error_code => |error_code| switch (ErrorType) {
                    georgios.ExecError => switch (error_code) {
                        .FileNotFound => georgios.ExecError.FileNotFound,
                        .NotADirectory => georgios.ExecError.NotADirectory,
                        .NotAFile => georgios.ExecError.NotAFile,
                        .InvalidFilesystem => georgios.ExecError.InvalidFilesystem,
                        .Unsupported => georgios.ExecError.Unsupported,
                        .Internal => georgios.ExecError.Internal,
                        .InvalidFileId => georgios.ExecError.InvalidFileId,
                        .Unknown => georgios.ExecError.Unknown,
                        .OutOfBounds => georgios.ExecError.OutOfBounds,
                        .NotEnoughSource => georgios.ExecError.NotEnoughSource,
                        .NotEnoughDestination => georgios.ExecError.NotEnoughDestination,
                        .OutOfMemory => georgios.ExecError.OutOfMemory,
                        .ZeroSizedAlloc => georgios.ExecError.ZeroSizedAlloc,
                        .InvalidFree => georgios.ExecError.InvalidFree,
                        .InvalidElfFile => georgios.ExecError.InvalidElfFile,
                        .InvalidElfObjectType => georgios.ExecError.InvalidElfObjectType,
                        .InvalidElfPlatform => georgios.ExecError.InvalidElfPlatform,
                        _ => utils.Error.Unknown,
                    },
                    georgios.fs.Error => switch (error_code) {
                        .FileNotFound => georgios.fs.Error.FileNotFound,
                        .NotADirectory => georgios.fs.Error.NotADirectory,
                        .NotAFile => georgios.fs.Error.NotAFile,
                        .InvalidFilesystem => georgios.fs.Error.InvalidFilesystem,
                        .Unsupported => georgios.fs.Error.Unsupported,
                        .Internal => georgios.fs.Error.Internal,
                        .InvalidFileId => georgios.fs.Error.InvalidFileId,
                        .Unknown => georgios.fs.Error.Unknown,
                        .OutOfBounds => georgios.fs.Error.OutOfBounds,
                        .NotEnoughSource => georgios.fs.Error.NotEnoughSource,
                        .NotEnoughDestination => georgios.fs.Error.NotEnoughDestination,
                        .OutOfMemory => georgios.fs.Error.OutOfMemory,
                        .ZeroSizedAlloc => georgios.fs.Error.ZeroSizedAlloc,
                        .InvalidFree => georgios.fs.Error.InvalidFree,
                        else => utils.Error.Unknown,
                    },
                    georgios.io.FileError => switch (error_code) {
                        .Unsupported => georgios.io.FileError.Unsupported,
                        .Internal => georgios.io.FileError.Internal,
                        .InvalidFileId => georgios.io.FileError.InvalidFileId,
                        .Unknown => georgios.io.FileError.Unknown,
                        .OutOfBounds => georgios.io.FileError.OutOfBounds,
                        .NotEnoughSource => georgios.io.FileError.NotEnoughSource,
                        .NotEnoughDestination => georgios.io.FileError.NotEnoughDestination,
                        .OutOfMemory => georgios.io.FileError.OutOfMemory,
                        .ZeroSizedAlloc => georgios.io.FileError.ZeroSizedAlloc,
                        .InvalidFree => georgios.io.FileError.InvalidFree,
                        else => utils.Error.Unknown,
                    },
                    else => @compileError(
                            "Invalid ErrorType for " ++ @typeName(Self) ++ ".get: " ++
                            @typeName(ErrorType)),
                },
            };
        }
    };
}


pub inline fn print_string(s: []const u8) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 0)),
        [arg1] "{ebx}" (@ptrToInt(&s)),
        );
}

pub inline fn yield() void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 2)),
        );
}

pub inline fn exit(status: u8) noreturn {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 3)),
        [arg1] "{ebx}" (status),
        );
    unreachable;
}

pub inline fn exec(info: *const georgios.ProcessInfo) georgios.ExecError!void {
    var rv: ValueOrError(void, georgios.ExecError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 4)),
        [arg1] "{ebx}" (info),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub inline fn get_key() georgios.keyboard.Event {
    var key: georgios.keyboard.Event = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 5)),
        [arg1] "{ebx}" (@ptrToInt(&key)),
        );
    return key;
}

pub inline fn next_dir_entry(iter: *georgios.DirEntry) bool {
    var rv: bool = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 6)),
        [arg1] "{ebx}" (iter),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv;
}

pub inline fn print_hex(value: u32) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 7)),
        [arg1] "{ebx}" (value),
        );
}

pub inline fn file_open(path: []const u8) georgios.fs.Error!georgios.io.File.Id {
    var rv: ValueOrError(georgios.io.File.Id, georgios.fs.Error) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 8)),
        [arg1] "{ebx}" (@ptrToInt(&path)),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub inline fn file_read(id: georgios.io.File.Id, to: []u8) georgios.io.FileError!usize {
    var rv: ValueOrError(usize, georgios.io.FileError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 9)),
        [arg1] "{ebx}" (id),
        [arg2] "{ecx}" (@ptrToInt(&to)),
        [arg3] "{edx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub inline fn file_close(id: georgios.io.File.Id) georgios.io.FileError!void {
    var rv: ValueOrError(void, georgios.io.FileError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 10)),
        [arg1] "{ebx}" (id),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}
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
    NoCurrentProcess = 18,
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
                    georgios.ExecError.NoCurrentProcess => ErrorCode.NoCurrentProcess,
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
                georgios.threading.Error => switch (err) {
                    georgios.threading.Error.NoCurrentProcess => ErrorCode.NoCurrentProcess,
                    georgios.threading.Error.Unknown => ErrorCode.Unknown,
                    georgios.threading.Error.OutOfBounds => ErrorCode.OutOfBounds,
                    georgios.threading.Error.NotEnoughSource => ErrorCode.NotEnoughSource,
                    georgios.threading.Error.NotEnoughDestination => ErrorCode.NotEnoughDestination,
                    georgios.threading.Error.OutOfMemory => ErrorCode.OutOfMemory,
                    georgios.threading.Error.ZeroSizedAlloc => ErrorCode.ZeroSizedAlloc,
                    georgios.threading.Error.InvalidFree => ErrorCode.InvalidFree,
                },
                georgios.ThreadingOrFsError => switch (err) {
                    georgios.ThreadingOrFsError.FileNotFound => ErrorCode.FileNotFound,
                    georgios.ThreadingOrFsError.NotADirectory => ErrorCode.NotADirectory,
                    georgios.ThreadingOrFsError.NotAFile => ErrorCode.NotAFile,
                    georgios.ThreadingOrFsError.InvalidFilesystem => ErrorCode.InvalidFilesystem,
                    georgios.ThreadingOrFsError.Unsupported => ErrorCode.Unsupported,
                    georgios.ThreadingOrFsError.Internal => ErrorCode.Internal,
                    georgios.ThreadingOrFsError.InvalidFileId => ErrorCode.InvalidFileId,
                    georgios.ThreadingOrFsError.Unknown => ErrorCode.Unknown,
                    georgios.ThreadingOrFsError.OutOfBounds => ErrorCode.OutOfBounds,
                    georgios.ThreadingOrFsError.NotEnoughSource => ErrorCode.NotEnoughSource,
                    georgios.ThreadingOrFsError.NotEnoughDestination => ErrorCode.NotEnoughDestination,
                    georgios.ThreadingOrFsError.OutOfMemory => ErrorCode.OutOfMemory,
                    georgios.ThreadingOrFsError.ZeroSizedAlloc => ErrorCode.ZeroSizedAlloc,
                    georgios.ThreadingOrFsError.InvalidFree => ErrorCode.InvalidFree,
                    georgios.ThreadingOrFsError.NoCurrentProcess => ErrorCode.NoCurrentProcess,
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
                        .NoCurrentProcess => georgios.ExecError.NoCurrentProcess,
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
                    georgios.threading.Error => switch (error_code) {
                        .NoCurrentProcess => georgios.threading.Error.NoCurrentProcess,
                        .Unknown => georgios.threading.Error.Unknown,
                        .OutOfBounds => georgios.threading.Error.OutOfBounds,
                        .NotEnoughSource => georgios.threading.Error.NotEnoughSource,
                        .NotEnoughDestination => georgios.threading.Error.NotEnoughDestination,
                        .OutOfMemory => georgios.threading.Error.OutOfMemory,
                        .ZeroSizedAlloc => georgios.threading.Error.ZeroSizedAlloc,
                        .InvalidFree => georgios.threading.Error.InvalidFree,
                        else => utils.Error.Unknown,
                    },
                    georgios.ThreadingOrFsError => switch (error_code) {
                        .FileNotFound => georgios.ThreadingOrFsError.FileNotFound,
                        .NotADirectory => georgios.ThreadingOrFsError.NotADirectory,
                        .NotAFile => georgios.ThreadingOrFsError.NotAFile,
                        .InvalidFilesystem => georgios.ThreadingOrFsError.InvalidFilesystem,
                        .Unsupported => georgios.ThreadingOrFsError.Unsupported,
                        .Internal => georgios.ThreadingOrFsError.Internal,
                        .InvalidFileId => georgios.ThreadingOrFsError.InvalidFileId,
                        .Unknown => georgios.ThreadingOrFsError.Unknown,
                        .OutOfBounds => georgios.ThreadingOrFsError.OutOfBounds,
                        .NotEnoughSource => georgios.ThreadingOrFsError.NotEnoughSource,
                        .NotEnoughDestination => georgios.ThreadingOrFsError.NotEnoughDestination,
                        .OutOfMemory => georgios.ThreadingOrFsError.OutOfMemory,
                        .ZeroSizedAlloc => georgios.ThreadingOrFsError.ZeroSizedAlloc,
                        .InvalidFree => georgios.ThreadingOrFsError.InvalidFree,
                        .NoCurrentProcess => georgios.ThreadingOrFsError.NoCurrentProcess,
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


pub fn print_string(s: []const u8) callconv(.Inline) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 0)),
        [arg1] "{ebx}" (@ptrToInt(&s)),
        );
}

pub fn yield() callconv(.Inline) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 2)),
        );
}

pub fn exit(status: u8) callconv(.Inline) noreturn {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 3)),
        [arg1] "{ebx}" (status),
        );
    unreachable;
}

pub fn exec(info: *const georgios.ProcessInfo) callconv(.Inline) georgios.ExecError!void {
    var rv: ValueOrError(void, georgios.ExecError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 4)),
        [arg1] "{ebx}" (info),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn get_key(blocking: georgios.Blocking) callconv(.Inline) ?georgios.keyboard.Event {
    var key: ?georgios.keyboard.Event = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 5)),
        [arg1] "{ebx}" (@ptrToInt(&blocking)),
        [arg2] "{ecx}" (@ptrToInt(&key)),
        );
    return key;
}

pub fn next_dir_entry(iter: *georgios.DirEntry) callconv(.Inline) bool {
    var rv: bool = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 6)),
        [arg1] "{ebx}" (iter),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv;
}

pub fn print_hex(value: u32) callconv(.Inline) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 7)),
        [arg1] "{ebx}" (value),
        );
}

pub fn file_open(path: []const u8) callconv(.Inline) georgios.fs.Error!georgios.io.File.Id {
    var rv: ValueOrError(georgios.io.File.Id, georgios.fs.Error) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 8)),
        [arg1] "{ebx}" (@ptrToInt(&path)),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn file_read(id: georgios.io.File.Id, to: []u8) callconv(.Inline) georgios.io.FileError!usize {
    var rv: ValueOrError(usize, georgios.io.FileError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 9)),
        [arg1] "{ebx}" (id),
        [arg2] "{ecx}" (@ptrToInt(&to)),
        [arg3] "{edx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn file_write(id: georgios.io.File.Id, from: []const u8) callconv(.Inline) georgios.io.FileError!usize {
    var rv: ValueOrError(usize, georgios.io.FileError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 10)),
        [arg1] "{ebx}" (id),
        [arg2] "{ecx}" (@ptrToInt(&from)),
        [arg3] "{edx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn file_seek(id: georgios.io.File.Id, offset: isize, seek_type: georgios.io.File.SeekType) callconv(.Inline) georgios.io.FileError!usize {
    var rv: ValueOrError(usize, georgios.io.FileError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 11)),
        [arg1] "{ebx}" (id),
        [arg2] "{ecx}" (offset),
        [arg3] "{edx}" (seek_type),
        [arg4] "{edi}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn file_close(id: georgios.io.File.Id) callconv(.Inline) georgios.io.FileError!void {
    var rv: ValueOrError(void, georgios.io.FileError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 12)),
        [arg1] "{ebx}" (id),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn get_cwd(buffer: []u8) callconv(.Inline) georgios.threading.Error![]const u8 {
    var rv: ValueOrError([]const u8, georgios.threading.Error) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 13)),
        [arg1] "{ebx}" (@ptrToInt(&buffer)),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn set_cwd(dir: []const u8) callconv(.Inline) georgios.ThreadingOrFsError!void {
    var rv: ValueOrError(void, georgios.ThreadingOrFsError) = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 14)),
        [arg1] "{ebx}" (@ptrToInt(&dir)),
        [arg2] "{ecx}" (@ptrToInt(&rv)),
        );
    return rv.get();
}

pub fn sleep_milliseconds(ms: u64) callconv(.Inline) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 15)),
        [arg1] "{ebx}" (@ptrToInt(&ms)),
        );
}

pub fn sleep_seconds(s: u64) callconv(.Inline) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 16)),
        [arg1] "{ebx}" (@ptrToInt(&s)),
        );
}

pub fn time() callconv(.Inline) u64 {
    var rv: u64 = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 17)),
        [arg1] "{ebx}" (@ptrToInt(&rv)),
        );
    return rv;
}

pub fn get_process_id() callconv(.Inline) u32 {
    var rv: u32 = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 18)),
        [arg1] "{ebx}" (@ptrToInt(&rv)),
        );
    return rv;
}

pub fn get_thread_id() callconv(.Inline) u32 {
    var rv: u32 = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 19)),
        [arg1] "{ebx}" (@ptrToInt(&rv)),
        );
    return rv;
}

pub fn overflow_kernel_stack() callconv(.Inline) void {
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 20)),
        );
}

pub fn console_width() callconv(.Inline) u32 {
    var rv: u32 = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 21)),
        [arg1] "{ebx}" (@ptrToInt(&rv)),
        );
    return rv;
}

pub fn console_height() callconv(.Inline) u32 {
    var rv: u32 = undefined;
    asm volatile ("int $100" ::
        [syscall_number] "{eax}" (@as(u32, 22)),
        [arg1] "{ebx}" (@ptrToInt(&rv)),
        );
    return rv;
}

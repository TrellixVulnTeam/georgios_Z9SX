const utils = @import("utils");
const georgios = @import("georgios");
const Info = georgios.ProcessInfo;

const platform = @import("platform.zig");
const pthreading = platform.impl.threading;
const kernel = @import("kernel.zig");
const memory = @import("memory.zig");
const print = @import("print.zig");
const MappedList = @import("mapped_list.zig").MappedList;

pub const debug = false;

pub const Error = georgios.threading.Error;

pub const Thread = struct {
    pub const Id = u32;

    pub const State = enum {
        Run,
        Wait,
    };

    id: Id = undefined,
    state: State = .Run,
    // TODO: Support multiple waits?
    wake_on_exit: ?*Thread = null,
    kernel_mode: bool = false,
    impl: pthreading.ThreadImpl = undefined,
    process: ?*Process = null,
    prev_in_system: ?*Thread = null,
    next_in_system: ?*Thread = null,
    /// Address of First Instruction
    entry: usize = 0,

    pub fn init(self: *Thread, boot_thread: bool) Error!void {
        if (self.process) |process| {
            if (process.info) |*info| {
                self.kernel_mode = info.kernel_mode;
            }
        }
        try self.impl.init(self, boot_thread);
    }

    pub fn start(self: *Thread) Error!void {
        try self.impl.start();
    }

    pub fn finish(self: *Thread) void {
        if (self.wake_on_exit) |other| {
            other.state = .Run;
        }
    }
};

pub const Process = struct {
    pub const Id = u32;

    info: ?Info = null,
    id: Id = undefined,
    impl: pthreading.ProcessImpl = .{},
    main_thread: Thread = .{},
    /// Address of First Instruction for Main Thread
    entry: usize = 0,
    /// Current Working Directory
    cwd: ?[]const u8 = null,

    pub fn init(self: *Process, current: ?*Process) Error!void {
        // TODO: Cleanup on failure

        if (self.info) |*info| {
            // Duplicate info data because we can't trust it will stay.
            const path_temp = try kernel.memory.small_alloc.alloc_array(u8, info.path.len);
            _ = utils.memory_copy_truncate(path_temp, info.path);
            info.path = path_temp;
            if (info.name.len > 0) {
                const name_temp =
                    try kernel.memory.small_alloc.alloc_array(u8, info.name.len);
                _ = utils.memory_copy_truncate(name_temp, info.name);
                info.name = name_temp;
            }
            if (info.args.len > 0) {
                const args_temp =
                    try kernel.memory.small_alloc.alloc_array([]u8, info.args.len);
                for (info.args) |arg, i| {
                    if (arg.len > 0) {
                        args_temp[i] = try kernel.memory.small_alloc.alloc_array(u8, arg.len);
                        _ = utils.memory_copy_truncate(args_temp[i], arg);
                    } else {
                        args_temp[i] = utils.make_slice(u8, @intToPtr([*]u8, 1024), 0);
                    }
                }
                info.args = args_temp;
            }
        }

        try self.set_cwd(if (current) |c| c.cwd.? else "/");

        try self.impl.init(self);
        self.main_thread.process = self;
        try self.main_thread.init(false);
    }

    pub fn start(self: *Process) Error!void {
        self.main_thread.entry = self.entry;
        try self.impl.start();
    }

    pub fn address_space_copy(self: *Process,
            address: usize, data: []const u8) memory.AllocError!void {
        try self.impl.address_space_copy(address, data);
    }

    pub fn address_space_set(self: *Process,
            address: usize, byte: u8, len: usize) memory.AllocError!void {
        try self.impl.address_space_set(address, byte, len);
    }

    pub fn set_cwd(self: *Process, dir: []const u8) Error!void {
        const new_cwd = try kernel.memory.small_alloc.alloc_array(u8, dir.len);
        _ = utils.memory_copy_truncate(new_cwd, dir);
        if (self.cwd) |cwd| {
            try kernel.memory.small_alloc.free_array(cwd);
        }
        self.cwd = new_cwd;
    }
};

pub const Manager = struct {
    fn pid_eql(a: Process.Id, b: Process.Id) bool {
        return a == b;
    }

    fn pid_cmp(a: Process.Id, b: Process.Id) bool {
        return a > b;
    }

    const ProcessList = MappedList(Process.Id, *Process, pid_eql, pid_cmp);

    idle_thread: Thread = .{.kernel_mode = true, .state = .Wait},
    boot_thread: Thread = .{.kernel_mode = true},
    next_thread_id: Thread.Id = 0,
    current_thread: ?*Thread = null,
    head_thread: ?*Thread = null,
    tail_thread: ?*Thread = null,
    process_list: ProcessList = undefined,
    next_process_id: Process.Id = 0,
    current_process: ?*Process = null,
    waiting_for_keyboard: ?*Thread = null,

    pub fn init(self: *Manager) Error!void {
        self.process_list = .{.alloc = kernel.memory.small_alloc};
        try self.idle_thread.init(false);
        self.idle_thread.entry = @ptrToInt(platform.idle);
        try self.boot_thread.init(true);
        self.current_thread = &self.boot_thread;
        platform.disable_interrupts();
        self.insert_thread(&self.idle_thread);
        self.insert_thread(&self.boot_thread);
        platform.enable_interrupts();
    }

    pub fn new_process_i(self: *Manager) Error!*Process {
        const p = try kernel.memory.small_alloc.alloc(Process);
        p.* = .{.info = undefined};
        return p;
    }

    pub fn new_process(self: *Manager, info: *const Info) Error!*Process {
        const p = try self.new_process_i();
        p.info = info.*;
        try p.init(self.current_process);
        return p;
    }

    pub fn start_process(self: *Manager, process: *Process) Error!void {
        platform.disable_interrupts();
        // Assign ID
        process.id = self.next_process_id;
        self.next_process_id += 1;

        // Start
        try self.process_list.push_back(process.id, process);
        self.insert_thread(&process.main_thread);
        try process.start();
    }

    pub fn insert_thread(self: *Manager, thread: *Thread) void {
        // Assign ID
        thread.id = self.next_thread_id;
        self.next_thread_id += 1;

        // Insert into Thread List
        if (self.head_thread == null) {
            self.head_thread = thread;
        }
        if (self.tail_thread) |tail| {
            tail.next_in_system = thread;
        }
        thread.prev_in_system = self.tail_thread;
        thread.next_in_system = null;
        self.tail_thread = thread;
    }

    pub fn remove_process(self: *Manager, process: *Process) void {
        _ = self.process_list.find_remove(process.id)
            catch @panic("remove_process: process_list.find_remove");
        kernel.memory.small_alloc.free(process)
            catch @panic("remove_process: free(process)");
    }

    pub fn remove_thread(self: *Manager, thread: *Thread) void {
        if (thread.next_in_system) |nt| {
            nt.prev_in_system = thread.prev_in_system;
        }
        if (thread.prev_in_system) |pt| {
            pt.next_in_system = thread.next_in_system;
        }
        if (self.head_thread == thread) {
            self.head_thread = thread.next_in_system;
        }
        if (self.tail_thread == thread) {
            self.tail_thread = thread.prev_in_system;
        }
        thread.finish();
        if (thread.process) |process| {
            if (thread == &process.main_thread) {
                self.remove_process(process);
            }
        }
    }

    pub fn remove_current_thread(self: *Manager) void {
        platform.disable_interrupts();
        if (self.current_thread) |thread| {
            if (debug) print.format("Thread {} has Finished\n", .{thread.id});
            self.remove_thread(thread);
            // TODO: Cleanup Process, Memory
            while (true) {
                self.yield();
            }
        } else {
            @panic("remove_current_thread: no current thread");
        }
        @panic("remove_current_thread: reached end");
    }

    fn next_from(self: *const Manager, thread_maybe: ?*Thread) ?*Thread {
        if (thread_maybe) |thread| {
            const nt = thread.next_in_system orelse self.head_thread;
            if (debug) print.format("+{}->{}+", .{thread.id, nt.?.id});
            return nt;
        }
        return null;
    }

    fn next(self: *Manager) ?*Thread {
        var next_thread: ?*Thread = null;
        var thread = self.current_thread;
        while (next_thread == null) {
            thread = self.next_from(thread);
            if (thread) |t| {
                if (t == self.current_thread.?) {
                    if (self.current_thread.?.state != .Run) {
                        if (debug) print.string("&I&");
                        self.idle_thread.state = .Run;
                        next_thread = &self.idle_thread;
                    } else {
                        if (debug) print.string("&C&");
                    }
                    break;
                }
                if (t.state == .Run) {
                    next_thread = t;
                }
            } else break;
        }
        if (next_thread) |nt| {
            if (nt != &self.idle_thread and self.idle_thread.state == .Run) {
                if (debug) print.string("&i&");
                self.idle_thread.state = .Wait;
            }
        }
        if (debug) {
            if (next_thread) |nt| {
                print.format("({})", .{nt.id});
            } else {
                print.string("(null)");
            }
        }
        return next_thread;
    }

    pub fn yield(self: *Manager) void {
        platform.disable_interrupts();
        if (self.next()) |next_thread| {
            next_thread.impl.switch_to();
        }
    }

    pub fn process_is_running(self: *Manager, id: Process.Id) bool {
        return self.process_list.find(id) != null;
    }

    pub fn wait_for_process(self: *Manager, id: Process.Id) void {
        if (debug) print.format("<Wait for pid {}>\n", .{id});
        platform.disable_interrupts();
        if (self.process_list.find(id)) |proc| {
            if (debug) print.string("<pid found>");
            if (proc.main_thread.wake_on_exit != null)
                @panic("yield_while_process_is_running: wake_on_exit not null");
            self.current_thread.?.state = .Wait;
            proc.main_thread.wake_on_exit = self.current_thread;
            self.yield();
        }
        if (debug) print.format("<Wait for pid {} is done>\n", .{id});
    }

    // TODO Make this and keyboard_event_occured generic
    pub fn wait_for_keyboard(self: *Manager) void {
        platform.disable_interrupts();
        self.current_thread.?.state = .Wait;
        self.waiting_for_keyboard = self.current_thread;
        self.yield();
    }

    pub fn keyboard_event_occured(self: *Manager) void {
        if (self.waiting_for_keyboard) |t| {
            t.state = .Run;
            self.waiting_for_keyboard = null;
        }
    }

    pub fn get_cwd(self: *Manager, buffer: []u8) Error![]const u8 {
        if (self.current_process) |proc| {
            return buffer[0..try utils.memory_copy_error(buffer, proc.cwd.?)];
        } else {
            return Error.NoCurrentProcess;
        }
    }

    pub fn set_cwd(self: *Manager, dir: []const u8) georgios.ThreadingOrFsError!void {
        if (self.current_process) |proc| {
            try proc.set_cwd(dir);
        } else {
            return Error.NoCurrentProcess;
        }
    }
};

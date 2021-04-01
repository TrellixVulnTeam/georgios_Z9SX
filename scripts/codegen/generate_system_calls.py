#!/usr/bin/env python3

# Generates system call interface functions that can be called by programs
# based on the implementation file.

import sys
from pathlib import Path
import re


debug = False
impl_file = Path('kernel/platform/system_calls.zig')
interface_file = Path('programs/common/system_calls.zig')
this_file = Path(__file__)

int_num = None
syscall = None
syscalls = {}
syscall_regs = {}
imports = {}


def log(*args, prefix_message=None, **kwargs):
    f = kwargs[file] if 'file' in kwargs else sys.stdout
    prefix = lambda what: print(what, ": ", sep='', end='', file=f)
    prefix(sys.argv[0])
    if prefix_message is not None:
        prefix(prefix_message)
    print(*args, **kwargs)


def error(*args, **kwargs):
    log(*args, prefix_message='ERROR', **kwargs)
    sys.exit(1)


# See if we can skip generating the file
need_to_generate = False
if not interface_file.exists():
    log('Missing', str(interface_file), ' so need to generate')
    need_to_generate = True
else:
    interface_modified = interface_file.stat().st_mtime
    if this_file.stat().st_mtime >= interface_modified:
        log('Script changed so need to generate')
        need_to_generate = True
    elif impl_file.stat().st_mtime >= interface_modified:
        log(str(interface_file), 'was updated so need to generate')
        need_to_generate = True
if not need_to_generate:
    log('No need to generate', str(interface_file), 'so exiting')
    sys.exit(0);


# Parse the System Call Implementations =======================================

int_num_re = re.compile(r'\s*pub const interrupt_number: u8 = (\d+);$')
syscall_sig_re = re.compile(r'\s*// SYSCALL: (.*)')
syscall_num_re = re.compile(r'\s*(\d+) => ')
syscall_arg_re = re.compile(r'\s*const arg(\d+) = interrupt_stack.(\w+);')
import_re = re.compile(r'\s*// IMPORT: ([^ ]+) "([^" ]+)"')

with impl_file.open() as f:
    for i, line in enumerate(f):
        lineno = i + 1

        # System Call Interrupt Number
        m = int_num_re.match(line)
        if m:
            if syscall:
                error("Interrupt Number in syscall on line", lineno)
            if int_num is not None:
                error(("Found duplicate interrupt number {} on line {}, " +
                    "already found {}").format(m.group(1), lineno, int_num))
            int_num = m.group(1)
            continue

        # Registers Available for Return and Arguments
        m = syscall_arg_re.match(line)
        if m:
            if syscall:
                error("Syscall register in syscall on line", lineno)
            syscall_regs[int(m.group(1))] = m.group(2)
            continue

        # System Call Pseudo-Signature (see implementation file for details)
        m = syscall_sig_re.match(line)
        if m:
            if syscall:
                error("Syscall signature", repr(syscall),
                    "without a syscall number before line ", lineno)
            syscall = m.group(1)
            continue

        # Import Needed for the System Call
        m = import_re.match(line)
        if m:
            if syscall is None:
                error("Import without a syscall signature on line", lineno)
            imports[m.group(1)] = m.group(2)
            continue

        # System Call Number, Concludes System Call Info
        m = syscall_num_re.match(line)
        if m:
            if syscall is None:
                error("Syscall number without a syscall signature on line", lineno)
            syscalls[int(m.group(1))] = syscall
            syscall = None
            continue


# Print Debug Info ============================================================

if int_num is None:
    error("Didn't find interrupt number")
if debug:
    log('System Call Interrupt Number:', int_num)

if len(syscall_regs) == 0:
    error("No registers found!")

if debug:
    for num, reg in syscall_regs.items():
        log('Arg {} is reg %{}'.format(num, reg))

if len(syscalls) == 0:
    error("No system calls found!")

if debug:
    for pair in imports.items():
        log('Import', *pair)


# Write Interface File ========================================================

decompose_sig_re = re.compile(r'^(\w+)\((.*)\) ([^ :]+(?:: [\w\.]+)?)$')

with interface_file.open('w') as f:
    print('// Generated by scripts/codegen/generate_system_calls.py\n', file=f)

    for pair in imports.items():
        print('const {} = @import("{}");'.format(*pair), file=f)

    for num, sig in syscalls.items():
        m = decompose_sig_re.match(sig)
        if not m:
            error("Could not decompose signature of", repr(sig))
        name, args, return_decl = m.groups()
        args = args.split(', ')
        if len(args) == 1 and args[0] == '':
            args = []
        return_name = None
        if ':' in return_decl:
            return_name, return_type = [s.strip() for s in return_decl.split(':')]
        else:
            return_type = return_decl
            return_name = 'rv'
        if debug:
            log(num, '=>', repr(name), 'args', args,
                'return', repr(return_name), ':', repr(return_type))
        has_return = return_type != 'void'

        required_regs = len(args) + 1 if has_return else 0
        avail_regs = len(syscall_regs)
        if required_regs > avail_regs:
            error('System call {} requires {} registers, but the max is',
                repr(sig), required_regs, avail_regs)

        print('\npub inline fn {}({}) {} {{'.format(
            name,
            ', '.join([a[1:] if a.startswith('&') else a for a in args]),
            return_type), file=f)

        return_value = ''
        return_expr = ''
        if has_return:
            print('    var {}: {} = undefined;'.format(return_name, return_type), file=f)

        print((
            '    asm volatile ("int ${}" ::\n' +
            '        [syscall_number] "{{eax}}" (@as(u32, {})),'
            ).format(int_num, num), file=f)

        arg_num = 1
        def add_arg(arg_num , what):
            if ':' in what:
                what = what.split(':')[0]
            if what.startswith('&'):
                what = '@ptrToInt(' + what + ')'
            print('        [arg{}] "{{{}}}" ({}),'.format(
                arg_num, syscall_regs[arg_num], what), file=f)
            return arg_num + 1

        for arg in args:
            arg_num = add_arg(arg_num, arg)

        if has_return:
            arg_num = add_arg(arg_num, '&' + return_name)

        print(
            '        );', file=f)

        if has_return:
            print('    return {};'.format(return_name), file=f)
        print('}', file=f)
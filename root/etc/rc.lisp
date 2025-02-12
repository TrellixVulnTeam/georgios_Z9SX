#!/bin/shell.elf
(add_command motd (lambda () (progn
    (print
        "Welcome to Georgios!\n"
        "Try the \"hello\", \"ls\", \"shell\", or \"snake\" programs.\n"
        "Within the shell you can try the \"cd\", \"pwd\", \"sleep\",\n"
        "\"motd\", or \"reset\" commands.\n"
        "Type Ctrl-D or \"exit\" to exit the current shell.\n"
        "Exiting the last shell powers down the system.\n"
    )
)))

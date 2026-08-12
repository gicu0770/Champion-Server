define hook-run
    set logging file crash.log
    set logging on
end

define hook-stop
    echo \nProgram crashed. Saving backtrace...\n
    bt full
    info threads
    thread apply all bt full
    set logging off
end
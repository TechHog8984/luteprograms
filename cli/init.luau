--!strict

local libfs = require("@lute/fs")

export type CommandLineInterface = {
    -- config
    program_name: string,
    arg1_as_input_file: boolean,
    arg1_default: string?,
    arg2_as_output_file: boolean,
    arg2_default: string?,
    header: string?,
    usage: string?,

    -- private
    _options_message: string,
    _options: { [string]: () -> (...any) },
    _text_options: { [string]: (string) -> (...any) },

    -- config
    withArg1AsInputFile: (CommandLineInterface, boolean?) -> CommandLineInterface,
    withArg1Default: (CommandLineInterface, string?) -> CommandLineInterface,
    withArg2AsOutputFile: (CommandLineInterface, boolean?) -> CommandLineInterface,
    withArg2Default: (CommandLineInterface, string?) -> CommandLineInterface,
    withHeader: (CommandLineInterface, string) -> CommandLineInterface,
    withUsage: (CommandLineInterface, string) -> CommandLineInterface,
    withDefaultUsage: (CommandLineInterface) -> CommandLineInterface,
    withOption: (CommandLineInterface, string, string, (...any) -> (...any)) -> CommandLineInterface,
    withTextOption: (CommandLineInterface, string, string, (...any) -> (...any)) -> CommandLineInterface,

    -- api
    run: (CommandLineInterface) -> CommandLineInterfaceResult?,

    -- private
    printHelp: (CommandLineInterface) -> ()
}
export type CommandLineInterfaceResult = {
    input_file: string,
    output_file: string,

    input_contents: string,
    writeToOutput: ( string ) -> ()
}

local CommandLineInterface = {}
CommandLineInterface.__index = CommandLineInterface

function CommandLineInterface.new(program_name: string): CommandLineInterface
    local self = {
        program_name = program_name,
        arg1_as_input_file = false,
        arg1_default = nil,
        arg2_as_output_file = false,
        arg2_default = nil,
        header = nil,
        usage = nil,

        _options_message = "",
        _options = {},
        _text_options = {}
    }

    local cli: CommandLineInterface = setmetatable(self, CommandLineInterface) :: any
    return cli
end

function CommandLineInterface.withArg1AsInputFile(self: CommandLineInterface, value: boolean?): CommandLineInterface
    local final_value = true
    if type(value) == "boolean" then
        final_value = value
    end
    self.arg1_as_input_file = final_value

    return self
end
function CommandLineInterface.withArg1Default(self: CommandLineInterface, value: string?): CommandLineInterface
    self.arg1_default = value

    return self
end
function CommandLineInterface.withArg2AsOutputFile(self: CommandLineInterface, value: boolean?): CommandLineInterface
    local final_value = true
    if type(value) == "boolean" then
        final_value = value
    end
    self.arg2_as_output_file = final_value

    return self
end
function CommandLineInterface.withArg2Default(self: CommandLineInterface, value: string?): CommandLineInterface
    self.arg2_default = value

    return self
end
function CommandLineInterface.withHeader(self: CommandLineInterface, value: string): CommandLineInterface
    self.header = value

    return self
end
function CommandLineInterface.withUsage(self: CommandLineInterface, usage: string): CommandLineInterface
    self.usage = usage;

    return self
end
function CommandLineInterface.withDefaultUsage(self: CommandLineInterface): CommandLineInterface
    local usage = self.program_name

    if self.arg1_as_input_file then
        usage ..= " INPUTFILE"
    end
    if self.arg2_as_output_file then
        usage ..= " OUTPUTFILE"
    end

    usage ..= " [options]"

    self.usage = usage

    return self
end
function CommandLineInterface.withOption(self: CommandLineInterface, opt: string, description: string, func): CommandLineInterface
    self._options[opt] = func
    self._options_message ..= "  " .. opt .. "  -  " .. description .. '\n'

    return self
end
function CommandLineInterface.withTextOption(self: CommandLineInterface, opt: string, description: string, func): CommandLineInterface
    self._text_options[opt] = func
    self._options_message ..= "  " .. opt .. "=VALUE  -  " .. description .. '\n'

    return self
end

function CommandLineInterface.printHelp(self: CommandLineInterface)
    local header = assert(self.header, "please set a header!")

    print(header)
    if self.usage then
        print("  usage: " .. self.usage .. '\n')
    end
    print("  options:")
    print("  -h, --help  -  display help page")
    print(self._options_message)
end

function CommandLineInterface.run(self: CommandLineInterface, ...): CommandLineInterfaceResult?
    local args = {...}
    assert(table.remove(args, 1), "no arguments given!")

    local arg1 = args[1]
    local arg1_required = self.arg1_as_input_file and not self.arg1_default
    local arg1_missing = not arg1 or #arg1 < 1

    local arg1_processed = false

    if arg1 == "-h" or arg1 == "--help" then
        self:printHelp()
        return nil
    elseif arg1_missing then
        if arg1_required then
            error("missing required argument #1 INPUTFILE; try " .. self.program_name .. " -h for help")
        elseif self.arg1_default then
            arg1 = self.arg1_default
        else
            self:printHelp()
            return nil
        end
    else
        arg1_processed = true
    end

    local arg2 = args[2]
    local arg2_required = self.arg2_as_output_file and not self.arg2_default
    local arg2_missing = not arg2 or #arg2 < 1

    local arg2_processed = false

    if arg2_missing then
        if arg2_required then
            error("missing required argument #2 OUTPUTFILE")
        else
            arg2 = self.arg2_default or ""
        end
    else
        if arg2 == "-h" or arg2 == "--help" then
            self:printHelp()
            return nil
        end
        arg2_processed = true
    end

    local args_start = 2
    if not arg1_processed then
        args_start -= 1
    end
    if not arg2_processed then
        args_start -= 1
    end

    for _, arg in next, args, args_start do
        if arg == "-h" or arg == "--help" then
            self:printHelp()
            return nil
        end

        local found = false

        for option, func in self._options do
            if arg:match("^" .. option) then
                func()
                found = true
                break
            end
        end

        if found then
            continue
        end

        for option, func in self._text_options do
            local rightside = arg:match("^" .. option .. "=(.+)")
            if rightside then
                found = true
                func(rightside)
                break
            end
        end

        if found then
            continue
        end

        error("unhandled argument '" .. arg .. '\'')
    end


    assert(libfs.exists(arg1), "failed to open input file at '" .. arg1 .. '\'')

    local writeToOutput: ( string ) -> ()
    if arg2 == "" then
        writeToOutput = function(contents)
            print(contents)
        end
    else
        writeToOutput = function(contents)
            libfs.writestringtofile(arg2, contents)
        end
    end

    return {
        input_file = arg1,
        output_file = arg2,

        input_contents = libfs.readfiletostring(arg1),
        writeToOutput = writeToOutput
    }
end

return CommandLineInterface

local opts = require("true-zen.config").options
local mode_minimalist = require("lua.true-zen.services.modes.mode-minimalist.init")
local hi_group = require("true-zen.services.modes.mode-ataraxis.modules.hi_group")
local fillchar = require("true-zen.services.modes.mode-ataraxis.modules.fillchar")
local integrations_loader = require("true-zen.services.integrations.modules.integrations_loader")

local cmd = vim.cmd
local api = vim.api

local M = {}

local function get_axis_length(axis)
    if (axis == "x") then
        return x_axis
    end

    return y_axis
end

local function set_axis_length(axis, value)
    if (axis == "x") then
        x_axis = value
    else
        y_axis = value
    end
end

local function ensure_settings()
    if (api.nvim_eval("&splitbelow != 0 || &splitright != 0") == 1) then
        cmd("set splitbelow")
        cmd("set splitright")
    end
end

local function unlet_padding_vars()
    api.nvim_exec(
        [[
		if exists("g:tz_top_padding") | unlet g:tz_top_padding | endif
		if exists("g:tz_bottom_padding") | unlet g:tz_bottom_padding | endif
		if exists("g:tz_left_padding") | unlet g:tz_left_padding | endif
		if exists("g:tz_right_padding") | unlet g:tz_right_padding | endif
	]],
        false
    )
end

local function gen_buffer_specs(gen_command, command, extra)
    cmd(gen_command)
    cmd(command)
    cmd(
        "setlocal buftype=nofile bufhidden=wipe nomodifiable nobuflisted noswapfile nocursorline nocursorcolumn nonumber norelativenumber noruler noshowmode noshowcmd laststatus=0"
    )

    if (extra ~= nil) then
        cmd(extra)
    end
end

function window_has_neighbour(direction)
    local current_position = api.nvim_eval([[win_screenpos(winnr())]])
    local amount_windows = api.nvim_eval("winnr('$')")

    if (direction == "top") then
        return current_position[1] ~= 1
    elseif (direction == "bottom") then
        while (amount_windows > 0) do
            local position = api.nvim_eval([[win_screenpos(]] .. amount_windows .. [[)]])
            amount_windows = amount_windows - 1

            if ((current_position[1] + api.nvim_eval("winheight(0)")) < position[1]) then
                return true
            end
        end
        return false
    elseif (direction == "left") then
        return current_position[2] ~= 1
    elseif (direction == "right") then
        while (amount_windows > 0) do
            local position = api.nvim_eval([[win_screenpos(]] .. amount_windows .. [[)]])
            amount_windows = amount_windows - 1

            if ((current_position[2] + api.nvim_eval("winwidth(0)")) < position[2]) then
                return true
            end
        end
        return false
    end
end

local function layout(action)
    if (action == "generate") then
        ensure_settings()

        tz_top_padding = api.nvim_eval([[get(g:,"tz_top_padding", "NONE")]])
        tz_left_padding = api.nvim_eval([[get(g:,"tz_left_padding", "NONE")]])
        tz_right_padding = api.nvim_eval([[get(g:,"tz_right_padding", "NONE")]])
        tz_bottom_padding = api.nvim_eval([[get(g:, "tz_bottom_padding", "NONE")]])

        local left_padding_cmd = ""
        local right_padding_cmd = ""
        local top_padding_cmd = ""
        local bottom_padding_cmd = ""

        if (tz_left_padding ~= "NONE" or tz_right_padding ~= "NONE") then -- not equal to NONE
            if not (tz_left_padding == "NONE") then
                left_padding_cmd = "vertical resize " .. tz_left_padding .. ""
            else
                left_padding_cmd = "vertical resize " .. opts["ataraxis"]["left_padding"] .. ""
            end

            if not (tz_right_padding == "NONE") then
                right_padding_cmd = "vertical resize " .. tz_right_padding .. ""
            else
                right_padding_cmd = "vertical resize " .. opts["ataraxis"]["right_padding"] .. ""
            end
        else
            if (opts["ataraxis"]["ideal_writing_area_width"] > 0) then
                local window_width = api.nvim_eval("winwidth('%')")
                local ideal_writing_area_width = opts["ataraxis"]["ideal_writing_area_width"]

                if (ideal_writing_area_width == window_width) then
                    print(
                        "TrueZen: the ideal_writing_area_width setting cannot have the same size as your current window, it must be smaller than " ..
                            window_width
                    )
                else
                    local total_left_right_width = window_width - ideal_writing_area_width

                    if (total_left_right_width % 2 > 0) then
                        total_left_right_width = total_left_right_width + 1
                    end

                    local calculated_left_padding = total_left_right_width / 2
                    local calculated_right_padding = total_left_right_width / 2

                    left_padding_cmd = "vertical resize " .. calculated_left_padding .. ""
                    right_padding_cmd = "vertical resize " .. calculated_right_padding .. ""
                end
            else
                if (opts["ataraxis"]["just_do_it_for_me"] == true) then
                    -- calculate padding
                    local calculated_left_padding = api.nvim_eval("winwidth('%') / 4")
                    local calculated_right_padding = api.nvim_eval("winwidth('%') / 4")

                    left_padding_cmd = "vertical resize " .. calculated_left_padding .. ""
                    right_padding_cmd = "vertical resize " .. calculated_right_padding .. ""
                else
                    left_padding_cmd = "vertical resize " .. opts["ataraxis"]["left_padding"] .. ""
                    right_padding_cmd = "vertical resize " .. opts["ataraxis"]["right_padding"] .. ""
                end
            end
        end

        -- TODO: REPLACE THIS WITH PCALL TO AVOID NEGATIVE NUMBERS
        if not (tz_top_padding == "NONE") then
            top_padding_cmd = "resize " .. tz_top_padding .. ""
        else
            top_padding_cmd = "resize " .. opts["ataraxis"]["top_padding"] .. ""
        end

        if not (tz_bottom_padding == "NONE") then
            bottom_padding_cmd = "resize " .. tz_bottom_padding .. ""
        else
            bottom_padding_cmd = "resize " .. opts["ataraxis"]["bottom_padding"] .. ""
        end

        gen_buffer_specs("leftabove vnew", left_padding_cmd, "wincmd l") -- left buffer
        gen_buffer_specs("vnew", right_padding_cmd, "wincmd h") -- right buffer
        gen_buffer_specs("leftabove new", top_padding_cmd, "wincmd j") -- right buffer
        gen_buffer_specs("rightbelow new", bottom_padding_cmd, "wincmd k") -- right buffer
        -- final position: middle buffer

        if (get_axis_length("x") == nil) then
            set_axis_length("x", api.nvim_eval([[winwidth('%')]]))
            set_axis_length("y", api.nvim_eval([[winheight('%')]]))
        end
    elseif (action == "destroy") then
        if (window_has_neighbour("left")) then
            cmd("wincmd h")
            cmd("q")
        elseif (window_has_neighbour("right")) then
            cmd("wincmd l")
            cmd("q")
        elseif (window_has_neighbour("bottom")) then
            cmd("wincmd j")
            cmd("q")
        elseif (window_has_neighbour("top")) then
            cmd("wincmd k")
            cmd("q")
        end

        unlet_padding_vars()
    end
end

function M.on()
    if (api.nvim_eval("winnr('$')") > 1) then
        cmd("tabe %")
    end

    mode_minimalist.main("on")
    layout("generate")
    integrations_loader.load_integrations()
    fillchar.store_fillchars()
    fillchar.set_fillchars()

    if (opts["ataraxis"]["bg_configuration"] == true) then
        hi_group.store_hi_groups(opts["ataraxis"]["affected_higroups"])
        hi_group.set_hi_groups(opts["ataraxis"]["custome_bg"], opts["ataraxis"]["affected_higroups"])
    end
end

function M.off()
    mode_minimalist.main("off")
    layout("destroy")
    integrations_loader.unload_integrations()
    fillchar.restore_fillchars()

    if (opts["ataraxis"]["bg_configuration"] == true) then
        hi_group.restore_hi_groups()
    end
end

return M
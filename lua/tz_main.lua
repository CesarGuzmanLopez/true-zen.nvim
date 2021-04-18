

local bottom = require("services.bottom.init")
local top = require("services.top.init")
local left = require("services.left.init")
local minimalist_mode = require("services.mode-minimalist.init")

local resume = require("services.resume.init")
local cmd  = vim.cmd

-- function setup()
-- 	cmd("echo 'TrueZen was setup'")
-- 	-- require("config").set_options(custom_opts)
-- 	-- if (opts.true_false_commands == true) then
-- 	-- 	cmd("command! TZStatuslineT lua main(0, 1)")
-- 	-- 	cmd("command! TZStatuslineF lua main(0, 2)")
-- 	-- else
-- 	-- 	-- do nothing
-- 	-- end
-- end

-- 	if (opts.setup_message == true) then
-- 		cmd("echo 'TrueZen.nvim was set up...'")		-- working...
-- 	elseif (opts.setup_message == false) then
-- 		-- do nothing
-- 	else
-- 		-- do nothing
-- 	end
-- end

-- if (opts.true_false_commands == true) then
-- 	cmd("command! TZStatuslineT lua main(0, 1)")
-- 	cmd("command! TZStatuslineF lua main(0, 2)")
-- else
-- 	-- do nothing
-- end


function main(option, command_option)

	option = option or 0
	command_option = command_option or 0

	if (option == 0) then
		bottom.main(command_option)
	elseif (option == 1) then
		top.main(command_option)
	elseif (option == 2) then
		left.main(command_option)
	elseif (option == 3) then
		minimalist_mode.main(command_option)
	else
		-- command not recognized, raise an error
	end


	
end


-- export the functions
return {
	-- toggle_statusline = toggle_statusline, -- called with TZStatusline
	main = main
}

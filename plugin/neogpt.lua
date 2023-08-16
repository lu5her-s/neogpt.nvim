local openai = require("openai")

openai.api_key = "dEXMiu282AKk6PZO5JvJvpGXMjrqflV_YzTQ9yX1DdY"
openai.api_base = "https://chimeragpt.adventblocks.cc/api/v1"

local OpenAICompletionPlugin = {}

function OpenAICompletionPlugin.ai_command(args, range)
	local prompt = table.concat(args, " ")
	local completion = openai.Completion.create({
		model = "text-davinci-003",
		prompt = prompt,
		max_tokens = 20,
		temperature = 0.8,
		n = 1,
	})
	local completion_text = completion.choices[1].text:strip()
	vim.api.nvim_feedkeys("i" .. completion_text .. "<Esc>", "n", true)
end

function OpenAICompletionPlugin.setup()
	local nvim = pynvim.new(vim.env.NVIM_LISTEN_ADDRESS)
	nvim:register_function("ai_command", OpenAICompletionPlugin.ai_command)
	nvim:command("command! -nargs=* Ai lua OpenAICompletionPlugin.ai_command(<f-args>)")
	vim.o.completefunc = "v:lua.openai_complete"
end

function openai_complete(findstart, base)
	if findstart == 1 then
		local line = vim.api.nvim_get_current_line()
		local pos = vim.fn.col(".") - 1
		while pos > 0 and line:sub(pos, pos):match("[a-zA-Z0-9_]") do
			pos = pos - 1
		end
		return pos + 1
	else
		local prompt = vim.api.nvim_call_function("getline", { "." })
		local prefix = prompt:sub(findstart)
		local completion = openai.Completion.create({
			model = "text-davinci-003",
			prompt = prompt,
			max_tokens = 20,
			temperature = 0.8,
			n = 1,
			stop = "\n",
		})
		local choices = completion.choices[1].text:split("\n")
		local matches = {}
		for _, choice in ipairs(choices) do
			if choice:sub(1, #prefix) == prefix then
				table.insert(matches, choice)
			end
		end
		return matches
	end
end

OpenAICompletionPlugin.setup()

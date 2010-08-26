# Helper function which prompts for user input, if none selected the returned
# variable is set to the default.
# 'prompt'  -> user prompt
# 'var'     -> variable
# 'default' -> default value set if no user input is received.

def prompt_with_default(prompt, var, default)
  set(var) do
    Capistrano::CLI.ui.ask "#{prompt} [#{default}]: "
  end
  set var, default if eval("#{var.to_s}.empty?")
end

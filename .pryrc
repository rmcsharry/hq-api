Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
Pry.config.history.file = './tmp/.pry_history'
Pry.config.editor = 'vi'
Pry.config.pager = false

Pry.config.exception_handler = proc do |output, exception, pry_|
  pry_.run_command 'cat --ex'
  output.puts "\nBacktrace (first 10 lines):"
  output.puts exception.backtrace.first(10).map { |l| "  #{l}" }.join("\n")
end

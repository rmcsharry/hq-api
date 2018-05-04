# frozen_string_literal: true

Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'
Pry.commands.alias_command 'n', 'next'
Pry.config.history.file = './tmp/.pry_history'
Pry.config.editor = 'vi'
Pry.config.pager = false

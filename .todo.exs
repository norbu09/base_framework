%ExTodo.Config{
  supported_codetags: ["NOTE:", "TODO:", "FIXME:", "HACK:", "BUG:"],
  error_codetags: ["FIXME:", "BUG:"],
  skip_patterns: [~r/\.git/, ~r/_build/, ~r/deps/, ~r/cover/, ~r/docs/, ~r/\.todo\.exs/, ~r/node_modules/]
}

[
  import_deps: [:phoenix],
  plugins: [HeexFormatter],
  inputs: [
    # ...
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}"
  ]
]

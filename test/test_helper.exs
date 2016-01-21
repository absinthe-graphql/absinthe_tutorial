ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Blog.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Blog.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Blog.Repo)


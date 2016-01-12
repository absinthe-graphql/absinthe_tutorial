ExUnit.start

Mix.Task.run "ecto.create", ~w(-r AbsintheExample.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r AbsintheExample.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(AbsintheExample.Repo)


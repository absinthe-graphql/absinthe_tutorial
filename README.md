# AbsintheExample

Let's build a (basic) GraphQL Blog Server with Absinthe.

# Table of Contents

1. [Our First Query](#our-first-query)
2. [Using Our Query](#using-our-query)
3. [Query Arguments](#query-arguments)
4. [Mutations](#mutations)

## [Our First Query](#our-first-query)

The first thing our viewers want are a list of our blog posts, so that's what we're going to give them. Here's the query we want to support

```
{
  posts {
    title
    body
    posted_at
  }
}
```

To do this we're going to need a schema. Let's create some basic types for our schema, starting with a Post. GraphQL has several fundamental on top of which all of our types will be built. The [Object](http://hexdocs.pm/absinthe/Absinthe.Type.Object.html) type is the right one to use when representing a set of key value pairs.

```elixir
# web/schema/types.ex
defmodule AbsintheExample.Schema.Types do
  use Absinthe.Type.Definitions
  alias Absinthe.Type

  @absinthe :type
  def post do
    %Type.Object{
      fields: fields(
        title: [type: :string],
        body: [type: :string],
        posted_at: [type: :string]
      )
    }
  end
end
```

You'll notice we use the `fields()` function to define the fields on our Post object. This is just a convenience function that fills out a bit of GraphQL boilerplate for each of the fields we define. See [Absinthe.Type.Definitions](http://hexdocs.pm/absinthe/Absinthe.Type.Definitions.html#fields/1) for more information. That module also contains the documentation for several other convenience functions we will use in this example.

With our type completed we can now write a basic schema that will let us query a set of posts.

```elixir
# web/schema.ex
defmodule AbsintheExample.Schema do
  use Absinthe.Schema, type_modules: [AbsintheExample.Schema.Types]
  alias Absinthe.Type
  alias AbsintheExample.Resolver

  def query do
    %Type.Object{
      fields: fields(
        posts: [
          type: list_of(:post),
          resolve: &Resolver.Post.all/3
        ]
      )
    }
  end
end

# web/resolver/post.ex
defmodule AbsintheExample.Resolver.Post do
  def all(_, _, _) do
    {:ok, AbsintheExample.Repo.all(Post)}
  end
end
```

Queries are defined as fields inside the GraphQL object returned by our `query` function. We created a posts query that has a type `list_of(:post)` and is resolved by our `AbsintheExample.Resolver.Post.all` function. Later we'll get into what the arguments to resolver functions are, but don't worry about it for now. The resolver function can be anything you like that takes the requisite 3 arguments. By convention we recommend organizing your resolvers under `web/resolvers/`

These types are checked at compile time when you use `Absinthe.Plug` in your router. This means that if you misspell a type and do `list_of(:pots)` you'll be notified that the type you reference in your schema doesn't exist.

The last thing we need to do is configure our phoenix router to use our newly created schema.

```elixir
defmodule AbsintheExample.Web.Router do
  use Phoenix.Router

  forward "/", Absinthe.Plug,
    schema: AbsintheExample.Schema
end
```

That's it! We're running GraphQL.

## Resolution Overview

# TODO

## [Query Arguments](#query-arguments)

Our blog also needs users, and the ability to look up users by id. Here's the query we want to support:
```
{
  user(id: "1") {
    name
    email
  }
}
```

This query includes arguments, which are the key value pairs contained within the parenthesis. To support this, we'll create first create a user type, and then create a query in our schema that takes an id argument.

```elixir
# in web/schema/types

@absinthe :type
def user do
  %Type.Object{
    fields: fields(
      id: [type: :id],
      name: [type: :string],
      email: [type: :string]
      posts: [type: list_of(:posts)]
    )
  }
end

@absinthe :type
def post do
  %Type.Object{
    fields: fields(
      title: [type: :string],
      body: [type: :string],
      posted_at: [type: :string],
      author: [type: :user]
    )
  }
end

# in web/schema.ex
def query do
  %Type.Object{
    fields: fields(
      posts: [
        type: list_of(:post),
        resolve: &Resolver.Post.all/3
      ]
      user: [
        type: :user,
        args: args(
          id: [type: non_null(:id)]
        )
        resolve: &Resolver.User.find/3
      ]
    )
  }
end
```

In GraphQL you define your arguments ahead of time just like your return values. This powers a number of very helpful features. To see them at work, let's look at our resolver.

```elixir
# web/resolver/user.ex
defmodule AbsintheExample.Resolver.User do
  def find(_, %{id: id}, _) do
    case AbsintheExample.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end
end
```

The second argument to every resolve function contains the graphql arguments of the query / mutation. Our schema marks the id argument as `non_null`, so we can be certain we will receive it and just pattern match directly. If the id is left out of the query, Absinthe will return an informative error to the user, and the resolve function will not be called.

Note also that the id parameter is an atom, and not a binary like ordinary phoenix parameters. Absinthe knows what arguments will be used ahead of time, and will cull any extraneous arguments given to a query. This means that all arguments can be supplied to the resolve functions with atom keys.

Finally you'll see that we need to handle the possibility that the query, while valid from GraphQL's perspective, may still ask for a user that does not exist.


















Right now we have Instead of just representing this as a string, we can create a new [Scalar](http://hexdocs.pm/absinthe/Absinthe.Type.Scalar.html) type that will automatically handle serializing and unserializing the time with our preferred time handling library.

```elixir
# in web/schema/types.ex

@absinthe :type
def time do
  %Type.Scalar{
    description: "ISOz time",
    parse: &Timex.DateFormat.parse(&1, "{ISOz}"),
    serialize: &Timex.DateFormat.format!(&1, "{ISOz}")
  }
end
```

Our post should now look like

```elixir
@absinthe :type
def post do
  %Type.Object{
    fields: fields(
      title: [type: :string],
      body: [type: :string],
      posted_at: [type: :time]
    )
  }
end
```

By default, the atom name of the type (in this case `:time` or `:post`) is determined by the function used to define it. You can give it

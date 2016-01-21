# AbsintheExample

Let's build a GraphQL Blog Server with Absinthe.

## Our First Query

The first thing you're going to need is a schema. Let's create some basic types for our schema, starting with a Post. GraphQL has several fundamental on top of which all of our types will be built. The [Object](http://hexdocs.pm/absinthe/Absinthe.Type.Object.html) type is the right one to use when representing a set of key value pairs.

```elixir
# web/schema/types.ex
defmodule MyApp.Schema.Types do
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
defmodule MyApp.Schema do
  use Absinthe.Schema, type_modules: [MyApp.Schema.Types]
  alias Absinthe.Type

  def query do
    %Type.Object{
      fields: fields(
        posts: [
          type: list_of(:post),
          resolve: &MyApp.Resolver.Post.all/3
        ]
      )
    }
  end
end

# web/resolver/post.ex
defmodule MyApp.Resolver.Post do
  @posts [
    %{
      title: "Hello World",
      body: "This is my first blog post!",
      posted_at: "2016-01-19T16:07:37Z"
    },
  ] # Other Posts elided for brevity, see the real file.
  def all(_, _, _) do
    {:ok, @posts}
  end
end
```

Queries are defined as fields inside the GraphQL object returned by our `query` function. We created a posts query that has a type `list_of(:post)` and is resolved by our `MyApp.Resolver.Post.all` function. Later we'll get into what the arguments to resolver functions are, but don't worry about it for now.

The resolver function can be anything you like that takes the requisite 3 arguments. By convention we recommend organizing your resolvers under `web/resolvers/`

The last thing we need to do is configure our phoenix router to use our newly created schema.

```elixir
defmodule MyApp.Web.Router do
  use Phoenix.Router

  forward "/", Absinthe.Plug,
    schema: MyApp.Schema
end
```

That's it! You're running GraphQL.

## How resolution works

##

We really should include a `posted_at` field in our post. Instead of just representing this as a string, we can create a new [Scalar](http://hexdocs.pm/absinthe/Absinthe.Type.Scalar.html) type that will automatically handle serializing and unserializing the time with our preferred time handling library.

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

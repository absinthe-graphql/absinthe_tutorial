# Absinthe Example

Let's build a (basic) GraphQL Blog Server with Absinthe.

This tutorial does assume a (super) basic knowledge of what a GraphQL query is. It DOES NOT assume any knowledge of Absinthe. For a basic sense of how GraphQL works, see: http://facebook.github.io/graphql/#sec-Overview

## Table of Contents

1. [Our First Query](#our-first-query)
2. [Using Our Query](#using-our-query)
3. [Query Arguments](#query-arguments)
4. [Mutations](#mutations)
5. [Scalar Types](#scalar-types)
6. [Associations](#associations)

## Our First Query

The first thing our viewers want is a list of our blog posts, so that's what we're going to give them. Here's the query we want to support

```
{
  posts {
    title
    body
  }
}
```

To do this we're going to need a schema. Let's create some basic types for our schema, starting with a Post. GraphQL has several fundamental types on top of which all of our types will be built. The [Object](http://hexdocs.pm/absinthe/Absinthe.Type.Object.html) type is the right one to use when representing a set of key value pairs.

```elixir
# web/schema/types.ex
defmodule Blog.Schema.Types do
  use Absinthe.Type.Definitions
  alias Absinthe.Type

  @absinthe :type
  def post do
    %Type.Object{
      fields: fields(
        id: [type: :id],
        title: [type: :string],
        body: [type: :string]
      )
    }
  end
end
```

You'll notice we use the `fields()` function to define the fields on our Post object. This is just a convenience function that fills out a bit of GraphQL boilerplate for each of the fields we define. See [Absinthe.Type.Definitions](http://hexdocs.pm/absinthe/Absinthe.Type.Definitions.html#fields/1) for more information.

If you're curious what the type `:id` is used by the `:id` field, see the [GraphQL spec](https://facebook.github.io/graphql/#sec-ID). In our case it's our regular Ecto id, but always serialized as a string.

With our type completed we can now write a basic schema that will let us query a set of posts.

```elixir
# web/schema.ex
defmodule Blog.Schema do
  use Absinthe.Schema, type_modules: [Blog.Schema.Types]
  alias Absinthe.Type
  alias Blog.Resolver

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
defmodule Blog.Resolver.Post do
  def all(_obj, _args, _exe) do
    {:ok, Blog.Repo.all(Post)}
  end
end
```

Queries are defined as fields inside the GraphQL object returned by our `query` function. We created a posts query that has a type `list_of(:post)` and is resolved by our `Blog.Resolver.Post.all` function. Later we'll get into what the arguments to resolver functions are; don't worry about it for now. The resolver function can be anything you like that takes the requisite 3 arguments. By convention we recommend organizing your resolvers under `web/resolver/foo.ex`

By default, the atom name of the type (in this case `:post`) is determined by the name of the function which defines it. For more information on type definitions see [Absinthe.Type.Definitions](http://hexdocs.pm/absinthe/Absinthe.Type.Definitions.html).

The last thing we need to do is configure our phoenix router to use our newly created schema.

```elixir
defmodule Blog.Web.Router do
  use Phoenix.Router

  forward "/", Absinthe.Plug,
    schema: Blog.Schema
end
```

That's it! We're running GraphQL.

Using Absinthe.Plug in your router ensures that your schema is type checked at compile time. This means that if you misspell a type and do `list_of(:pots)` you'll be notified that the type you reference in your schema doesn't exist.

## Resolution Overview

- TODO

## Query Arguments

Our blog needs users, and the ability to look up users by id. Here's the query we want to support:
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
      email: [type: :string],
      posts: [type: :post]
    )
  }
end

@absinthe :type
def post do
  %Type.Object{
    fields: fields(
      title: [type: :string],
      body: [type: :string],
      author: [type: :user],
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
defmodule Blog.Resolver.User do
  def find(_obj, %{id: id}, _exe) do
    case Blog.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end
end
```

The second argument to every resolve function contains the GraphQL arguments of the query / mutation. Our schema marks the id argument as `non_null`, so we can be certain we will receive it and just pattern match directly. If the id is left out of the query, Absinthe will return an informative error to the user, and the resolve function will not be called.

Note also that the id parameter is an atom, and not a binary like ordinary phoenix parameters. Absinthe knows what arguments will be used ahead of time, and will cull any extraneous arguments given to a query. This means that all arguments can be supplied to the resolve functions with atom keys.

Finally you'll see that we need to handle the possibility that the query, while valid from GraphQL's perspective, may still ask for a user that does not exist.

## Mutations

A blog is no good without new content. We want to support a mutation to create a blog post:

```
mutation CreatePost {
  post(title: "Second", body: "We're off to a great start!") {
    id
  }
}
```

Fortunately for us we don't need to make any changes to our types file. We do however need a new function in our schema and resolver

```elixir
# in web/schema.ex
def mutation do
  %Type.Object{
    fields: fields(
      post: [
        type: :post,
        args: args(
          title: [type: non_null(:string)],
          body: [type: non_null(:string)],
          posted_at: [type: non_null(:string)],
        ),
        resolve: &Resolver.Post.create/3,
      ]
    )
  }
end

# in web/resolver/post.ex
def create(_obj, args, _exe) do
  %Post{}
  |> Post.changeset(args)
  |> Blog.Repo.insert
end
```

Simple enough!

## Scalar Types

It would be nice if our blog posts had a `posted_at` time. This would be something we could both send as part of our CreatePost mutation, and also retrieve in a query.

```
mutation CreatePost {
  post(title: "Second", body: "We're off to a great start!", postedAt: "2016-01-19T16:07:37Z") {
    id
    postedAt
  }
}
```

Here we have a small conundrum. While GraphQL strings have an obvious counterpart in elixir strings, time in Elixir is often represented by something like a Timex struct. We could handle this in our resolvers by manually serializing or deserializing the time data. Fortunately however GraphQL provides a better way via allowing us to build additional [Scalar](http://hexdocs.pm/absinthe/Absinthe.Type.Scalar.html) types.

Let's define our time type:
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

And our mutation in the schema should look like
```elixir
def mutation do
  %Type.Object{
    fields: fields(
      post: [
        type: :post,
        args: args(
          title: [type: non_null(:string)],
          body: [type: non_null(:string)],
          posted_at: [type: non_null(:time)],
        ),
        resolve: &Resolver.Post.create/3,
      ]
    )
  }
end
```

user(id: "1") {
  name
  posts {
    title
  }
}

When `posted_at` is passed as an argument, the parse function we defined in our `:time` type will be called and it will automatically arrive in our resolver as a `Timex.DateTime` struct! Similarly, when we return the `posted_at` field the `Timex.DateTime` struct will be serialized back to a string for easy JSON representation.

## Comments

What is a blog without insightful and constructive commentary? Let's give the people a voice!
```
mutation CreateComment {
  comment(post: {id: "1"})
  comment(comment: {id: "1"})
}

{
  user(id: "1") {
    comments {
      subject {
        id
        ... on Post {
          title
        }
        ... on Comment {
          body
          author {
            name
          }
        }
      }
    }
  }
}
```

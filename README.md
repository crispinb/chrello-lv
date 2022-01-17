# Chrello

## Purpose
This has 2 aims: 
1. for me to learn a bit more about Phoenix LiveView
1. as a proof-of-concept of what seems in principle a nice idea (to provide a Trelloish view of a Checkvist list)

## Scope


Given the difficulty (inherent to software it seems) of keeping ambitions in check, and my own lack of Phoenix LiveView skill, I'll start with these limits in mind: 
* Chrello will only handle public lists to avoid messing with auth. If this ever actually works reliably, adding auth will be our first bit of scope creep 
* The board <-> Checkvist list mapping will be the simplest possible: one list, one board. Each top level list item is a column. Each first level list item is a card. Behaviour for sub-items, and a bunch of other things, is undefined, making Chrello much like C. Chrello may be more colourful than C when I have Tailwind mastered though.

## FAQ
* *isn't "Chrello" a ridiculous name*?

    Yes but I am English so that's OK. 
    
* *mightn't the name be a trademark violation*?

    Probably but that's OK too because I'm also Australianish.

## Refs
* [Checkvist API docs](https://checkvist.com/auth/api)
* [Drag and Drop with Elixir - Phoenix LiveView and JavaScript Interop](https://www.headway.io/events/elixir-and-javascript-interop-with-phoenix-liveview-drag-and-drop)
  * [youtube](https://www.youtube.com/watch?v=U1EKT7WT_Ic)
* [Phoenix LiveView Trello clone example](https://github.com/noozo/live_view_trello_clone)
* https://sortablejs.github.io/Sortable/











----

# Phoenix

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

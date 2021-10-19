%{

  title: "The base framework",
  description: "I always had a base framework for little projects. It was a
    project in itself that i curated with the igredients that i thought make a
    good starting poit for PoCs that can grow into something that is usable
    without throwing away the PoC.",
  todo: " add git URL"
}
---

# The base framework

I always had a base framework for little projects. It was a
project in itself that i curated with the igredients that i thought make a
good starting poit for PoCs that can grow into something that is usable
without throwing away the PoC. Elixir is my goto language since years and
Phoenix is an amazing framework to get stuff done quickly. Here i'll outline
what i did to get going. If you want to see the code go to: GIT_URL_HERE

I normally try to get going without a traditional database for various reasons,
ability to distribute nodes around without needing to think about replication
is a big one. This time round i try to see how far i get with holding state
in ETS and backing it up to disk, then sync that to S3 and read it in on
application startup. Inspiration for that came from the next part in that
tutorial where we add a simple CMS to the stack. The other big one is the
ability to pull in production data and see how things look in development
without dumping and restoring DBs.

## Phoenix 1.6 + Tailwind

Tailwind is a nice CSS framework that i started using after years of using
Tachions. It follows the same ethos but provides a bit more and seems to have a
growing comunity so there are normally tutorials fo things i need or code
samles i can work off. This is also the case with getting this first step done,
Sergio wrote a fantastic tutorial that i followed to get tailwind into
Phoenix. Check it out here: https://sergiotapia.com/phoenix-160-liveview-esbuild-tailwind-jit-alpinejs-a-brief-tutorial

Skip the last step with the build script as we will do the build and deploy via
GitHub to fly.io.

## CI/CD and fly.io

I like to set everything up from the start to have a full deployment pipeline
so that i don't have to think about that later in the project. This time round
i want to try out fly.io and see how it could fit into a future hosting stategy
fo projects of mine. fly.io works well with elixi releases apparently and hooks
nicely into GitHub actions, something i wanted to try out anyway. I found a
really good tutorial by StarkNune here:
https://staknine.com/deploy-elixir-phoenix-fly-continuous-deployment/

Follow the tutorial from the point "Runtime configuration" onward and remember
that the `runtime.exs` is already present in Phoenix 1.6. I skipped all the `ecto`
steps as i try to get away without a traditional DB. Also, remember that our
asset compile step is called `MIX_ENV=prod mix assets.deploy` not like in this
tutorial calling `npm` directly.

To make fly.io work you need the `fyctl` which should be bundled for most
operating systems. Here is the relevant help page to get the cli:
https://fly.io/docs/getting-started/installing-flyctl/

After the "Deploy" step in the tutorial you should have a working site up and
running on fly.io with Tailwind and Alpine.js. The next step is getting the
GitHub actions working and that requires that `mix test` runs without errors.
So make sure you check that before moving on. Also, in case you have been
working with `git` locally so far, now is a good point to push everything up to
GitHub as the next step requires us to have everything set up there.

After this step you should have a working test and deploy setup that pushes
everything live on fly.io that is committed to the `main` branch and pushed to
GitHub. On fly.io check the "Activity" tab to see when the releases happened to
check everything is working.

## CMS

All my base frameworks always had a easy way to create content. Content is an
integral part of any platform and having a simple way to create and update
content is vital, especially in the proove of concept stage where i normally
experiment a lot with messaging, create content to see what converts well and
so on. Till now i normally worked with CouchDB but i found the fantastic work
of Alfred with his
[pardall_markdown](https://github.com/alfredbaudisch/pardall_markdown) project
and want to see if i can whip something up that uses Tailwind for styling and
is backed by S3 rather than the local file system so that i can easily play
with content locally and if satisfied sync the content to S3 to release it. If
i enable S3 versioning I even get content versioning for free.

This next step involves watching the video here:
https://www.youtube.com/watch?v=FdzqToe3dug and reading the source of the demo
project here: https://github.com/alfredbaudisch/pardall_markdown_phoenix_demo

I will have a few commits in my `base_framework` repo that outline the various
steps involved to get `pardall_markdown` working first.

- floki needs a braoder dependency definition

- get pardall dependencies and add a hook for pre-start things we need to do like creating directories locally


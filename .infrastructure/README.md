# Docs for infrastructure

## AWS 

For learning purposes, I initially tried to deploy my app to AWS.
Using AWS+[Terraform](https://www.terraform.io/use-cases/infrastructure-as-code) for IaaS/IaC sounds always reasonable but I had strong doubts that the price will stay low enough for using it on the long run.

After running the webside for ~1 week, the price already went up to 9 $,
Without a running DB instance, without real users (besides me) and without SSL support - even tho I assume the last point for free.

## Making decisions on switching to another provider

### TOP 3 players for hosting Elixir/Phoenix webapps

- [Fly.io](https://fly.io/docs/about/pricing/)

Fly.io seems to be the next bigger player talking about feature-richness. I would go for them but the price seems to be on the same magnitude like AWS. For now, let's check other players.

- [Heroku](https://www.heroku.com/pricing)

I came across Heroku once in the past but did not have a valid payment method they support. The cheapest plan is > 25$ per month which sounds reasonable but maybe it can be cheaper. Keep in mind that I try to improve my infrastructure for cost at the moment.

- [Gigalixir](https://www.gigalixir.com/pricing/)

Not only is Gigalixir specialized on hosting Elixir/Phoenix apps, it also grants a single instance, a DB, custom domains and SSL certificates for free. 

> **Elixir’s Platform as a Service** \
>The only platform that fully supports Elixir and Phoenix. Unlock the full power of Elixir/Phoenix. No infrastructure, maintenance, or operations.

The fact that [Dashbit](https://dashbit.co/blog/the-beauty-of-liveview) is a [direct customer](https://www.gigalixir.com/) also made me more confident that this is the next provider to try.

## Installation

`sudo pip3 install gigalixir --break-system-packages` \
Since I do not need python3 for anything else in this dev setup, I simply use the `--break-system-packages` here.

`gigalixir signup:google`

`gigalixir login:google`

Since I already have an production-ready app, I use \
`gigalixir create -n kkalb --region europe-west1 --cloud gcp`

Setting up remote repo with

`gigalixir git:remote kkalb`

I commit to my personal git all the changes with `*_build_pack` files and lastly, I also push to gigalixir repo with

`git push gigalixir`

I am scared that it just worked on the first try [kkalb.com](https://kkalb.gigalixirapp.com/gameoflife) \
has SSL activated, took ~2 min since running the push command and is free..


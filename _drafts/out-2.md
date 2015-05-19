---
layout: post
title: "Software Outsourcing, Survival Guide"
date: 2015-05-21
tags: outsourcing mgmt
description:
  Here is a few basic recommendations that will help you
  to not become a victim in a software outsourcing project
  and increase your chances of success.
keywords:
  - software outsourcing
  - software outsourcing best practices
  - software outsourcing pros and cons
  - software outsourcing companies
  - software outsourcing trends
  - software outsourcing definition
---

There are a few...

<!--more-->

**Control Source Code Repository**.
Make sure the source code repository is under your control. The best
way to do this is to create a private Github repository for
[$7/month](https://github.com/pricing). The repository will be visible and
accessible only by you and your outsourcing team. Moreover, make sure
the team has read-only access and can't change the code directly, but only
through pull requests. In Git it's possible to destroy the entire history
just by a single "forced" push to `master` branch. So, would be much better
if you will be the only person with write access. To make life simplier,
I would recommend to use [Rultor]({% pst 2014/jul/2014-07-24-rultor-automated-merging %}),
as a tool for merging that pull requests semi-automatically.

**Independent Technical Reviews**.
I wrote about them already in
[You Do Need Independent Technical Reviews!]({% pst 2014/dec/2014-12-18-independent-technical-reviews %})
post, a few months ago. The importance of such reviews is difficult
to overrate. In software outsourcing they are especially crucial.
Actually, this is the best and the only way of collecting
objective information about the software you're getting from the outsourcer.
Don't rely on reports, promises, guarantees and extensive documentation.
Instead, hire someone else, on an hourly basis, and ask that person
to review what your outsourcing partner is developing. Do such reviews
regularly and systematically. Don't be afraid to offend your programmers.
Honestly explain their concerns to them. If they are professionals, they
will understand and respect your business objectives.
You can also show them this article :)

**Automate Deployment**.
Ask your outsourcing team to automate the entire deployment pipeline and
keep it under your control. I would recommend to do this during the first
days of the project. This means that the product should be compiled, tested,
packaged, installed and deployed to production repository (or server/s) by
a single click. Some script should be created to automate this chain
of operations. That's what your outsourcing partner has to create for you.
Then, when development starts, every time a new change is made to the
repository that has to be deployed to production, the same script has
to be executed. What is important here is that you should know how
this script works and how to run it. You should be able to build and deploy your
product by yourself.

**Regularly Collect Metrics**.
Ask your outsourcing team to regularly collect metrics from the software
they create and send you somehow (by email, maybe). I would recommend to use
[Hits-of-Code]({% pst 2014/nov/2014-11-14-hits-of-code %}),
unit test coverage (or just total amount of unit tests), tickets opened/closed,
build duration. I'm talking here about process metrics. This is not what
you're already getting from NewRelic. These metrics will measure the
performance of the team, not of the product under development. I'm not saying
that you should manage the team by the metrics, but you have to keep
an eye on these numbers and their dynamics.

**Have Work For Hire Agreement**.
Make sure the contract you have with software outsourcing team
includes something like this: "Parties shall deem all deliverables created by
the developer as _works made for hire_ as is defined under the
[Copyright Law of the United States](http://www.copyright.gov/title17/)".
This is the shortest and the easiest definition of "whatever you create
for me is mine". Put this into the contract and the outsourcing company
won't be able to claim that the software they created belongs to them.
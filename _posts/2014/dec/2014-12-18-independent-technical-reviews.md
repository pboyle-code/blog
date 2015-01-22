---
layout: post
title: "You Do Need Independent Technical Reviews!"
date: 2014-12-18
tags: mgmt
categories: jcg
description:
  Regularly and systematically having your programmers' technical deliverables
  reviewed by an independent engineer will greatly improve your
  quality and team motivation.
keywords:
  - independent source code review
  - independent technical review
  - how to control programmers
  - how to monitor programmers
  - independent code review
  - independent review of source code
---

Do you have a team of brilliant and enthusiastic programmers? Of course! You've carefully
chosen them from a hundred candidates! Are they passionate about the product?
Absolutely! They use cutting-edge technologies, never sleep, and hardly eat or drink
anything except coffee! Do they believe in your business success? No doubts about it;
they live and breathe all those features, releases, continuous delivery, user
experience, etc. Are you sure they are developing the product correctly?
Well, yes, you're pretty sure; why wouldn't they? ...

Does this sound familiar? I can't count how many times I've heard
these stories told by startup founders. Most of them are in love with their teams ...
until that day when it's time to hire a new one. There could be many
possible reasons for such a fiasco, but one of them is a lack of
regular, systematic, and independent **technical reviews**.
Nothing demotivates a development team more than a lack of attention
to their deliverables. On the other hand, a regular
reconciliation of their results and your quality expectations is one
of the key factors that will guarantee technical success for your
startup. Below I summarize my experience with organizing such technical reviews.

<!--more-->

{% picture /images/2014/12/arizona-dream-car-shop.png 0 Arizona Dream (1992) by Emir Kusturica %}

An independent review is when you ask someone outside of your team
to look at your source code and other technical resources
and give you an objective opinion about them.
Every modern software team should also use internal code reviews, which is
is something else entirely. An internal review occurs when one programmer
shows his code to other peers on the team and asks their opinion. This usually
happens as a daily activity and has nothing to do with independent
reviews.

An independent review is performed by a programmer who knows nothing about your team.
He comes on board, checks out the code from your repository, spends a few hours
(or days) looking at it and trying to understand what it does. Then, he
tells you what is wrong and where. He explains how he would do it better,
where he would change it, and what he would do instead. Then, you pay him
and he leaves. You may never see him again, but his conclusions and suggestions
help you _check the reality_ of your code and evaluate how your team is really doing.

{% badge http://img.teamed.io/logo.svg 160 http://www.teamed.io %}

We, at [teamed.io](http://www.teamed.io), do independent reviews
with every project of ours, and this is a list of principles we use:

**Make Independent Reviews Systematic**.
This is the first and most important rule &mdash; organize
such technical reviews regularly. Moreover, inform your team about the schedule,
and let them be prepared for the reviews. Once a month is a good practice,
according to my experience. Depending on your source code size, a full
review should take from **two to eight hours**. Don't spend more than eight hours;
there is no point in going too deep into the code during independent reviews.

**Pay for Bugs Found**.
We [always]({% pst 2014/apr/2014-04-13-bugs-are-welcome %})
pay for bugs, not for the time spent finding them. We ask our reviewers
to look at the code and report as many bugs as we think we need. For each
bug, we pay 15 minutes for their time. In other words, we assume that
a good reviewer can find and report approximately four problems in one hour. For example,
a reviewer charges $150 per hour. We hire him and ask him to find and report the 20 most
criticial issues he can discover. Our estimate is that he should spend five hours on this
work. Thus, he will get $750 when we have 20 bugs in our tracking system
reported by him. If he finds fewer, he gets proportionally less money.
This payment schedule will help you focus your reviewer on the main
objective of the review process &mdash; finding and reporting issues. There
are no other goals. The only thing you're interested in is knowing what
the issues with your current technical solution are. That's what you're paying for.

**Hire the Best and Pay Well**.
My experience tells me that the position of an independent reviewer is a very
important one. He is not just a programmer but more of
[an architect]({% pst 2014/oct/2014-10-14-who-is-software-architect %})
who is capable of looking at the solution from a very high level of abstraction,
while at the same time paying a lot of attention to details; he should be very
good at designing similar systems; he should know how to report a bug
correctly and with enough detail; he should understand your business domain; etc.
Besides all that, he should be
well motivated to help you. You're not hiring him for full-time work but
rather just for a few-hour gig. My advice is to try to get
[the best guys]({% pst 2014/oct/2014-10-29-how-much-do-you-cost %}),
and pay them as much as they ask, usually over $100 per hour. Don't negotiate,
just pay. It's just a few hundred dollars for you, but the effect of their
contribution will be huge.

**Ask For and Expect Criticism**.
It is a very common mistake to ask a reviewer, "Do you like our code?"
Don't expect him to tell you how great your code is. This is not what you're
paying him for! You already have a full team of programmers for cheering you up; they can tell
you a lot about the code they are creating and how awesome it is. You don't want
to hear this again from the reviewer. Instead, you want to know what
is wrong and needs to be fixed. So your questions should sound like,
"What problems do you think we should fix first?" Some reviewers will try
to please you with positive comments, but ignore that flattery and bring them back
to the main goal &mdash; bugs. The payment schedule explained above should help.

**Regularly Change Reviewers**.
Try not to use the same reviewer more than once on the same project (I mean the
same code base). I believe the reason here is obvious, but let me re-iterate:
You don't need your reviewer to be nice to you and tell you how
great your code is. You want him to be objective and focused on problems,
not on bright sides. If you hire the same person again and again,
psychologically you make him engaged to the source code. He's seen it once;
now he has to see it again. He already told you about some problem, and
now he has to repeat it again. He won't feel comfortable doing it. Instead,
he will start feeling like a member of the team and will feel
responsible for the source code and its mistakes. He, as any other
team member, will start hiding issues instead of revealing them. Thus,
for every independent technical review, get a new person.

**Be Polite and Honest With Your Team**.
Independent reviews can be rather offensive to your programmers. They may
think that you don't trust them. They may feel that you don't respect them
as technical specialists. They may even decide that you're getting ready
to fire them all and are currently looking for new people. This is a very
possible and very destructive side effect of an independent review. How do you avoid it?
I can't give you universal advice, but the best suggestion I can give is this:
be honest with them. Tell them that the quality of the product is critical for you
and your business. Explain to them that the business is paying them for their
work and that in order to keep paychecks coming, you have to stress quality
control &mdash; regularly, objectively, independently, and honestly. In the end,
if you manage to organize reviews as this article explains, the team will
be very thankful to you. They will gain a lot of new ideas and thoughts from every
review and will ask you to repeat them regularly.

**Review From Day One**.
Don't wait until the end of the project! I've seen this mistake many times.
Very often startup founders think that until the product is done and ready
for the market, they shouldn't distract their team. They think they should
let the team work toward project milestones and take care of quality
later, "when we have a million visitors per day". This day will never come
if you let your team run without control! Start conducting independent reviews
from the moment your Git repository has its first file. Until the repository
is big enough, you may only spend $300 once a month to receive an objective,
independent opinion about its quality. Will this ruin your budget?

**Prohibit Discussions, and Ask for Formal Reporting**.
Don't let your reviewers talk to the team. If you do, the entire
idea of a review being independent falls apart. If a reviewer is able
to ask informal questions and discuss your system design with your programmers,
their answers will satisfy him, and he will move on. But you,
the owner of the business, will stay exactly where you were before the review.
The point of the review is not to make the reviewer happy. It is exactly the
opposite. You want to make him confused! If he is confused, your
design is wrong and he feels the need to report a bug. The source code
should speak for itself, and it should be easy enough for a stranger (the
reviewer) to understand how it works. If this is not the case, there is
something wrong that should be fixed.

**Treat Any Question as a Bug**.
Don't expect a review to produce any bugs in functionality, like
"I click this button and the system crashes". This will happen rarely, if ever.
Your team is very good at discovering these issues and fixing them. Independent
reviews are not about that kind of bugs. The main goal of an independent review is to
discover bugs in the architecture and design. Your product may work, but its
architecture may have serious design flaws that won't allow you, for example,
to handle exponential growth in web traffic. An independent reviewer will help you
find those flaws and address them sooner than later. In order to get bugs
of that kind from the reviewer, you should encourage him to report
_anything_ he doesn't like &mdash; unmotivated use of a technology,
lack of documentation, unclear purpose of a file, absence of
a unit test, etc. Remember, the reviewer is not a member of your team and has his
own ideas about the technologies you're using and software development in general.
You're interested in matching his vision with your team's. Then, you're
interested in fixing all critical mismatches.

**Review Everything, Not Just Source Code**.
Let your reviewer look at all technical resources you have, not just
source code files (`.java`, `.rb`, `.php`, etc.) Give him access to the
database schema, continuous integration panel, build environment,
issue tracking system, plans and schedules, work agendas, uptime reports,
deployment pipeline, production logs,
customer bug reports, statistics, etc. Everything that
could help him understand how your system works, and more importantly,
where and how it breaks, is very useful. Don't limit the reviewer to the
source code only &mdash; this is simply not enough! Let him see the big
picture, and you will get a much more detailed and professional report.

**Track How Inconsistencies Are Resolved**.
Once you get a report from the reviewer, make sure that the most important
issues immediately get into your team's backlog. Then, make sure they are
addressed and closed. That doesn't mean you should fix them all and listen
to everything said by the reviewer. Definitely not! Your
[architect]({% pst 2014/oct/2014-10-14-who-is-software-architect %})
runs the show, not the reviewer. Your architect should decide what is right
and what is wrong in the technical implementation of the product. But it's
important to make him resolve all concerns raised by the reviewer. Very often
you will get answers like these from him: "We don't care about it now", "we won't
fix it until the next release", or "he is wrong; we're doing it better". These
answers are perfectly valid, but they have to be given
(reviewers are people and they also make mistakes). The answers will help
you, the founder, understand what your team is doing and how well they
understand their business.

<hr/>

If you can offer more suggestions, based on your experience, please post
them below in the comments, and I'll add them to the list. I'm still
thinking that I may have forgotten something important :)
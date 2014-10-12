---
layout: post
title: "Fluent Java HTTP Client"
date: 2014-04-11
tags: jcabi http java
categories: best
description:
  I created a simple fluent Java HTTP client to make things
  easier with HTTP interactions; the article explains its benefits
  comparing with native Java and Apache HttpClient
keywords:
  - alternative to apache http client
  - best java http client library
  - http client java
  - httpclient fluent
  - httpclient java
  - java http client
  - java httpclient
  - sample http client in java
  - simple http client in java
discussions:
  reddit: http://www.reddit.com/r/java/comments/22rfdc/fluent_java_http_client/
---

{% badge http://img.jcabi.com/logo-square.svg 64 http://http.jcabi.com %}

In the world of Java, there are plenty of HTTP clients from which to choose.
Nevertheless, I decided to create a new one because none of the other clients
satisfied fully all of my requirements. Maybe, I'm too demanding. Still, this is
how my [jcabi-http](http://http.jcabi.com/) client interacts when you make an
HTTP request and expect a successful HTML page in return:

{% highlight java linenos=table %}
String html = new JdkRequest("https://www.google.com")
  .uri().path("/users").queryParam("id", 333).back()
  .method(Request.GET)
  .header("Accept", "text/html")
  .fetch()
  .as(RestResponse.class)
  .assertStatus(HttpURLConnection.HTTP_OK)
  .body();
{% endhighlight %}

I designed this new client with the following requirements in mind:

<!--more-->

## Simplicity

For me, this was the most important requirement. The client must be simple and
easy to use. In most cases, I need only to make an HTTP request and parse the
JSON response to return a value. For example, this is how I use the new client
to return a current EUR rate:

{% highlight java linenos=table %}
String rate = new JdkRequest("http://www.getexchangerates.com/api/latest.json")
  .header("Accept", "application/json")
  .fetch()
  .as(JsonResponse.class)
  .json().readArray().getJsonObject(0)
  .getString("EUR");
{% endhighlight %}

I assume that the above is easy to understand and maintain.

## Fluent Interface

The new client has to be fluent, which means that the entire server interaction
fits into one Java statement. Why is this important? I think that [fluent
interface](http://martinfowler.com/bliki/FluentInterface.html) is the most
compact and expressive way to perform multiple imperative calls. To my
knowledge, none of the existing libraries enable this type of fluency.

## Testable and Extendable

I'm a big fan of interfaces, mostly because they make your designs both cleaner
and highly extendable at the same time. In [jcabi-http](http://http.jcabi.com/),
there are five interfaces extended by 20 classes.

[`Request`](http://http.jcabi.com/apidocs-1.3/com/jcabi/http/Request.html)
is an interface, as well as
[`Response`](http://http.jcabi.com/apidocs-1.3/com/jcabi/http/Response.html),
[`RequestURI`](http://http.jcabi.com/apidocs-1.3/com/jcabi/http/RequestURI.html),
and
[`RequestBody`](http://http.jcabi.com/apidocs-1.3/com/jcabi/http/RequestBody.html)
exposed by it.

Use of interfaces makes the library highly extendable. For example, we have
[`JdkRequest`](http://http.jcabi.com/apidocs-1.3/com/jcabi/http/request/JdkRequest.html)
and
[`ApacheRequest`](http://http.jcabi.com/apidocs-1.3/com/jcabi/http/request/ApacheRequest.html),
which make actual HTTP calls to the server using two completely different technologies: (JDK `HttpURLConnection` and Apache Http Client, respectively). In the future, it will be possible to introduce new implementations without breaking existing code.

Say, for instance, I want to fetch a page and then do something with it. These two calls perform the task differently, but the end results are the same:

{% highlight java %}
String uri = "http://www.google.com";
Response page;
page = new JdkRequest(uri).fetch();
page = new ApacheRequest(uri).fetch();
{% endhighlight %}

## XML and JSON Out-of-the-Box

There are two common standards that I wanted the library to support right out of
the box. In most cases, the response retrieved from a server is in either XML or
JSON format. It has always been a hassle, and extra work, for me to parse the
output to take care of formatting issues.

[jcabi-http](http://http.jcabi.com/) client supports them both out of the box,
and it's possible to add more formats in the future as needed. For example, you
can fetch XML and retrieve a string value from its element:

{% highlight java %}
String name = new JdkRequest("http://my-api.example.com")
  .header("Accept", "text/xml")
  .fetch()
  .as(XmlResponse.class)
  .xml().xpath("/root/name/text()").get(0);
{% endhighlight %}

Basically, the response produced by `fetch()` is decorated by `XmlResponse`. This then exposes the `xml()` method that returns an instance of the [`XML`](http://xml.jcabi.com/apidocs-0.7.7/com/jcabi/xml/XML.html) interface.

The same can be done with JSON through the Java JSON API
([JSR-353](https://jcp.org/en/jsr/detail?id=353)).

None of the libraries that I'm aware of or worked with offer this feature.

## Immutable

The last requirement, but certainly not the least important, is that I need all interfaces of the
library to be annotated with [`@Immutable`](http://http://aspects.jcabi.com/annotation-immutable.html).
This is important because I need to be able to encapsulate an instance of `Request` in other immutable classes.

ps. A short summary of this article was published at
[JavaLobby](http://java.dzone.com/articles/jcabi-http-fluent-java-http)
---
layout: post
title: "Java Web App Architecture In Takes Framework"
date: 2015-02-10
tags: java
description:
  Takes is a pure object-oriented and immutable
  Java web framework that turns the design and development
  of web applications into a pleasant and fun process.
keywords:
  - java web framework
  - java web development framework
  - best java web framework
  - object-oriented java web framework
  - java web app framework
---

I used to utilize Servlets, JSP, JAX-RS, Spring Framework, Play Framework,
JSF with Facelets, and a bit of Spark Framework. All of these solutions,
in my humble opinion, are very far from being object-oriented and elegant.
They all are full of static methods, untestable data structures, and
dirty hacks. So about a month ago, I decided to create my own Java web
framework. I put a few basic principles into its foundation: 1) No NULLs,
2) no public static methods, 3) no mutable classes, and 4) no class casting, reflection,
and `instanceof` operators. These four basic principles should guarantee
clean code and transparent architecture. That's how the
[Takes](http://www.takes.org) framework was born.
Let's see what was created and how it works.

<!--more-->

## Java Web Architecture in a Nutshell

This is how I understand a web application architecture and its
components, in simple terms.

First, to create a web server, we should create
a new [network socket](http://en.wikipedia.org/wiki/Network_socket),
that accepts connections on a certain [TCP port](http://en.wikipedia.org/wiki/Port_%28computer_networking%29).
Usually it is 80, but I'm going to use 8080 for testing purposes.
This is done in Java with the [`ServerSocket`](http://docs.oracle.com/javase/7/docs/api/java/net/ServerSocket.html) class:

{% highlight java %}
import java.net.ServerSocket;
public class Foo {
  public static void main(final String... args) throws Exception {
    final ServerSocket server = new ServerSocket(8080);
    while (true);
  }
}
{% endhighlight %}

That's enough to start a web server. Now, the socket is ready and listening
on port 8080. When someone opens `http://localhost:8080` in their browser,
the connection will be established and the browser will spin its waiting
wheel forever. Compile this snippet and try. We just built a simple web
server without the use of any frameworks. We're not doing anything with
incoming connections yet, but we're not rejecting them either. All of them
are being lined up inside that `server` object. It's being done in a background
thread; that's why we need to put that `while(true)` in afterward. Without this endless pause,
the app will finish its execution immediately and the server socket will
shut down.

The next step is to accept the incoming connections. In Java, that's done through
a blocking call to the `accept()` method:

{% highlight java %}
final Socket socket = server.accept();
{% endhighlight %}

The method is blocking its thread and waiting until a new connection arrives. As
soon as that happens, it returns an instance of `Socket`. In order to accept
the next connection, we should call `accept()` again. So basically, our
web server should work like this:

{% highlight java %}
public class Foo {
  public static void main(final String... args) throws Exception {
    final ServerSocket server = new ServerSocket(8080);
    while (true) {
      final Socket socket = server.accept();
      // 1. Read HTTP request from the socket
      // 2. Prepare an HTTP response
      // 3. Send HTTP response to the socket
      // 4. Close the socket
    }
  }
}
{% endhighlight %}

It's an endless cycle that accepts a new connection, understands it,
creates a response, returns the response, and accepts a new connection again.
HTTP protocol is stateless, which means the server should not
remember what happened in any previous connection. All it cares about is
the incoming HTTP request in this particular connection.

The HTTP request is coming from the input stream of the socket and looks like
a multi-line block of text. This is what you would see if you read
an input stream of the socket:

{% highlight java %}
final BufferedReader reader = new BufferedReader(
  new InputStreamReader(socket.getInputStream())
);
while (true) {
  final String line = reader.readLine();
  if (line.isEmpty()) {
    break;
  }
  System.out.println(line);
}
{% endhighlight %}

You will see something like this:

{% highlight text %}
GET / HTTP/1.1
Host: localhost:8080
Connection: keep-alive
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36
Accept-Encoding: gzip, deflate, sdch
Accept-Language: en-US,en;q=0.8,ru;q=0.6,uk;q=0.4
{% endhighlight %}

The client (the Google Chrome browser, for example) passes this text into the
connection established. It connects to port 8080 at `localhost`, and as soon
as the connection is ready, it immediately sends this text into it, then waits
for a response.

Our job is to create an HTTP response using the information we get in the
request. If our server is very primitive, we can basically ignore all the
information in the request and just return "Hello, world!" to all requests
(I'm using
[`IOUtils`](https://commons.apache.org/proper/commons-io/apidocs/org/apache/commons/io/IOUtils.html)
for simplicity):

{% highlight java %}
import java.net.Socket;
import java.net.ServerSocket;
import org.apache.commons.io.IOUtils;
public class Foo {
  public static void main(final String... args) throws Exception {
    final ServerSocket server = new ServerSocket(8080);
    while (true) {
      try (final Socket socket = server.accept()) {
        IOUtils.copy(
          IOUtils.toInputStream("HTTP/1.1 200 OK\r\n\r\nHello, world!"),
          socket.getOutputStream()
        );
      }
    }
  }
}
{% endhighlight %}

That's it. The server is ready. Try to compile and run it. Point your browser
to http://localhost:8080, and you will see `Hello, world!`:

{% highlight bash %}
$ javac -cp commons-io.jar Foo.java
$ java -cp commons-io.jar:. Foo &
$ curl http://localhost:8080 -v
* Rebuilt URL to: http://localhost:8080/
* Connected to localhost (::1) port 8080 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.37.1
> Host: localhost:8080
> Accept: */*
>
< HTTP/1.1 200 OK
* no chunk, no close, no size. Assume close to signal end
<
* Closing connection 0
Hello, world!
{% endhighlight %}

That's all you need to build a web server. Now let's discuss how to make
it object-oriented and composable. Let's try to see how the [Takes](http://www.takes.org)
framework was built.

## Routing/Dispatching

The most important step is to decide who is responsible for building
an HTTP response. Each HTTP request has 1) a query, 2) a method, and 3) a number
of headers. Using these three parameters, we need to instantiate an object
that will build a response for us. This process, in most web frameworks,
is called request dispatching or routing. Here is how we do it in Takes:

{% highlight java %}
final Take take = takes.route(request);
final Response response = take.act();
{% endhighlight %}

There are basically two steps. The first one is creating an instance of
[`Take`](http://www.takes.org/apidocs-0.9/org/takes/Take.html)
from `takes`, and the second one is creating an instance of `Response` from `take`.
Why is it done this way? Mostly in order to separate responsibilities. An
instance of [`Takes`](http://www.takes.org/apidocs-0.9/org/takes/Takes.html)
is responsible for dispatching a request and instantiating
the right `Take`, and an instance of `Take` is responsible for creating a response.

To create a simple application in Takes, you should create two classes. First,
an implementation of `Takes`:

{% highlight java %}
import org.takes.Request;
import org.takes.Take;
import org.takes.Takes;
public final class TsFoo implements Takes {
  @Override
  public Take route(final Request request) {
    return new TkFoo();
  }
}
{% endhighlight %}

We're using these `Ts` and `Tk` prefixes for
`Takes` and `Take`, respectively.
The second class you should create is an implementation of `Take`:

{% highlight java %}
import org.takes.Take;
import org.takes.Response;
import org.takes.rs.RsText;
public final class TkFoo implements Take {
  @Override
  public Response act() {
    return new RsText("Hello, world!");
  }
}
{% endhighlight %}

And now it's time to start a server:

{% highlight java %}
import org.takes.http.Exit;
import org.takes.http.FtBasic;
public class Foo {
  public static void main(final String... args) throws Exception {
    new FtBasic(new TsFoo(), 8080).start(Exit.NEVER);
  }
}
{% endhighlight %}

This [`FtBasic`](http://www.takes.org/apidocs-0.9/org/takes/http/FtBasic.html)
class does the exact same socket manipulations explained
above. It starts a server socket on port 8080 and dispatches all incoming
connections through an instance of `TsFoo` that we are giving to its constructor.
It does this dispatching in an endless cycle, checking every second whether
it's time to stop with an instance of
[`Exit`](http://www.takes.org/apidocs-0.9/org/takes/http/Exit.html).
Obviously, `Exit.NEVER` always responds with, "Don't stop, please".

## HTTP Request

Now let's see what's inside the HTTP request arriving at `TsFoo` and what
we can get out of it. This is how the
[`Request`](http://www.takes.org/apidocs-0.9/org/takes/Request.html)
interface is defined in [Takes](http://www.takes.org):

{% highlight java %}
public interface Request {
  Iterable<String> head() throws IOException;
  InputStream body() throws IOException;
}
{% endhighlight %}

The request is divided into two parts: the head and the body. The head
contains all lines that go before the empty line that starts
a body, according to HTTP specification in
[RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html). There are many useful
decorators for `Request` in the framework. For example, `RqMethod` will
help you get the method name from the first line of the header:

{% highlight java %}
final String method = new RqMethod(request).method();
{% endhighlight %}

`RqHref` will help extract the query part and parse it. For example,
this is the request:

{% highlight java %}
GET /user?id=123 HTTP/1.1
Host: www.example.com
{% endhighlight %}

This code will extract that `123`:

{% highlight java %}
final int id = Integer.parseInt(
  new RqHref(request).href().param("id").get(0)
);
{% endhighlight %}

`RqPrint` can get the entire request or its body printed as a `String`:

{% highlight java %}
final String body = new RqPrint(request).printBody();
{% endhighlight %}

The idea here is to keep the `Request` interface simple and provide
this request parsing functionality to its decorators. This approach helps the
framework keep classes small and cohesive. Each decorator is very
small and solid, doing exactly one thing. All of these decorators
are in the [`org.takes.rq`](http://www.takes.org/apidocs-0.9/org/takes/rq/index.html) package.
As you already probably understand, the `Rq` prefix stands for `Request`.

## First Real Web App

Let's create our first real web application, which will do something
useful. I would recommend starting with an `Entry` class, which is
required by Java to start an app from the command line:

{% highlight java %}
import org.takes.http.Exit;
import org.takes.http.FtCLI;
public final class Entry {
  public static void main(final String... args) throws Exception {
    new FtCLI(new TsApp(), args).start(Exit.NEVER);
  }
}
{% endhighlight %}

This class contains just a single `main()` static method that will be
called by JVM when the app starts from the command line. As you see, it
instantiates [`FtCLI`](http://www.takes.org/apidocs-0.9/org/takes/http/FtCLI.html),
giving it an instance of class `TsApp` and command
line arguments. We'll create the `TsApp` class in a second. `FtCLI`
(translates to "front-end with command line interface") makes an instance
of the same `FtBasic`, wrapping it into a few useful decorators and configuring
it according to command line arguments. For example, `--port=8080` will
be converted into a `8080` port number and passed as a second argument of
the `FtBasic` constructor.

The web application itself is called `TsApp` and extends `TsWrap`:

{% highlight java %}
import org.takes.Take;
import org.takes.Takes;
import org.takes.facets.fork.FkRegex;
import org.takes.facets.fork.TsFork;
import org.takes.ts.TsWrap;
import org.takes.ts.TsClasspath;
final class TsApp extends TsWrap {
  TsApp() {
    super(TsApp.make());
  }
  private static Takes make() {
    return new TsFork(
      new FkRegex("/robots.txt", ""),
      new FkRegex("/css/.*", new TsClasspath()),
      new FkRegex("/", new TkIndex())
    );
  }
}
{% endhighlight %}

We'll discuss this `TsFork` class in a minute.

If you're using Maven, this is the `pom.xml` you should start with:

{% highlight java %}
<?xml version="1.0"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>foo</groupId>
  <artifactId>foo</artifactId>
  <version>1.0-SNAPSHOT</version>
  <dependencies>
    <dependency>
      <groupId>org.takes</groupId>
      <artifactId>takes</artifactId>
      <version>0.9</version> <!-- check the latest in Maven Central -->
    </dependency>
  </dependencies>
  <build>
    <finalName>foo</finalName>
    <plugins>
      <plugin>
        <artifactId>maven-dependency-plugin</artifactId>
        <executions>
          <execution>
            <goals>
              <goal>copy-dependencies</goal>
            </goals>
            <configuration>
              <outputDirectory>${project.build.directory}/deps</outputDirectory>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
{% endhighlight %}

Running `mvn clean package` should build a `foo.jar` file in `target` directory
and a collection of all JAR dependencies in `target/deps`. Now you
can run the app from the command line:

{% highlight bash %}
$ mvn clean package
$ java -Dfile.encoding=UTF-8 -cp ./target/foo.jar:./target/deps/* foo.Entry --port=8080
{% endhighlight %}

The application is ready, and you can deploy it to, say, Heroku. Just
create a `Procfile` file in the root of the repository and push the repo
to Heroku. This is what `Procfile` should look like:

{% highlight text %}
web: java -Dfile.encoding=UTF-8 -cp target/foo.jar:target/deps/* foo.Entry --port=${PORT}
{% endhighlight %}

## TsFork

This [`TsFork`](http://www.takes.org/apidocs-0.9/org/takes/facets/fork/TsFork.html)
class seems to be one of the core elements of the framework. It
helps route an incoming HTTP request to the right _take_. Its logic is very
simple, and there are just a few lines of code inside it. It encapsulates
a collection of "forks", which are instances of the
[`Fork<Take>`](http://www.takes.org/apidocs-0.9/org/takes/facets/fork/Fork.html) interface:

{% highlight java %}
public interface Fork<T> {
  Iterator<T> route(Request req) throws IOException;
}
{% endhighlight %}

Its only `route()` method either returns an empty iterator or an iterator
with a single `Take`. `TsFork` goes through all forks, calling their
`route()` methods until one of them returns a _take_. Once that happens,
`TsFork` returns this _take_ to the caller, which is
[`FtBasic`](http://www.takes.org/apidocs-0.9/org/takes/http/FtBasic.html).

Let's create a simple fork ourselves now. For example, we want to show
the status of the application when the `/status` URL is requested. Here is
the code:

{% highlight java %}
final class TsApp extends TsWrap {
  private static Takes make() {
    return new TsFork(
      new Fork.AtTake() {
        @Override
        public Iterator<Take> route(Request req) {
          final Collection<Take> takes = new ArrayList<>(1);
          if (new RqHref(req).href().path().equals("/status")) {
            takes.add(new TkStatus());
          }
          return takes.iterator();
        }
      }
    );
  }
}
{% endhighlight %}

I believe the logic here is clear. We either return an empty iterator
or an iterator with an instance of `TkStatus` inside. If an empty
iterator is returned, `TsFork` will try to find another fork in the
collection that actually gets an instance of `Take` in order to produce a `Response`.
By the way, if nothing is found and all forks return empty iterators,
`TsFork` will throw a "Page not found" exception.

This exact logic is implemented by an out-of-the-box fork called `FkRegex`,
which attempts to match a request URI path with the regular expression
provided:

{% highlight java %}
final class TsApp extends TsWrap {
  private static Takes make() {
    return new TsFork(
      new FkRegex("/status", new TkStatus())
    );
  }
}
{% endhighlight %}

We can compose a multi-level structure of `TsFork` classes; for example:

{% highlight java %}
final class TsApp extends TsWrap {
  private static Takes make() {
    return new TsFork(
      new FkRegex(
        "/status",
        new TsFork(
          new FkParams("f", "json", new TkStatusJSON()),
          new FkParams("f", "xml", new TkStatusXML())
        )
      )
    );
  }
}
{% endhighlight %}

Again, I believe it's obvious. The instance of `FkRegex` will ask an
encapsulated instance of `TsFork` to return a _take_, and it will try to
fetch it from one that `FkParams` encapsulated. If the HTTP query is
`/status?f=xml`, an instance of `TkStatusXML` will be returned.

## HTTP Response

Now let's discuss the structure of the HTTP response and its object-oriented
abstraction, [`Response`](http://www.takes.org/apidocs-0.9/org/takes/Response.html).
This is how the interface looks:

{% highlight java %}
public interface Response {
  Iterable<String> head() throws IOException;
  InputStream body() throws IOException;
}
{% endhighlight %}

Looks very similar to the [`Request`](http://www.takes.org/apidocs-0.9/org/takes/Request.html),
doesn't it? Well, it's identical, mostly because the structure of the HTTP request and
response is almost identical. The only difference is the first line.

There is a collection of useful decorators that help in response building. They
are [composable]({% pst 2015/feb/2015-02-26-composable-decorators %}),
which makes them very convenient. For example, if you want to build a response
that contains an HTML page, you compose them like this:

{% highlight java %}
final class TkIndex implements Take {
  @Override
  public Response act() {
    return new RsWithStatus(
      new RsWithType(
        new RsWithBody("<html>Hello, world!</html>"),
        "text/html"
      ),
      200
    );
  }
}
{% endhighlight %}

In this example, the decorator `RsWithBody`
creates a response with a body but with no headers at all. Then,
`RsWithType` adds the header `Content-Type: text/html` to it. Then, `RsWithStatus`
makes sure the first line of the response contains `HTTP/1.1 200 OK`.

You can create your own decorators that can reuse existing ones. Take a look
at how it's done in [`RsPage`](https://github.com/yegor256/rultor/blob/1.50.2/src/main/java/com/rultor/web/RsPage.java)
from rultor.com.

## How About Templates?

Returning simple "Hello, world" pages is not a big problem, as we can see. But
what about more complex output like HTML pages, XML documents, JSON
data sets, etc? There are a few convenient `Response` decorators that
enable all of that. Let's start with [Velocity](http://velocity.apache.org),
a simple templating engine. Well, it's not that simple. It's rather powerful,
but I would suggest to use it in simple situations only. Here is how it
works:

{% highlight java %}
final class TkIndex implements Take {
  @Override
  public Response act() {
    return new RsVelocity("Hello, ${name}")
      .with("name", "Jeffrey");
  }
}
{% endhighlight %}

The [`RsVelocity`](http://www.takes.org/apidocs-0.9/org/takes/rs/RsVelocity.html) constructor
accepts a single argument that has to be a Velocity template. Then, you call
the `with()` method, injecting data into the Velocity context. When it's time
to render the HTTP response, `RsVelocity` will "evaluate" the template
against the context configured. Again, I would recommend you use
this templating approach only for simple outputs.

For more complex HTML documents, I would recommend you use XML/XSLT
in combination with Xembly. I explained this idea in a few previous posts:
[XML+XSLT in a Browser]({% pst 2014/jun/2014-06-25-xml-and-xslt-in-browser %})
and [RESTful API and a Web Site in the Same URL]({% pst 2014/sep/2014-09-09-restful-web-sites %}).
It is simple and powerful &mdash; Java generates XML output and the XSLT
processor transforms it into HTML documents. This is how we separate
representation from data. The XSL stylesheet is a "view" and `TkIndex` is a "controller",
in terms of [MVC](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller).

I'll write a separate article about templating with Xembly and XSL very soon.

In the meantime, we'll create decorators for [JSF/Facelets](http://en.wikipedia.org/wiki/Facelets)
and [JSP](http://en.wikipedia.org/wiki/JavaServer_Pages) rendering
in Takes. If you're interested in helping, please fork the framework
and submit your pull requests.

## What About Persistence?

Now, a question that comes up is what to do with persistent entities, like databases,
in-memory structures, network connections, etc. My suggestion is to
initialize them inside the `Entry` class and pass them as arguments into
the `TsApp` constructor. Then, the `TsApp` will pass them into the
constructors of custom _takes_.

For example, we have a PostgreSQL database that contains
some table data that we need to render. Here is how I would
initialize a connection to it in the `Entry` class (I'm using
a [BoneCP](http://jolbox.com/) connection pool):

{% highlight java %}
public final class Entry {
  public static void main(final String... args) throws Exception {
    new FtCLI(new TsApp(Entry.postgres()), args).start(Exit.NEVER);
  }
  private static Source postgres() {
    final BoneCPDataSource src = new BoneCPDataSource();
    src.setDriverClass("org.postgresql.Driver");
    src.setJdbcUrl("jdbc:postgresql://localhost/db");
    src.setUser("root");
    src.setPassword("super-secret-password");
    return src;
  }
}
{% endhighlight %}

Now, the constructor of `TsApp` must accept a single argument of type
`java.sql.Source`:

{% highlight java %}
final class TsApp extends TsWrap {
  TsApp(final Source source) {
    super(TsApp.make(source));
  }
  private static Takes make(final Source source) {
    return new TsFork(
      new FkRegex("/", new TkIndex(source))
    );
  }
}
{% endhighlight %}

Class `TkIndex` also accepts a single argument of class `Source`. I believe
you know what to do with it inside `TkIndex` in order to fetch the SQL
table data and convert it into HTML. The point here is that the dependency
must be injected into the application (instance of class `TsApp`) at the
moment of its instantiation. This is a pure and clean dependency injection
mechanism, which is absolutely container-free. Read more about it in
["Dependency Injection Containers Are Code Polluters"]({% pst 2014/oct/2014-10-03-di-containers-are-evil %}).

## Unit Testing

Since every class is immutable and all dependencies are injected only
through constructors, unit testing is extremely easy. Let's say we want
to test `TkStatus`, which is supposed to return an HTML response
(I'm using [JUnit 4](http://junit.org/) and [Hamcrest](http://www.hamcrest.org/)):

{% highlight java %}
import org.junit.Test;
import org.hamcrest.MatcherAssert;
import org.hamcrest.Matchers;
public final class TkIndexTest {
  @Test
  public void returnsHtmlPage() throws Exception {
    MatcherAssert.assertThat(
      new RsPrint(
        new TkStatus().act()
      ).printBody(),
      Matchers.equalsTo("<html>Hello, world!</html>")
    );
  }
}
{% endhighlight %}

Also, we can start the entire application or any individual _take_ in a
test HTTP server and test its behavior via a real TCP socket; for example
(I'm using [jcabi-http](http://http.jcabi.com) to make an HTTP request and check the output):

{% highlight java %}
public final class TkIndexTest {
  @Test
  public void returnsHtmlPage() throws Exception {
    new FtRemote(new TsFixed(new TkIndex())).exec(
      new FtRemote.Script() {
        @Override
        public void exec(final URI home) throws IOException {
          new JdkRequest(home)
            .fetch()
            .as(RestResponse.class)
            .assertStatus(HttpURLConnection.HTTP_OK)
            .assertBody(Matchers.containsString("Hello, world!"));
        }
      }
    );
  }
}
{% endhighlight %}

[`FtRemote`](http://www.takes.org/apidocs-0.9/org/takes/http/FtRemote.html)
starts a test web server at a random TCP port and calls the
`exec()` method at the provided instance of `FtRemote.Script`. The first
argument of this method is a URI of the just-started web server homepage.

The architecture of Takes framework is very modular and composable. Any
individual _take_ can be tested as a standalone component, absolutely
independent from the framework and other _takes_.

## Why the Name?

That's the question I've been hearing rather often. The idea is simple, and it
originates from the movie business. When a movie is made, the crew shoots many _takes_ in order
to capture the reality and put it on film. Each capture is called a _take_.

In other words, a _take_ is like a snapshot of the reality.

The same applies to this framework. Each instance of `Take` represents
a reality at one particular moment in time. This reality is then sent to the
user in the form of a `Response`.
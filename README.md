[![Stories in Ready](https://badge.waffle.io/mumuki/mumukit-auth.png?label=ready&title=Ready)](https://waffle.io/mumuki/mumukit-auth)
[![Build Status](https://travis-ci.org/mumuki/mumukit-auth.svg?branch=master)](https://travis-ci.org/mumuki/mumukit-auth)
[![Code Climate](https://codeclimate.com/github/mumuki/mumukit-auth/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumukit-auth)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumukit-auth/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumukit-auth)


# Mumukit::Auth

> Ruby gem for handling user permissions within Mumuki

## Core Components

## Config

`Mumukit::Auth` comes with good defaults, but you can customize it using the `configure` method:

```ruby
Mumukit::Auth.configure do |config|
   config.clients.default = {id: ..., secret: ...} # change the default encoding secrets,
                                                   # see the Mumukit::Auth::Client section above
   config.client.my_custom_client = {...}          # add a new encoding secret,
                                                   # see the Mumukit::Auth::Client section above
   config.persistence_strategy = # change the default persistence strategy,
                                 # only meaningful for Mumukit::Auth::Store, see above
end
```

### Slugs

Slugs are identifier composed of two parts, separated by a slash, similar to Github's or DockerHub's slugs. For example:

* `mumuki/mumukit-auth`: the first part is `mumuki` and the last part is `mumukit-auth`
* `my-university/course-101`

There are common use cases within Mumuki:

* the first may represent the _organization_
* the second may represents a _repository_, a _course_ or a _content_

Parts are simple identifiers that can be contain alphanumeric ASCII characters, dashes or numbers. There are also two _special identifiers_:

* The match-all wildcard `*`
* The match-any wildcard `_`

Usage:

```ruby

# Creation
Mumukit::Auth::Slug.new('first', 'second')
Mumukit::Auth::Slug.from_options(first: 'hello', second: 'world')
Mumukit::Auth::Slug.from_options(organization: 'hello', repository: 'world')
Mumukit::Auth::Slug::Normalized.from_options(organization: 'Hello', repository: 'World!') # answers the slug hello/world

Mumukit::Auth::Slug.join('first', 'second')
Mumukit::Auth::Slug.join(first: 'first', second: 'second')
Mumukit::Auth::Slug.join('first') # answers the slug 'first/_'
Mumukit::Auth::Slug::Normalized.join(first: 'fïrst', second: 'sécond') # answers the slug first/second

Mumukit::Auth::Slug.join_s('first', 'second') # answers the string 'first/second'
Mumukit::Auth::Slug.join_s('first') # answers the string 'first/_'
Mumukit::Auth::Slug::Normalized.join_s('FIRST', 'Second') # answers the string 'first/second'

# Parsing
Mumukit::Auth::Slug.parse("hello/world")

# Convertion from and to string
"hello/world".to_mumukit_slug
Mumukit::Auth::Slug.new('foo', 'bar').to_s

# Comparing
"hello/world".to_mumukit_slug == "hello/world".to_mumukit_slug # true
"Hello/World!".to_mumukit_slug == "hello/world".to_mumukit_slug # true
"Hello/World!".to_mumukit_slug.eql? "hello/world".to_mumukit_slug # false
"Hello/World!".to_mumukit_slug.normalize.eql? "hello/world".to_mumukit_slug # true

# Matching
"hello/world".to_mumukit_slug.match_first 'hello'
"hello/world".to_mumukit_slug.match_second 'world'
```

### Grants

Grants are patterns for matching slugs. There are three kind of patterns:

* _all-patterns_: `*`: they match every slug
* _first-part-patterns_: `foo/*`: they match slugs whose first part match the grant
* _exact-match-patterns_: `foo/bar`: they match a single slug

```ruby
# Parsing
Mumukit::Auth::Grant.parse "*"
Mumukit::Auth::Grant.parse "foo/bar"
Mumukit::Auth::Grant.parse "foo/*"

# Convertion from and to string
"foo/*".to_mumukit_grant
a_grant.to_s

# Comparing
"*".to_mumukit_grant == "*".to_mumukit_grant

# Validating
"foo/*".to_mumukit_grant.allows? 'foo/bar' # true
"foo/*".to_mumukit_grant.allows? 'goo/bar' # false
"foo/*".to_mumukit_grant.allows? 'foo/_' # true
"baz/bar".to_mumukit_grant.allows? 'baz/bar' # true
"baz/bar".to_mumukit_grant.allows? 'goo/_' # false
"baz/bar".to_mumukit_grant.allows? Mumukit::Auth::Slug.join('foo') # false
```

### Roles

![roles hierarchy](https://yuml.me/diagram/plain/class/[Student]^-[ExStudent],[Teacher]^-[Student],[Headmaster]^-[Teacher],[Janitor]^-[Headmaster],[Editor]^-[Writer],[Manager]^-[Editor],[Manager]^-[Janitor],[Supervisor]^-[Moderator],[Supervisor]^-[Manager],[Admin]^-[Supervisor],[Owner]^-[Admin]).


```ruby
Mumukit::Auth::Roles.ROLES # answers [:ex_student, :student, :teacher, :headmaster, :writer, :editor, :janitor, :moderator, :supervisor, :manager, :admin, :owner]
```

### Permissions

`Mumukit::Auth::Permissions` is a set of specifications of what a user can do. Each permissions is a pair role-scope, for example:

```
       writer => foo/*:bar/baz
role-->^^^^^           ^^^^^^<---- grant
                 ^^^^^^^^^^^^<---- scope
       ^^^^^^^^^^^^^^^^^^^^^^<---- permission
```

The simplest way of instantiating the previous permissions is the following:

```ruby
Mumukit::Auth::Permissions.parse(writer: 'foo/*:bar/baz')
```

You can use `Mumukit::Auth::Permissions` the following way:

```ruby
# Manage permissions
some_permissions.add_permission! :owner, 'foo/*'
some_permissions.add_permission! :owner, 'foo/*', 'bar/*' # it accepts multiple permissions
some_permissions.remove_permission! :student, 'foo/bar'
some_permissions.update_permission! :student, 'foo/*', 'foo/bar'

# Checking permissions
some_permissions.has_permission? :student, 'foo/_'
some_permissions.student? 'foo/_' # equivalent to previous line
some_permissions.protect! :student, 'foo/_' # similar to previous samples,
                                            # but raises and exception instead
                                            # of returning a boolean

# Converting from and to json
some_permissions.to_json
Mumukit::Auth::Permissions.load('"writer": "foo/*:bar/baz"')

# Merging Permissions
permissions_1 = Mumukit::Auth::Permissions.parse(student: 'foo/*', teacher: 'foo/baz', owner: 'foobar/baz')
permissions_2 = Mumukit::Auth::Permissions.parse(student: 'foo/baz', teacher: 'foo/*', owner: 'bar/baz')
permissions_1.merge(permissions_2).as_json # {student: 'foo/*', teacher: 'foo/*', owner: 'foobar/baz:bar/baz' }
```

### Tokens

Tokens are easy-to-use JWT tokens.

```ruby
# Creating
Mumukit::Auth::Token.build uid, expiration: 5.minutes.from_now, metadata: {key: value}
Mumukit::Auth::Token.new metadata: {key: value}, iss: '...', aud: '...'
Mumukit::Auth::Token.new {...},
                         Mumukit::Auth::Client.new client: :myclient # use a custom client, see above

# Decoding
Mumukit::Auth::Token.decode('eyJh...XVCJ9.eA....X0.yRQ..Xw')
Mumukit::Auth::Token.decode_header('bearer eyJh...XVCJ9.eA....X0.yRQ..Xw')

# Encoding
a_token.encode # answers a jwt **string**
a_token.encode_header # answers a bearer header **string**

# Verification
a_token.verify_client!

# Usage
a_token.jwt
a_token.metadata
```

### Encoding Clients

In order to encode and decode JWT tokens, Mumukit::Auth uses a secret and id, which by default is read from the environment
variables `MUMUKI_AUTH_CLIENT_ID` and `MUMUKI_AUTH_CLIENT_SECRET`. However you can control this by changing those values
or adding more clients, so you can encode and decode multiple tokens using different id/secret pairs:

```ruby
# Change the default id and secret, useful in test environment
Mumukit::Auth.configure do |config|
   config.clients.default = {id: '...', secret: '...'}
end

# Add multiple clients...
Mumukit::Auth.configure do |config|
   config.clients.custom_client_1 = {id: '...', secret: '...'}
   config.clients.custom_client_2 = {id: '...', secret: '...'}
end
#...and then use them
Mumukit::Token.build(uid, Mumukit::Auth:Client.new(client: :custom_client_1)).encode
Mumukit::Token.decode encoded_token, Mumukit::Auth:Client.new(client: :custom_client_2)

```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

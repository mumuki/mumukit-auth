[![Stories in Ready](https://badge.waffle.io/mumuki/mumukit-auth.png?label=ready&title=Ready)](https://waffle.io/mumuki/mumukit-auth)
[![Build Status](https://travis-ci.org/mumuki/mumukit-auth.svg?branch=master)](https://travis-ci.org/mumuki/mumukit-auth)
[![Code Climate](https://codeclimate.com/github/mumuki/mumukit-auth/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumukit-auth)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumukit-auth/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumukit-auth)


# Mumukit::Auth

> Ruby gem for handling user permissions within Mumuki

## Core Components

### Slugs

Slugs are identifier composed of up to two parts, separated by a slash, similar to Github's or DockerHub's slugs. 

Usage: 

```ruby

# Creation
Mumukit::Auth:Slug.new('first', 'second')
Mumukit::Auth:Slug.from_options(first: 'hello', second: 'world')
Mumukit::Auth:Slug.from_options(organization: 'hello', repository: 'world')

Mumukit::Auth:Slug.join('first', 'second')
Mumukit::Auth:Slug.join(first: 'first', second: 'second')
Mumukit::Auth:Slug.join('first') # answers the slug 'first/_' 

Mumukit::Auth:Slug.join_s('first', 'second') # answers the string 'first/second' 
Mumukit::Auth:Slug.join_s('first') # answers the string 'first/_' 

# Parsing
Mumukit::Auth:Slug.parse("hello/world")

# Convertion from and to string
"hello/world".to_mumukit_slug
Mumukit::Auth:Slug.new('foo', 'bar').to_s

# Comparing
"hello/world".to_mumukit_slug == "hello/world".to_mumukit_slug

# Matching
"hello/world".to_mumukit_slug.match_first 'hello'
"hello/world".to_mumukit_slug.match_second 'world'
```

### Grants

Grants are patterns for matching slugs. There are three kind of patterns: 

* _all-patterns_: `*`: they match every slug
* _first-part-patterns_: `foo/*`: they match slugs whose first part match the grant, the 
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
"*".to_mumukig_grant == "*".to_mumukig_grant 

# Validating
"foo/*".to_mumukit_grant.allows? 'foo/bar' # true
"foo/*".to_mumukit_grant.allows? 'goo/bar' # false
"foo/*".to_mumukit_grant.allows? 'foo/_' # true
"baz/bar".to_mumukit_grant.allows? 'baz/bar' # true
"baz/bar".to_mumukit_grant.allows? 'goo/_' # false
```

### Roles

```ruby
Mumukit::Auth::Roles.ROLES # answers [:student, :teacher, :headmaster, :writer, :editor, :janitor, :owner]
```

### Token

Tokens are easy-to-use JWT tokens. 

```ruby
# Creating
Mumukit::Auth::Token.new metadata: {key: value}, iss: '...', aud: '...'  

# Decoding
Mumukit::Auth::Token.decode('eyJh...XVCJ9.eA....X0.yRQ..Xw')
Mumukit::Auth::Token.decode_header('bearer eyJh...XVCJ9.eA....X0.yRQ..Xw')

# Encoding
Mumukit::Auth::Token.encode(metadata: {key: value}) # answers a jwt **string**
a_token.encode # answers a jwt **string**

# Verification
a_token.verify_client!

# Usage
a_token.jwt
a_token.metadata
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).



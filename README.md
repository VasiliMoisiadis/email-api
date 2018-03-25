# Email API

This Email API allows you to send plain-text only emails to clients through supported email service providers.

Supports sending to multiple email recipients, CCs, BCCs.

**Supported Providers:**
* [Mailgun](https://www.mailgun.com/)
* [Sendgrid](https://sendgrid.com/)


## Requirements
* Ruby > 1.9
* API Credentials with supported providers


## Installation

### Ruby Gem Installation
Add this line to your application's Gemfile:

```ruby
   gem 'email_api'
```

And then execute:

```
    $ bundle
```

Or install it yourself as:

```
    $ gem install email_api
```

### Environment Variables

The gem uses environment variables to hold sensitive information. Create a `.env` file on the same directory level as where you are running the program.

Inside the `.env` files, the following need to be defined:

```
    export SENDGRID_API_USER='<Sendgrid account username>'
    export SENDGRID_API_KEY='<Sendgrid account password'
    export MAILGUN_PRIVATE_KEY='<API given by Mailgun when creating an account>'
    export MAILGUN_DOMAIN='<Domain given by Mailgun when creating an account>'
    export TEST_NAME='<The identity name used to perform tests with>'
    export TEST_EMAIL='<The email address to perform tests with>'
```


## API Usage

All usages below denote `<hosting_server>`. This is the URL path to get to the API on whichever service you host it on.

For demonstration purposes, see this example hosting server: [Demonstration Email API](http://email-api.moisiadis.com)

### Ping

#### Accepts
* No parameters supported

#### Returns
* A hash containing the current time

#### Example Usage
```
    <hosting_server>/ping
```

#### Example Response
```
    {
      "time": "2000-01-01T00:00:00+00:00"
    }
```


### Send

#### Accepts
Note: All **Email Addresses** below are expected in the format of `YOUR NAME <your email>`

* `from`
  * Usage: `YOUR NAME <your email>`
  * Only one allowed email address allowed
* `to`
  * Usage: `YOUR NAME <your email>[, YOUR NAME <your email>]`
  * Any number of email addresses allowed
* `cc` [optional]
  * Same usage and rules as `to`
* `bcc` [optional]
  * Same usage and rules as `to`
* `subject`
  * Plain text. Cannot be empty.
* `content`
  * Plain text. Cannot be empty.

#### Returns
* A hash response containing the email as parsed and the status of the request.

#### Example Usage
```
    <hosting_server>/send?from=My Name <my@email.com>&to=Your Name <your@email.com>&cc=Friend 1 <friend_1@email.com>,Friend 2 <friend_2@email.com>&subject=Hello World&content=How are you today?
```

#### Example Response
```
    {
      "email":
      {
        "from":
        {
          "name": "My Name",
          "email": "my@email.com"
        },
        "to":
        [{
          "name": "Your Name",
          "email": "your@email.com"
        }],
        "cc": 
        [{
          "name": "Friend 1",
          "email": "friend_1@email.com"
        },
        {
          "name": "Friend 2",
          "email": "friend_2@email.com"
        }],
        "bcc": null,
        "subject": "Hello World",
        "content": "How are you today?"
      },
      "status":"200: OK"
    }
```


## Development

After checking out the repo at https://github.com/VasiliMoisiadis/email-api:

### Development Installation

There are two ways to install:

For complete scripted installation:
```
    $ bash bin/setup
```

For more manual installation:
```
    $ bundle install
```

### Starting environment

The provided web service at [Moisiadis.com](http://email-api.moisiadis.com) uses Puma, and it is the primary supported web server.

Start using:
```
    $ puma config.ru
```

By default it will start on port 9292. See instructions on Puma [Configuration](https://github.com/puma/puma#configuration) to alter this. 

### Tests

Tests are performed using the [Minitest testing suite](http://docs.seattlerb.org/minitest/)

Run using:
```
    $ rake test
```

Note: Can only be tested after complete installation - this includes environment variables.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/VasiliMoisiadis/email-api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Code of Conduct

Everyone interacting in the Email API project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/VasiliMoisiadis/email-api/blob/master/CODE_OF_CONDUCT.md).

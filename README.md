Verona is a simple gem for verifying Google Play In-App Purchase receipts, and retrieving the information associated with receipt data.

There are two reasons why you should verify in-app purchase receipts on the server: First, it allows you to keep your own records of past purchases, which is useful for up-to-the-minute metrics and historical analysis. Second, server-side verification is one of the most reliable way to determine the authenticity of purchasing records.

> Verona is named for [Verona, Italy](http://en.wikipedia.org/wiki/Verona,_Italy). Also is a word game that refers to [Venice gem](https://github.com/nomad/venice), which validates purchases for Apple. Verona is the Venice classic football match.

## Installation

    $ gem install verona

## Usage

### Basic

```ruby
require 'verona'

Verona.configure do |config|
  # if true the logging will be performed via Rails.logger
  # if false (default) the logging will be peperformed via STDOUT
  config.use_rails_logger = true
  # path to your credentials json file
  config.credentials_file_path = 'some/path/to/credentials.json'
end

package = 'com.somepackage'
product_id = 'some_product_identifier'
purchase_token = 'some_hash_token'

begin
  receipt = Verona::Receipt.verify(package, product_id, purchase_token)
  puts receipt.to_h
rescue => e
  puts e.message
end
```

### For Auto-Renewable
Pending

## Command Line Interface
Pending

## Creator

Juan Furattini ([@juanfurattini](https://twitter.com/frankancle))

## License

Venice is available under the MIT license. See the LICENSE file for more info.

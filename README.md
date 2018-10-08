Verona is a simple gem for verifying Google Play In-App Purchase receipts, and retrieving the information associated with receipt data.

There are two reasons why you should verify in-app purchase receipts on the server: First, it allows you to keep your own records of past purchases, which is useful for up-to-the-minute metrics and historical analysis. Second, server-side verification is one of the most reliable way to determine the authenticity of purchasing records.

> Verona is named for [Verona, Italy](http://en.wikipedia.org/wiki/Verona,_Italy). Also is a word game that refers to [Venice gem](https://github.com/nomad/venice), which validates purchases for Apple. Verona is the Venice classic football match.

## Installation

    $ gem install verona

## Usage

### Basic

```ruby
require 'verona'

package = 'com.somepackage'
product_id = 'some_product_identifier'
purchase_token = 'some_hash_token'
credentials_path = 'path_to_credentials_file'

begin
  receipt = Verona::Receipt.verify(package, product_id, purchase_token, credentials_path)
  p receipt.to_h
rescue => e
  p e.message
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

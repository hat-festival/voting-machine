[![Build Status](https://img.shields.io/travis/hat-festival/voting-machine.svg?style=flat-square)](//travis-ci.org/hat-festival/voting-machine)
[![Coverage Status](https://img.shields.io/coveralls/hat-festival/voting-machine.svg?style=flat-square)](//coveralls.io/r/hat-festival/voting-machine)
[![License](https://img.shields.io/:license-mit-blue.svg?style=flat-square)](//github.com/hat-festival/voting-machine/blob/master/LICENSE.md)

# Voting Machine

REST API for [one of the fundamental questions](//www.quora.com/Would-you-rather-fight-100-duck-sized-horses-or-one-horse-sized-duck)

## API

_This assumes `Accept` and `Content-type` headers are set to `application/json` everywhere_

### `GET /question`

Returns a JSON representation of [the question](//www.quora.com/Would-you-rather-fight-100-duck-sized-horses-or-one-horse-sized-duck):


    {
      "description": "Ducks or Horses?",
      "premise": "Would you rather fight",
      "options": {
        "horses": "One hundred duck-sized horses",
        "duck": "One horse-sized duck"
      }
    }

### `GET /results`

Returns a JSON representation of the current voting situation:

    {
      "One horse-sized duck": 25,
      "One hundred duck-sized horses": 32
    }

### `GET /chain`

Returns a (paginated) JSON representation of the [Equestreum blockchain](//github.com/hat-festival/equestreum) where the votes are recorded:

    {
      "chain_length": 231,
      "blocks": [
        {
            "data": "genesis block",
            "time": 1533138479,
            "hash": "0008a1d9e345892d5ad0fc4673639458c841ddbb7a43040a1af29365ad948379",
            "prev": "0000000000000000000000000000000000000000000000000000000000000000",
            "nonce": 1182,
            "difficulty": 3
        },
        {
            "data": "duck",
            "time": 1533138479,
            "hash": "000cd3b03be381169c4cf95496c09e8311de6aa31cf066cf0a34098d06a5b93b",
            "prev": "0008a1d9e345892d5ad0fc4673639458c841ddbb7a43040a1af29365ad948379",
            "nonce": 12877,
            "difficulty": 3
        },
        {
          ...
        }
      }
    }

The response also contains `Link` headers, eg:

    <http://example.com:9292/chain>; rel='first',
    <http://example.com:9292/chain?page=12>; rel='last',
    <http://example.com:9292/chain?page=3>; rel='next',
    <http://example.com:9292/chain?page=1>; rel='prev'

### `GET /difficulty`

Returns a JSON representation of the current difficulty of the Equestreum chain:

    {
      "difficulty": 6 # leading zeroes on the hash
    }

### `PATCH /difficulty`

Accepts JSON to amend the difficulty of the Equestreum chain:

    {
      "difficulty": 7 # leading zeroes on the hash
    }

and writes it to the `difficulty` field in `config/equestreum.yml`

### `POST /vote`

Accepts JSON representing a vote:

    {
      "choice": "horses"
    }

and dispatches this vote onto the [Sidekiq](//github.com/mperham/sidekiq) queue

## Queue

The `VoteWorker`'s `#perform` method calls the `#grow` method of the blockchain with the vote (_:horses_ or _:duck_) as the `data`, then waits (which can take quite a while, depending on the `difficulty`). Once it returns, if it detects that it's running on a Raspberry Pi, it plays a brief mp3

Sidekiq is set with `:concurrency: 1` because attempting to grow the Equestreum chain any way other than strictly sequentially causes all manner of fuckery

## Equestreum blockchain

At startup-time, it looks for a saved Equestreum chain at the `chain_path` specified in `config/equestreum.yml`. If it doesn't find one, it creates a new one and saves it there

Each time it mines a new block, it uses the difficulty it finds in the `difficulty` field of `config/equestreum.yml`

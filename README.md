AgreeList
=============
[![Code Climate](https://codeclimate.com/github/hectorperez/agreelist/badges/gpa.svg)](https://codeclimate.com/github/hectorperez/agreelist)

Tracking influencers' opinions
http://www.agreelist.org

Prerequisites:
-------
```bash
# Redis
sudo dnf install redis # Fedora
sudo apt-get install redis-server # Ubuntu
brew install redis # Mac

# PostgreSQL
sudo dnf install postgresql postgresql-server postgresql-devel # Fedora
sudo apt-get install postgresql postgresql-contrib libpq-dev # Ubuntu
```

Install:
-------
```ruby
git clone git://github.com/hectorperez/agreelist.git
cd agreelist
bundle install
cp config/database.yml.example config/database.yml
rake db:create
rake db:setup
```

Start local server:
```
redis-server
bundle exec sidekiq
rails s
```

API
-------
GraphQL API http://www.agreelist.org/api/v1

Example of use:
http://www.agreelist.org/api/v1?query={agreements(after:8000,limit:3){id,reason,extent,individual{name,twitter,wikipedia},statement{content}}}

```
{
  agreements(after: 8800, limit: 3) {
    id
    reason
    extent
    individual {
      name
    }
    statement {
      content
    }
  }
}
```

Contribute:
--------
1. Find or create an issue

2. Add a comment to the issue to let people know you're going to work on it

3. Fork

4. Hack your changes in a topic branch (don't forget to write some tests ;)

5. Make pull request

6. Wait for comments from maintainers or code merge

License:
-------
AGPLv3

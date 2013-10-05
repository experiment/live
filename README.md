live
====

### To run locally:

1. Clone repo
```shell
git clone git@github.com:Microryza/live.git
cd live
```

1. Install node
```shell
brew install node
```

2. Install packages
```shell
npm install
```

3. Install foreman
```shell
gem install foreman
```

4. Copy the librato, new relic & redis env variables from `heroku config` and put in `.env`

5. Start app
```shell
foreman start
```

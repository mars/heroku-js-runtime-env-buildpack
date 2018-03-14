Heroku JS Runtime Env Buildpack
===============================
Use runtime environment variables in bundled/minified javascript apps.

[![Build Status](https://travis-ci.org/mars/heroku-js-runtime-env-buildpack.svg?branch=master)](https://travis-ci.org/mars/heroku-js-runtime-env-buildpack)
[![npm Module](https://img.shields.io/npm/v/@mars/heroku-js-runtime-env.svg)](https://www.npmjs.com/package/@mars/heroku-js-runtime-env)

Usage
-----

🚧 **Work in progress** 🚧

A Heroku app uses this buildpack + an [npm module](https://github.com/mars/heroku-js-runtime-env).

Background
-----------
Normally javascript apps are compiled into a bundle before being deployed. During this build phase, environment variables may be embedded in the javascript bundle, such as with [Webpack DefinePlugin](https://webpack.github.io/docs/list-of-plugins.html#defineplugin).

When hosting on a [12-factor](https://12factor.net) platform like [Heroku](https://www.heroku.com), these embedded values may go stale when setting new [config vars](https://devcenter.heroku.com/articles/config-vars) or promoting through a [pipeline](https://devcenter.heroku.com/articles/pipelines).

Originally developed as part of [create-react-app-buildpack](https://github.com/mars/create-react-app-buildpack), this buildpack aims to solve this problem in a generalized way.

How Does It Work?
-----------------

When developing a JavaScript app, use the [npm module](https://www.npmjs.com/package/@mars/heroku-js-runtime-env) to access runtime environment variables in client-side code.

Then, each time the app starts-up on Heroku, a [`.profile.d` script](https://github.com/mars/heroku-js-runtime-env/blob/master/.profile.d/inject_js_runtime_env.sh) (installed from the buildpack) is executed which fills in a [JSON placeholder](https://github.com/mars/heroku-js-runtime-env/blob/master/index.js#L15) in the JavaScript bundle with the runtime environment variables. The result is 🍃fresh runtime environment variables in the production javascript bundle without recompiling.


Development
-----------

Use Ruby 2.3.1 as built-in to Heroku-16 stack.

```bash
gem install bundler
bundle install

bundle exec rake
```
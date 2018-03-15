Heroku JS Runtime Env Buildpack
===============================
Use runtime environment variables in bundled/minified javascript apps.

[![Build Status](https://travis-ci.org/mars/heroku-js-runtime-env-buildpack.svg?branch=master)](https://travis-ci.org/mars/heroku-js-runtime-env-buildpack)
[![npm Module](https://img.shields.io/npm/v/@mars/heroku-js-runtime-env.svg)](https://www.npmjs.com/package/@mars/heroku-js-runtime-env)

Usage
-----

🚧 **Work in progress** 🚧

A Heroku app uses this buildpack + an [npm module](https://github.com/mars/heroku-js-runtime-env). 

`JS_RUNTIME_TARGET_BUNDLE` must be set to the path glob pattern for the javascript bundle containing the [heroku-js-runtime-env](https://github.com/mars/heroku-js-runtime-env). For example:

* create-react-app: `JS_RUNTIME_TARGET_BUNDLE=/app/build/index.*.js`
* vue-cli with webpack: `JS_RUNTIME_TARGET_BUNDLE=/app/dist/static/js/vendor.*.js`

`JS_RUNTIME_`-prefixed environment variables will be made available in the running Heroku app via npm module [heroku-js-runtime-env](https://github.com/mars/heroku-js-runtime-env).

### with Vue

⚠️ Vue's `npm run dev` mode does not pass arbitrary env vars instead requiring settings in `config/dev.env.js`. So, dev mode seems to be broken. (Help?)

✏️ *Replace `$APP_NAME` with your app's unique name.*

```bash
npm install -g vue-cli
vue init webpack $APP_NAME
cd $APP_NAME
git init
git add .
git commit -m '🌱 create Vue app'
heroku create $APP_NAME
heroku buildpacks:add https://github.com/mars/heroku-js-runtime-env-buildpack
heroku config:set JS_RUNTIME_TARGET_BUNDLE=/app/dist/static/js/vendor.*.js
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-static

# Serve it with static site buildpack
echo '{ "root": "dist/" }' > static.json
git add static.json
git commit -m 'Serve it with static site buildpack'
```

Add Heroku build hook to `package.json`. Merge the following `"heroku-postbuild"` property into the existing `"scripts"` section:

```json
{
  "scripts": {
    "heroku-postbuild": "npm run build"
  }
}
```

Then, commit this change:

```
git add package.json
git commit -m 'Add Heroku build hook to `package.json`'
```

In the Vue component `src/components/HelloWorld.vue`:

```
<script>
import runtimeEnv from '@mars/heroku-js-runtime-env'

export default {
  name: 'HelloWorld',
  data () {
    const env = runtimeEnv()
    return {
      msg: env.JS_RUNTIME_MESSAGE || 'JS_RUNTIME_MESSAGE is empty. Here’s a donut instead: 🍩'
    }
  }
}
</script>
```

Then, commit this code & deploy the app:

```bash
git add src/components/HelloWorld.vue
git commit -m 'Implement runtimeEnv() in a component'
git push heroku master

heroku open
```

Once deployed, you can set the `JS_RUNTIME_MESSAGE` var to see the new value take effect immediately after the app restarts:

```bash
heroku config:set JS_RUNTIME_MESSAGE=🌈
heroku open
```

Background
-----------
Normally javascript apps are compiled into a bundle before being deployed. During this build phase, environment variables may be embedded in the javascript bundle, such as with [Webpack DefinePlugin](https://webpack.github.io/docs/list-of-plugins.html#defineplugin).

When hosting on a [12-factor](https://12factor.net) platform like [Heroku](https://www.heroku.com), these embedded values may go stale when setting new [config vars](https://devcenter.heroku.com/articles/config-vars) or promoting through a [pipeline](https://devcenter.heroku.com/articles/pipelines).

Originally developed as part of [create-react-app-buildpack](https://github.com/mars/create-react-app-buildpack), this buildpack aims to solve this problem in a generalized way.

How Does It Work?
-----------------
When developing a JavaScript app, use the [npm module](https://www.npmjs.com/package/@mars/heroku-js-runtime-env) to access runtime environment variables in client-side code.

Then, each time the app starts-up on Heroku, a [`.profile.d` script](.profile.d/inject_js_runtime_env.sh) (installed from the buildpack) is executed which fills in a [JSON placeholder](https://github.com/mars/heroku-js-runtime-env/blob/master/index.js#L15) (with a `REACT_APP_` legacy name) in the JavaScript bundle with the runtime environment variables. The result is 🍃fresh runtime environment variables in the production javascript bundle without recompiling.


Development
-----------
The program which performs the bundle injection is written in Ruby 2.3.1, the version included in the Heroku-16 stack.

```bash
gem install bundler
bundle install

bundle exec rake
```

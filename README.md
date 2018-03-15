Heroku JS Runtime Env Buildpack
===============================
Use runtime environment variables in bundled/minified javascript apps.

[![Build Status](https://travis-ci.org/mars/heroku-js-runtime-env-buildpack.svg?branch=master)](https://travis-ci.org/mars/heroku-js-runtime-env-buildpack)
[![npm Module](https://img.shields.io/npm/v/@mars/heroku-js-runtime-env.svg)](https://www.npmjs.com/package/@mars/heroku-js-runtime-env)

🔬🚧 **This is a reasearch project.** Results so far indicate that it's not generalizing to different JS frameworks as gracefully as one might hope.

Usage
-----

A Heroku app uses this buildpack + an [npm module](https://github.com/mars/heroku-js-runtime-env). 

`JS_RUNTIME_TARGET_BUNDLE` must be set to the path glob pattern for the javascript bundle containing the [heroku-js-runtime-env](https://github.com/mars/heroku-js-runtime-env). For example:

* create-react-app: `JS_RUNTIME_TARGET_BUNDLE=/app/build/index.*.js`
* ember-cli ([example](#user-content-with-ember)): `JS_RUNTIME_TARGET_BUNDLE=/app/dist/assets/vendor-*.js`
* vue-cli with webpack ([example](#user-content-with-vue)): `JS_RUNTIME_TARGET_BUNDLE=/app/dist/static/js/vendor.*.js`

`JS_RUNTIME_`-prefixed environment variables will be made available in the running Heroku app via npm module [heroku-js-runtime-env](https://github.com/mars/heroku-js-runtime-env).


### with Vue

[Example Vue app](https://github.com/mars/example-vue-with-heroku-js-runtime-env), created in this experiment.

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

Then, install the npm module, commit, and deploy the app:

```bash
npm install @mars/heroku-js-runtime-env --save
git add .
git commit -m 'Implement runtimeEnv() in a component'
git push heroku master

heroku open
```

Once deployed, you can set the `JS_RUNTIME_MESSAGE` var to see the new value take effect immediately after the app restarts:

```bash
heroku config:set JS_RUNTIME_MESSAGE=🌈
heroku open
```

### with Ember

⚠️ **Not working with Ember.** The bundle file integrity check fails, because this technique changes the bundle:

> Failed to find a valid digest in the 'integrity' attribute for resource 'https://example-ember-runtime-env.herokuapp.com/assets/vendor-05f75ec213143035d715ab3c640a3ff4.js' with computed SHA-256 integrity 'oSQ3RCkKyfwVgWjG0HDlTzDFreoQnTQCUCqJoiOJEMs='. The resource has been blocked.

[Example Ember app](https://github.com/mars/example-ember-with-heroku-js-runtime-env), created in this experiment.

✏️ *Replace `$APP_NAME` with your app's unique name.*

```bash
npm install -g ember-cli
ember new $APP_NAME
cd $APP_NAME
heroku create $APP_NAME
heroku buildpacks:add https://github.com/mars/heroku-js-runtime-env-buildpack
heroku config:set JS_RUNTIME_TARGET_BUNDLE=/app/dist/assets/vendor-*.js
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
    "heroku-postbuild": "ember build --environment=production"
  }
}
```

Then, commit this change:

```
git add package.json
git commit -m 'Add Heroku build hook to `package.json`'
```

Create a component that uses JS Runtime Env:

```bash
npm install --save-dev ember-browserify
npm install --save @mars/heroku-js-runtime-env
ember generate component runtime-env
```


Edit the component `app/components/runtime-env.js` to contain:

```
import Component from '@ember/component';
import { computed } from '@ember/object';
import runtimeEnv from 'npm:@mars/heroku-js-runtime-env';

export default Component.extend({
  message: computed(function() {
    const env = runtimeEnv();
    return env.RUNTIME_JS_MESSAGE || 'RUNTIME_JS_MESSAGE is empty. Here’s a donut instead: 🍩';
  })
});
```

Edit the component template `app/templates/components/runtime-env.hbs` to contain:

```
<h2>{{message}}</h2>
{{yield}}
```

Edit the application template `app/templates/components/runtime-env.hbs` to contain:

```
{{runtime-env}}

{{!-- The following component displays Ember's default welcome message. --}}
{{welcome-page}}
{{!-- Feel free to remove this! --}}

{{outlet}}
```

Then, commit and deploy the app:

```bash
git add .
git commit -m 'Implement runtimeEnv() in a component'
git push heroku master

heroku open
```

Once deployed, you would ideally set the `RUNTIME_JS_MESSAGE` var to see the new value take effect immediately after the app restarts:

```bash
heroku config:set JS_RUNTIME_MESSAGE=🌈
heroku open
```

⚠️ **Not working with Ember.** The bundle file integrity check fails, because this technique changes the bundle:

> Failed to find a valid digest in the 'integrity' attribute for resource 'https://example-ember-runtime-env.herokuapp.com/assets/vendor-05f75ec213143035d715ab3c640a3ff4.js' with computed SHA-256 integrity 'oSQ3RCkKyfwVgWjG0HDlTzDFreoQnTQCUCqJoiOJEMs='. The resource has been blocked.


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

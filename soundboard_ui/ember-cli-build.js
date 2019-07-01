'use strict';

var ES6Modules = require('broccoli-es6modules');

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

var esTranspiler = require('broccoli-babel-transpiler');
var mergeTrees = require('broccoli-merge-trees');

module.exports = function(defaults) {
  var phoenixTree = "./vendor/phoenix";
  let app = new EmberApp(defaults, {
    'ember-bootstrap': {
      'bootstrapVersion': 4,
      'importBootstrapFont': false,
      'importBootstrapCSS': false
    },
    sassOptions: {
      extension: 'sass'
    }
  });

  // Use `app.import` to add additional libraries to the generated
  // output files.
  //
  // If you need to use different assets in different
  // environments, specify an object as the first parameter. That
  // object's keys should be the environment name and the values
  // should be the asset to use in that environment.
  //
  // If the library that you are including contains AMD or ES6
  // modules that you would like to import into your application
  // please specify an object with the list of modules as keys
  // along with the exports of each module as its value.

    var phoenixAmdFiles = new ES6Modules(phoenixTree, {
        format: 'amd',
        esperantoOptions: {
            strict: true,
            amdName: "phoenix"
        }
    });

  var phoenixTranspiledFiles = esTranspiler(phoenixAmdFiles, {});

  return mergeTrees([phoenixTranspiledFiles, app.toTree()])
};

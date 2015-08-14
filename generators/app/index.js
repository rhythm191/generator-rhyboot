'use strict';
var yeoman = require('yeoman-generator');
var chalk = require('chalk');
var yosay = require('yosay');

module.exports = yeoman.generators.Base.extend({
  prompting: function () {
    var done = this.async();

    // Have Yeoman greet the user.
    this.log(yosay(
      'Welcome to the delightful ' + chalk.red('Rhyboot') + ' generator!'
    ));

    var prompts = [{
      name: 'project',
      message: 'What is your project name?',
      default: this.appname
    },
    {
      name: 'author',
      message: 'What is your name?',
      default: "john"
    }];

    this.prompt(prompts, function (props) {
      this.props = props;
      // To access props later use this.props.someOption;

      done();
    }.bind(this));
  },

  writing: {
    app: function () {
      this.fs.copyTpl(
        this.templatePath('_package.json'),
        this.destinationPath('package.json'),
        this.props
      );
      this.fs.copyTpl(
        this.templatePath('_bower.json'),
        this.destinationPath('bower.json'),
        this.props
      );
    },

    projectfiles: function () {
      this.fs.copy(
        this.templatePath('editorconfig'),
        this.destinationPath('.editorconfig')
      );
      this.fs.copy(
        this.templatePath('jshintrc'),
        this.destinationPath('.jshintrc')
      );
      this.fs.copy(
        this.templatePath('gulpfile.coffee'),
        this.destinationPath('gulpfile.coffee')
      );
      this.fs.copy(
        this.templatePath('webpack.config.coffee'),
        this.destinationPath('webpack.config.coffee')
      );
      this.fs.copy(
        this.templatePath('scss-lint.yml'),
        this.destinationPath('scss-lint.yml')
      );
      this.fs.copy(
        this.templatePath('yo-rc.json'),
        this.destinationPath('.yo-rc.json')
      );
    },

    contentfiles: function() {
      this.fs.copyTpl(
        this.templatePath('content/index.html'),
        this.destinationPath('index.html'),
        this.props
      );
      this.fs.copy(
        this.templatePath('content/robot.txt'),
        this.destinationPath('robot.txt')
      );
    },

    assetfiles: function() {
      // assets
      this.mkdir('assets/scripts');
      this.mkdir('assets/styles/layout');
      this.mkdir('assets/styles/object');
      this.mkdir('assets/styles/utility');

      this.fs.copy(
        this.templatePath('assets/main.coffee'),
        this.destinationPath('assets/scripts/main.coffee')
      );
      this.fs.copy(
        this.templatePath('assets/_custom-bootstrap-variables.scss'),
        this.destinationPath('assets/styles/_custom-bootstrap-variables.scss')
      );
      this.fs.copy(
        this.templatePath('assets/main.scss'),
        this.destinationPath('assets/styles/main.scss')
      );
    }
  },

  install: function () {
    this.installDependencies();
  }
});

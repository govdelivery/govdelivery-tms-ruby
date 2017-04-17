const ExtractTextPlugin = require("extract-text-webpack-plugin");

var path = require('path');
var webpack = require('webpack');

var BUILD_DIR = path.resolve(__dirname, 'app');
var APP_DIR = path.resolve(__dirname, 'public');

module.exports = {
    entry: BUILD_DIR + '/main.js',
    output: {
        path: APP_DIR,
        filename: 'main.public.js',
    },
    resolve: {
      extensions: ['.js', '.jsx']
    },
    module: {
      rules: [
        {
            test: /\.jsx?$/,
            use: {
              loader: 'babel-loader'
            },
        },
        {
          test: /\.scss$/,
          use: ExtractTextPlugin.extract({
            fallback: "style-loader",
            use: "css-loader!sass-loader"
          })
        }
      ]
    },
    stats: {
        colors: true
    },
    plugins: [
      new ExtractTextPlugin("main.css"),
    ],
    devtool: 'source-map',
    devServer: {
      port: 8080,
      historyApiFallback: {
        index: 'index.html'
      }
    }
};

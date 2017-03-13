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
      loaders: [
        {
            test: /\.jsx?$/,
            loaders: ['babel-loader']
        }
      ]
    },
    stats: {
        colors: true
    },
    devtool: 'source-map'
};

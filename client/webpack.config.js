 var path = require('path');
 var webpack = require('webpack');

var BUILD_DIR = path.resolve(__dirname, 'app');
var APP_DIR = path.resolve(__dirname, 'public');

module.exports = {
    entry: BUILD_DIR + '/main.js',
    output: {
        path: APP_DIR,
        filename: 'main.public.js'
    },
    module: {
        loaders: [
            {
                test: /\.jsx$/,
                include: APP_DIR,
                loader: 'babel-loader'
            },
            {
                test: /\.css$/,
                loader: "style!css"
            }
        ]
    },
    stats: {
        colors: true
    },
    devtool: 'source-map'
};

const webpackCustom = require('../webpack.config.js');

module.exports = {
  "stories": [
    "../src/stories/**/*.stories.mdx",
    "../src/stories/**/*.stories.@(js|jsx|ts|tsx)",
  ],
  webpackFinal: (config) => {
    return {
      ...config,
      resolve: {
        alias: {
          ...config.resolve.alias,
          ...webpackCustom.resolve.alias
        } 
      },
      module: {
        ...config.module,
        rules: webpackCustom.module.rules
      },
    }
  },
}
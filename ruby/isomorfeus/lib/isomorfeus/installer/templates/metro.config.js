/**
 *
 * Isomorfeus Metro configuration for React Native
 *
 */

const path = require('path');
const { getDefaultConfig } = require("metro-config");
const RubyResolver = require('metro-resolver/ruby_resolver');

module.exports = (async () => {
  const { resolver: { sourceExts }, watchFolders } = await getDefaultConfig();
  RubyResolver.init();
  return {
    resolver: {
      ruby_options: {
        hmr: true,
        hmrHook: 'Opal.Isomorfeus.$force_render()',
        memcached: false
      },
      sourceExts: [...sourceExts, "rb"],
      resolveRequest: RubyResolver.resolve,
    },
    transformerPath: require.resolve('metro/ruby_transformer'),
    watchFolders: [...watchFolders, path.resolve(__dirname, 'app')]
  };
})();

//= require angular.min
//= require ./configurator/inflector
//= require_self

var configurator = angular.module('configurator', ['ui.inflector']);

function ConfigCtrl ($scope) {
  $scope.configUrlBase       = window.CONFIGURATOR_DATA['config_url_base'];
  $scope.configOptions       = window.CONFIGURATOR_DATA['config_options'];
  $scope.optionalLaunchTypes = window.CONFIGURATOR_DATA['optional_launch_types'];
  $scope.configUrl = "";

  $scope.hasOptionalLaunchTypes = function() {
    return ($scope.optionalLaunchTypes.length > 0);
  }

  $scope.rebuildConfigUrl = function() {
    var params = {}
    $.each($scope.configOptions, function(idx, opt) {
      if (opt.type === 'checkbox') {
        if (opt.is_checked === true) {
          params[opt.name] = opt.default_value
        }
      } else {
        if (opt.default_value.length > 0) {
          params[opt.name] = opt.default_value;
        }
      }
    });
    $.each($scope.optionalLaunchTypes, function(idx, opt) {
      if (opt.is_checked === true) {
        params[opt.name] = 1;
      }
    });
    var queryString = $.param(params);
    if (queryString.length > 0) {
      $scope.configUrl = $scope.configUrlBase + "?" + queryString;
    } else {
      $scope.configUrl = $scope.configUrlBase
    }
  }

  // Trigger rebuildConfigUrl()
  $scope.$watch('[configOptions, optionalLaunchTypes]', $scope.rebuildConfigUrl, true);

  $scope.rebuildConfigUrl();
}
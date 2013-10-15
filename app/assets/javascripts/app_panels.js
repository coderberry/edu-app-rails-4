//= require underscore-min
//= require angular.min
//= require ./angular_shared/inflector
//= require_self

var app = angular.module('app', ['ui.inflector']);

app.controller('AppPanelCtrl', ['$scope', function($scope) {
  $scope.categories = window.ENV['categories'];
  $scope.educationLevels = window.ENV['education_levels'];
  $scope.platforms = window.ENV['platforms'];
  $scope.accesses = window.ENV['accesses'];
  $scope.apps = window.ENV['apps'];
  $scope.currentCategory = null;
  $scope.currentEducationLevel = null;
  $scope.currentPlatform = null;
  $scope.currentAccess = null;
  $scope.filterText = '';
  $scope.sort = 'name';

  $scope.selectCategory = function(category) {
    if (category === undefined) {
      $scope.currentCategory = null;
    } else {
      $scope.currentCategory = category;
    }
  }
  $scope.selectEducationLevel = function(educationLevel) {
    if (educationLevel === undefined) {
      $scope.currentEducationLevel = null;
    } else {
      $scope.currentEducationLevel = educationLevel;
    }
  }
  $scope.selectPlatform = function(platform) {
    if (platform === undefined) {
      $scope.currentPlatform = null;
    } else {
      $scope.currentPlatform = platform;
    }
  }
  $scope.selectAccess = function(access) {
    if (access === undefined) {
      $scope.currentAccess = null;
    } else {
      $scope.currentAccess = access;
    }
  }
  $scope.reset = function() {
    $scope.currentCategory = null;
    $scope.currentEducationLevel = null;
    $scope.currentPlatform = null;
    $scope.currentAccess = '';
    $scope.filterText = '';
  }
  $scope.sortBy = function(srt) {
    $scope.sort = srt;
  }
  $scope.hasFilters = function() {
    return (($scope.appliedFilterIds().length > 0) || ($scope.filterText != '') || ($scope.currentAccess != null));
  }
  $scope.submitForm = function() {
    // console.log("HI");
  }
  $scope.appliedFilterIds = function() {
    var f = [];
    if ($scope.currentCategory) { f.push($scope.currentCategory.id) }
    if ($scope.currentEducationLevel) { f.push($scope.currentEducationLevel.id) }
    if ($scope.currentPlatform) { f.push($scope.currentPlatform.id) }
    return f;
  }

  $scope.hideBasedOnAccess = function(app) {
    if ($scope.currentAccess) {
      if (($scope.currentAccess.id === 'open') && (app.requires_secret === false)) {
        return false;
      } else if (($scope.currentAccess.id === 'oauth') && (app.requires_secret === true)) {
        return false;
      } else if ($scope.currentAccess != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  $scope.customCriteriaFilter = function(app) {
    if ($scope.hasFilters()) {
      if ($scope.hideBasedOnAccess(app) === true) {
        return false;
      } else {
        var matches = [];
        $.each($scope.appliedFilterIds(), function(idx, id) {
          matches.push(_.contains(app.tag_ids, id));
        });
        if ($scope.filterText.length > 0) {
          if (app.name.match(new RegExp($scope.filterText, 'gi'))) {
            matches.push(true);
          } else {
            matches.push(false);
          }
        }
        if (!_.contains(matches, false)) {
          return app;
        }
      }
    } else {
      return app;
    }
  }
}]);
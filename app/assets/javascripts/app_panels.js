//= require underscore-min
//= require_self

var app = angular.module('app', ['ui.inflector']);

app.controller('AppPanelCtrl', ['$scope', function($scope) {
  $scope.categories = window.ENV['categories'];
  $scope.educationLevels = window.ENV['education_levels'];
  $scope.platforms = window.ENV['platforms'];
  $scope.apps = window.ENV['apps'];
  $scope.currentCategory = null;
  $scope.currentEducationLevel = null;
  $scope.currentPlatform = null;
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
  $scope.reset = function() {
    $scope.currentCategory = null;
    $scope.currentEducationLevel = null;
    $scope.currentPlatform = null;
    $scope.filterText = '';
  }
  $scope.sortBy = function(srt) {
    $scope.sort = srt;
  }
  $scope.hasFilters = function() {
    return (($scope.appliedFilterIds().length > 0) || ($scope.filterText != ''));
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

  $scope.customCriteriaFilter = function(app) {
    if ($scope.hasFilters()) {
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
    } else {
      return app;
    }
  }
}]);
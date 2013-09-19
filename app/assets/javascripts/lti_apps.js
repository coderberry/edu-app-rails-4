// var filter = '';
// var tagIds = [];
// var display = $.cookie('display') || 'thumbnails';

// var showDetails = function() {
//   $.cookie('display', 'details');
//   $('a[data-display="list"]').removeClass('selected');
//   $('a[data-display="details"]').addClass('selected');
//   $('div.thumbnail-view').hide();
//   $('div.details-view').show();
//   $('li.lti-app').removeClass('col-sm-6')
//                  .removeClass('col-lg-4')
//                  .removeClass('as-list')
//                  .addClass('col-sm-12')
//                  .addClass('col-lg-12')
//                  .addClass('as-details');
// }

// var showThumbnails = function() {
//   $.cookie('display', 'thumbnails');
//   $('a[data-display="details"]').removeClass('selected');
//   $('a[data-display="list"]').addClass('selected');
//   $('div.details-view').hide();
//   $('div.thumbnail-view').show();
//   $('li.lti-app').removeClass('col-sm-12')
//                  .removeClass('col-lg-12')
//                  .removeClass('as-details')
//                  .addClass('col-sm-6')
//                  .addClass('col-lg-4')
//                  .addClass('as-list');
// }

// var applyFilters = function() {
//   $('li.lti-app').each(function(idx) {
//     var _name = $(this).data('name').toLowerCase();
//     if (_name.match(filter.toLowerCase())) {
//       if (tagIds.length > 0) {
//         var _tagIds = $(this).data('tags').split(',');
//         var _show = false;
//         $.each(tagIds, function(idx, tagId) {
//           if ($.inArray(tagId, _tagIds) >= 0) {
//             _show = true;
//             return;
//           }
//         });
//         if (_show === true) {
//           $(this).show();
//         } else {
//           $(this).hide();
//         }
//       } else {
//         $(this).show();
//       }
//     } else {
//       $(this).hide();
//     }
//   });
// }

// $(function() {
//   $('a[data-display="details"]').click(function(e) {
//     e.preventDefault();
//     showDetails();
//   });
//   $('a[data-display="list"]').click(function(e) {
//     e.preventDefault();
//     showThumbnails();
//   });
//   $('#lti-app-filter').bind("keyup input paste", function() {
//     filter = $(this).val();
//     applyFilters();
//   });
//   $('.lti-app-filter-checkbox').change(function() {
//     tagIds = $.map($('form#filters').serializeArray(), function(obj) { return obj["value"]; });
//     applyFilters();
//   });

//   // Set the view to details if that is the view in the cookie
//   if ($.cookie('display') == 'details') {
//     showDetails();
//   }
// });
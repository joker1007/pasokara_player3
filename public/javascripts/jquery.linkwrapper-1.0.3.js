/*
 * Link Wrapper - jQuery plugin for long URL
 *  
 * Copyright (c) 2008 Norifumi SUNAOKA
 *
 * Dual licensed under 
 * the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.gnu.org/licenses/gpl.html) licenses.
 *
 * Version: 1.0.3
 */

(function() {
  jQuery.fn.linkwrapper = function(config) {
    config = jQuery.extend({
      pattern: '(.)'
    }, config);
    var pattern = new RegExp(config.pattern, 'g');
    var tag = jQuery.browser.opera ? '&#8203;' : '<wbr />';
    return this.each(function() {
      jQuery(this).html(jQuery(this).text().replace(pattern, '$1' + tag));
    });
  };
})(jQuery);

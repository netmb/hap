/**
 * @author Ben
 */
var LoadingMask = function(){
    return {
        init: function(){
            var loading = Ext.get('loading');
            var mask = Ext.get('loading-mask');
            mask.setOpacity(0.8);
            mask.shift({
                xy: loading.getXY(),
                width: loading.getWidth(),
                height: loading.getHeight(),
                remove: true,
                duration: 2,
                opacity: 0.3,
                easing: 'easeOut',
                callback: function(){
                    loading.fadeOut({
                        duration: 0.2,
                        remove: true
                    });
                }
            });
        }
    }
}
();

Ext.onReady(LoadingMask.init, LoadingMask, true)

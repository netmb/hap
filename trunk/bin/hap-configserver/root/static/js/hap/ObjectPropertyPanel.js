/**
 * @author bendowski
 */
HAP.ObjectPropertyPanel = function(){
    this.id = 'objectPropertyPanel';
    this.region = 'center';
    this.split = true;
    this.autoScroll = true;
    this.height = 500;
    this.layout = 'fit';
    HAP.ObjectPropertyPanel.superclass.constructor.call(this);
}

Ext.extend(HAP.ObjectPropertyPanel, Ext.Panel, {
    removeAll: function(){
        if (this.items) 
            this.items.each(function(item, index, len){
                this.remove(item, true); //and remove from DOM !
            }, this);
    }
});

/**
 * @author bendowski
 */
HAP.ObjectTreePanel = function(){
    this.id = 'objectTreePanel';
    this.iconCls = 'objectExplorer';
    this.region = 'north'; // wichtig!
    this.height = 500; //wichtig
    this.split = true; // wichtig
    //this.title = 'Objects';
    this.border = false;
    this.iconCls = 'nav';
    this.autoScroll = true;
    this.layout = 'fit';
    HAP.ObjectTreePanel.superclass.constructor.call(this);
}

Ext.extend(HAP.ObjectTreePanel, Ext.Panel, {
    removeAll: function(){
        if (this.items) {
            this.items.each(function(item, index, len){
                if (document.getElementById(item.id)) {
                    var node = document.getElementById(item.id).parentNode;
                    if (node.hasChildNodes()) {
                        while (node.childNodes.length >= 1) {
                            node.removeChild(node.firstChild);
                        }
                    }
                    this.remove(item, true); //and remove from DOM !
                }
            }, this);
        }
    }
});

